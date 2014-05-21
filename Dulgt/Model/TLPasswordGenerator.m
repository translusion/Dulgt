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

/** Resturn nil on failure otherwise a valid NSData object is returned */
NSData *generatePassword(NSString *passstr, NSString *saltstr, int N, int r, int p, NSUInteger dklen) {
    NSData *passdata = [passstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [saltstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *digestdata = [NSMutableData dataWithLength:dklen];
    int status = libscrypt_scrypt([passdata bytes], [passdata length],
                     [salt bytes], [salt length],
                     N, r, p,
                     [digestdata mutableBytes], [digestdata length]);
    if (status != 0)
        return nil;
    return digestdata;
}

@implementation TLLogin

- (instancetype)initWithUserName:(NSString *)uname target:(NSString *)target length:(int)length
{
    self = [super init];
    if (self) {
        _username = uname;
        _target = target;
        _length = length;
    }
    return self;
}

@end

@implementation TLPasswordGenerator {
    int _N, _r, _p;
    NSString *_pepper;
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
        
        _series = 0;
        _length = 8;
    }
    return self;
}

- (void) setPepper:(NSString *)pepper encrypted:(BOOL)isEncrypted {
    _pepper = pepper; // Handle decryption
}

- (int)minLength {
    return 4; // should not have smaller passwords than this
}


/** Returns nil if failed to generate password */
- (NSString *)derivePasswordFrom:(NSString *)passwd salt:(NSString *)salt dklen:(NSUInteger)dklen {
    NSData *digestdata = generatePassword(passwd, salt, _N, _r, _p, dklen);
    if (digestdata == nil)
        return nil;
    NSString *derivepassword = [digestdata base64EncodedStringWithOptions:0];
    
    return derivepassword;
}


- (NSString *)derivedPassword {

    NSString *finalpassword = [NSString stringWithFormat:@"%@ %@ %@ %d",
                               _username,
                               _masterpassword,
                               _pepper,
                               _series];
    
    NSUInteger dklen = b64_decode_len(_length)+1;
    NSString *derivepassword = [self derivePasswordFrom:finalpassword salt:_target dklen:dklen];
    if (derivepassword == nil)
        return nil;
    NSString *result = [derivepassword substringToIndex:_length];
    return result;
}

/*
 If we don't have this method implemented then an exception will be raised each
 time we erase all the text in a number textfield bound to this model.
 
 Look at: http://stackoverflow.com/questions/9102884/setnilvalueforkey-error
 */
- (void)setNilValueForKey:(NSString*)key {
    if ([key isEqualToString:@"length"])
        self.length = self.minLength;
    else  if ([key isEqualToString:@"series"])
        self.series = 0;
    else
        [super setNilValueForKey:key];
}

@end
