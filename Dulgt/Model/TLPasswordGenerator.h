//
//  TLPasswordGenerator.h
//  Dulgt
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import <Foundation/Foundation.h>

NSData *generatePassword(NSString *passstr, NSString *saltstr, int N, int r, int p, NSUInteger dklen);
NSData *fingerprint(NSString *passstr, int N, int r, int p); // Output in standard Modular Crypt Format, which contains algorithm, salt and hash
BOOL doesPasswordMatchFingerprint(NSString *passwd, NSData *fingerprint);

@interface TLLogin : NSObject
- (instancetype)initWithUserName:(NSString *)uname target:(NSString *)target password:(NSString *)password fingerprint:(NSData *)fingerprint;
- (instancetype)initFromScanner:(NSScanner *)scanner;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *target;
@property (nonatomic, copy, readonly) NSString *password;
@property (nonatomic, assign, readonly) int length;

/** Base64 encoded hash of password which can be stored to later verify password correctness */
@property (nonatomic, copy, readonly) NSData *fingerprint;

- (NSString *)colonSeparatedHeader;
- (NSString *)colonSeparatedData;

@end


@interface TLPasswordGenerator : NSObject

- (instancetype)init;
- (instancetype)initWithN:(int)N r:(int)r p:(int)p;
- (void)changeCostParamN:(int)N r:(int)r p:(int)p;
- (NSString *)derivePasswordFrom:(NSString *)passwd salt:(NSString *)salt dklen:(NSUInteger)dklen;

@property (nonatomic, copy) NSString *username;

/** Name of place to login to, e.g. Amazon, Yahoo */
@property (nonatomic, copy) NSString *target;

/** Single password which user must remember in his head */
@property (nonatomic, copy) NSString *masterpassword;

/** A long secret which is time consuming to enter or possibly impossible to remember. Something one keeps written down e.g.*/
- (void) setPepper:(NSString *)pepper encrypted:(BOOL)isEncrypted;

/** Defaults to 0. Increment by one when service requires you to make new password */
@property (nonatomic, assign) int series;

/** Desired length of generated password */
@property (nonatomic, assign) int length;

/** Password generated for given target, username and master password */
- (TLLogin *)derivedPassword;

- (int)minLength;

@end
