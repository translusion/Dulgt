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

/**
 The fingerprint contains data in Modular Crypt Format which contains info which
 says that scrypt was used and with what parameters.
 */
NSData *fingerprint(NSString *passstr, int N, int r, int p) {
    NSData *passdata = [passstr dataUsingEncoding:NSUTF8StringEncoding];
    char outbuffer[SCRYPT_MCF_LEN];
    int status = libscrypt_hash(outbuffer, (char *)[passdata bytes], N, r, p);
    NSData *fingerprintdata = [NSData dataWithBytes:outbuffer length:strnlen(outbuffer, SCRYPT_MCF_LEN)];

    if (status != 1)
        return nil;
    return fingerprintdata;
}

BOOL doesPasswordMatchFingerprint(NSString *passwd, NSData *fingerprint) {
    char fpbuffer[512];
    NSCAssert(fingerprint.length <= 512, @"Temporary buffer wasn't large enough to hold bytes for fingerprint data");
    [fingerprint getBytes:fpbuffer length:fingerprint.length];
    int retval = libscrypt_check(fpbuffer, (char *)[passwd UTF8String]);
    NSCAssert(retval >= 0, @"Failed to perform check on fingerprint. Don't know if it matches or not");
    return retval > 0;
}


@implementation TLLogin

- (instancetype)initWithUserName:(NSString *)uname
                          target:(NSString *)target
                        password:(NSString *)password
                     fingerprint:(NSData *)fingerprint
{
    self = [super init];
    if (self) {
        _username = uname;
        _target = target;
        _password = password;
        _fingerprint = fingerprint;
    }
    return self;
}

- (int)length {
    return (int)_password.length;
}

- (NSString *)colonSeparatedHeader {
    return @"#username:target:length:fingereprint(mcf)\n";
}

- (NSString *)colonSeparatedData {
    return [NSString stringWithFormat:@"%@:%@:%d:%@\n",
            _username,
            _target,
            self.length,
            [[NSString alloc] initWithData:_fingerprint encoding:NSUTF8StringEncoding]];
}

- (NSUInteger)hash {
    return _fingerprint.hash;
}

- (BOOL)isEqual:(TLLogin *)anObject {
    return [_fingerprint isEqual:anObject.fingerprint];
}

- (NSComparisonResult)compare:(TLLogin *)other
{
    return [_target compare:other.target];
}
@end

@implementation TLPasswordGenerator {
    int _N, _r, _p;
    NSString *_pepper;
}

- (instancetype)init
{
    // default settings for scrypt 2009
    // N 16384 r 8 p 1
    return [self initWithN:SCRYPT_N r:SCRYPT_r p:SCRYPT_p];
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

- (void)changeCostParamN:(int)N r:(int)r p:(int)p {
    _N = N;
    _r = r;
    _p = p;
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


- (TLLogin *)derivedPassword {

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
    NSData *fingerdata = fingerprint(result, _N, _r, _p);
    TLLogin *login = [[TLLogin alloc] initWithUserName:_username
                                                target:_target
                                              password:result
                                           fingerprint:fingerdata];
    return login;
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
