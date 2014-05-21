//
//  TLPasswordGeneratorController.h
//  Dulgt
//
//  Created by Erik Engheim on 5/18/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import <AppKit/AppKit.h>
@class TLPasswordGenerator;

@interface TLPasswordGeneratorController : NSWindowController
@property (nonatomic, strong) TLPasswordGenerator *model;
@property (nonatomic, assign) BOOL secretEncrypted;
@property (nonatomic, assign) BOOL showSecret;
// Received secret from another app rather than keyboard.
// for safety reasons it is encrypted with master password when sent
- (void)setEncryptedSecret:(NSString *)encryptedSecret;
@end
