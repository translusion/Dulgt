//
//  TLPasswordGenerator.m
//  Dulgt
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPasswordGenerator.h"
#include "libscrypt.h"
#include "b64.h"

static NSData *generatePassword(NSString *passstr, NSString *saltstr, int N, int r, int p) {
    NSData *passdata = [passstr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *salt = [saltstr dataUsingEncoding:NSUTF8StringEncoding];
    
    int dklen = 8;
    NSMutableData *digestdata = [NSMutableData dataWithLength:dklen];
    libscrypt_scrypt([passdata bytes], [passdata length],
                     [salt bytes], [salt length],
                     N, r, p,
                     [digestdata mutableBytes], [digestdata length]);
    return digestdata;
}

@implementation TLPasswordGenerator



- (NSString *)derivedPassword {

    int N = 16384;
    int r = 8;
    int p = 1;
    
    NSString *finalpassword = [NSString stringWithFormat:@"%@:%@:%@:%d",
                               _username,
                               _masterpassword,
                               _secret,
                               _length];
    
    NSData *digestdata = generatePassword(finalpassword, _target, N, r, p);
    NSString *derivepassword = [[NSString alloc] initWithData:digestdata
                                                     encoding:NSUTF8StringEncoding];
    return derivepassword;
}

@end
