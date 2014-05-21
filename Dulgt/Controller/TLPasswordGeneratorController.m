//
//  TLPasswordGeneratorController.m
//  Dulgt
//
//  Created by Erik Engheim on 5/18/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPasswordGeneratorController.h"
#import "TLPasswordGenerator.h"
#import "KSPasswordField.h"

@interface TLPasswordGeneratorController ()
@property (weak) IBOutlet NSTextField *derivedPassword;
@property (weak) IBOutlet NSWindow *secretsWindow;
@property (weak) IBOutlet NSWindow *masterpasswordWindow;
@property (weak) IBOutlet KSPasswordField *masterpassword;
@property (weak) IBOutlet KSPasswordField *secret;
@property (weak) IBOutlet KSPasswordField *singleMasterpassword;

@property (weak) IBOutlet NSComboBox *login;
@property (weak) IBOutlet NSComboBox *target;
@property (weak) IBOutlet NSSlider *lengthSlider;
@property (weak) IBOutlet NSTextField *lengthField;
@property (weak) IBOutlet NSStepper *seriesStepper;
@property (weak) IBOutlet NSTextField *seriesField;
@property (weak) IBOutlet NSButton *generateButton;

@end

@implementation TLPasswordGeneratorController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"TLPasswordGeneratorWindow"];
    if (self) {
        _model = [[TLPasswordGenerator alloc] init];
        _secretEncrypted = NO;
        _showSecret = NO;
    }
    return self;
}

- (void)windowDidLoad {
    _lengthSlider.integerValue  = _model.length;
    _lengthField.integerValue   = _model.length;
    _seriesStepper.integerValue = _model.series;
    _seriesField.integerValue   = _model.series;
    
    [_secret bind:@"showsText"
         toObject:self
      withKeyPath:@"showSecret"
          options:nil];
    
    [self changePasswordAndSecret:nil];
}

- (void)secretsSheetDidEnd:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo {
    [_model setPepper:_secret.stringValue encrypted:_secretEncrypted];
    _model.masterpassword = _masterpassword.stringValue;
    
    // want to make sure we are not accidentally leaving secrets for
    // for some uninted to copy
    _secret.stringValue = @"";
    _masterpassword.stringValue = @"";
}

- (void)masterpasswordSheetDidEnd:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo {
    _model.masterpassword = _singleMasterpassword.stringValue;
    
    // want to make sure we are not accidentally leaving secrets for
    // for some uninted to copy
    _singleMasterpassword.stringValue = @"";
}

- (IBAction)changePasswordAndSecret:(id)sender {
    [NSApp beginSheet:_secretsWindow
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(secretsSheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)endSecretsWindow:(id)sender {
    [_secretsWindow orderOut:sender];
    [NSApp endSheet:_secretsWindow returnCode:1];
}

- (IBAction)endPasswordWindow:(id)sender {
    [_masterpasswordWindow orderOut:sender];
    [NSApp endSheet:_masterpasswordWindow returnCode:1];
}

- (IBAction)changePassword:(id)sender {
    [NSApp beginSheet:_masterpasswordWindow
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(masterpasswordSheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (IBAction)passwdLengthChanged:(NSSlider*)sender {
    _lengthField.integerValue = sender.integerValue;
}

- (IBAction)seriesChanged:(NSStepper *)sender {
    _seriesField.integerValue = sender.integerValue;
}

- (IBAction)generatePassword:(id)sender {
    _model.username = _login.stringValue;
    _model.target = _target.stringValue;
    _model.length = (int)_lengthField.integerValue;
    _model.series = (int)_seriesField.integerValue;
    
    NSString *passwd = [_model derivedPassword];
    if (passwd) {
        [self.derivedPassword setStringValue: passwd];
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *objectsToCopy = @[passwd];
        [pasteboard writeObjects:objectsToCopy];
    }
}

- (void)setEncryptedSecret:(NSString *)encryptedSecret {
    NSWindow *attached = self.window.attachedSheet;
    if (attached != nil) {
        if (attached == _masterpasswordWindow) {
            NSString *passwd = _singleMasterpassword.stringValue;
            [self endPasswordWindow:nil];
            [self changePasswordAndSecret:nil];
            _masterpassword.stringValue = passwd;
        }
    }
    else {
        [self changePasswordAndSecret:nil];
    }
    _secret.stringValue = encryptedSecret;
    [self setValue:@YES forKey:@"showSecret"];
    [self setValue:@YES forKey:@"secretEncrypted"];
}

- (void)dealloc
{
    NSLog(@"Main window deallocated");
}

@end
