//
//  TLAppDelegate.m
//  Dulgt
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLAppDelegate.h"
#import "TLPasswordGeneratorController.h"
#import "TLPreferenceController.h"
#import "libscrypt.h"

@implementation TLAppDelegate {
    TLPasswordGeneratorController *_passwdGeneratorController;
    TLPreferenceController *_preferenceController;
}

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *passworfilepath = [paths firstObject];
    passworfilepath = [passworfilepath stringByAppendingPathComponent:@"cachedpasswords"];
    NSDictionary *defaults = @{
                               @"passwordfilepath": passworfilepath,
                               // scrypt algorithm parameters
                               @"N": @SCRYPT_N,
                               @"r": @SCRYPT_r,
                               @"p": @SCRYPT_p};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    
    _passwdGeneratorController = [[TLPasswordGeneratorController alloc] init];
    [[_passwdGeneratorController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *encryptedSecret = url.host;
    [_passwdGeneratorController setEncryptedSecret:encryptedSecret];
}

- (IBAction)showPreferencePanel:(id)sender {
    if (!_preferenceController) {
        _preferenceController = [[TLPreferenceController alloc] init];
    }
    [_preferenceController showWindow:self];
}
@end
