//
//  TLPasswordGenerator.m
//  Dulgt
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPasswordGenerator.h"
#include "libscrypt.h"

#define b64_encode_len(A) ((A+2)/3 * 4 + 1)
#define b64_decode_len(A) (A / 4 * 3 + 2)

NSData *generatePassword(NSString *passstr, NSString *saltstr, int N, int r, int p, NSUInteger dklen) {
    NSData *passdata = [passstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [saltstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *digestdata = [NSMutableData dataWithLength:dklen];
    libscrypt_scrypt([passdata bytes], [passdata length],
                     [salt bytes], [salt length],
                     N, r, p,
                     [digestdata mutableBytes], [digestdata length]);
    return digestdata;
}

@implementation TLPasswordGenerator {
    int _N, _r, _p;
}

- (instancetype)init
{
    // default settings for scrypt 2009
    return [self initWithN:16384 r:8 p:1];
}

- (instancetype)initWithN:(int)N r:(int)r p:(int)p
{
    self = [super init];
    if (self) {
        _N = N;
        _r = r;
        _p = p;
        _length = 8;
    }
    return self;
}

- (NSString *)derivePasswordFrom:(NSString *)passwd salt:(NSString *)salt dklen:(NSUInteger)dklen {
    NSData *digestdata = generatePassword(passwd, salt, _N, _r, _p, dklen);
    NSString *derivepassword = [digestdata base64EncodedStringWithOptions:0];
    
    return derivepassword;
}


- (NSString *)derivedPassword {

    NSString *finalpassword = [NSString stringWithFormat:@"%@ %@ %@ %d",
                               _username,
                               _masterpassword,
                               _secret,
                               _length];
    int dklen = 8;

    NSString *derivepassword = [self derivePasswordFrom:finalpassword salt:_target dklen:dklen];
    
    NSUInteger dlen = [derivepassword length];
    int alt = b64_encode_len(_length);
    
    return derivepassword;
}

@end
