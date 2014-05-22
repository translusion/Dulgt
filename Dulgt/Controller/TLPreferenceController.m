//
//  TLPreferenceController.m
//  Secret Formula
//
//  Created by Erik Engheim on 5/22/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPreferenceController.h"
#import "libscrypt.h"

@interface TLPreferenceController ()

@end

@implementation TLPreferenceController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"TLPreferenceController"];
    if (self) {

    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)revertScryptFactoryDefaults:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SCRYPT_N forKey:@"N"];
    [defaults setInteger:SCRYPT_r forKey:@"r"];
    [defaults setInteger:SCRYPT_p forKey:@"p"];

    // Might not be necessary, but we want to be really sure that the users know that from now on factory defaults are used.
    [defaults synchronize];
}

- (IBAction)selectPasswordFilePath:(id)sender {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [defaults stringForKey:@"passwordfilepath"];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setNameFieldStringValue:[path lastPathComponent]];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *url = [panel URL];
            [defaults setObject:[url path] forKey:@"passwordfilepath"];
        }
    }];
}

@end
