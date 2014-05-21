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
    _passwdGeneratorController = [[TLPasswordGeneratorController alloc] init];

    [[_passwdGeneratorController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
