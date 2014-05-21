//
//  TLAppDelegate.m
//  Dulgt
//
//  Created by Erik Engheim on 5/12/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLAppDelegate.h"
#import "TLPasswordGeneratorController.h"

@implementation TLAppDelegate {
    TLPasswordGeneratorController *_passwdGeneratorController;
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

@end
