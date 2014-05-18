//
//  TLPasswordGeneratorController.m
//  Dulgt
//
//  Created by Erik Engheim on 5/18/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPasswordGeneratorController.h"
#import "TLPasswordGenerator.h"

@interface TLPasswordGeneratorController ()
@property (weak) IBOutlet NSTextField *derivedPassword;
@property (unsafe_unretained) IBOutlet NSWindow *secretsWindow;
@property (weak) IBOutlet NSTextField *masterpassword;
@property (weak) IBOutlet NSTextField *secret;

@property (weak) IBOutlet NSComboBox *login;
@property (weak) IBOutlet NSComboBox *target;
@property (weak) IBOutlet NSSlider *lengthSlider;
@property (weak) IBOutlet NSTextField *lengthLabel;
@property (weak) IBOutlet NSStepper *seriesStepper;
@property (weak) IBOutlet NSTextField *seriesLabel;
@property (weak) IBOutlet NSButton *generateButton;

@end

@implementation TLPasswordGeneratorController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"TLPasswordGeneratorWindow"];
    if (self) {
        _model = [[TLPasswordGenerator alloc] init];
    }
    return self;
}

- (void)windowDidLoad {
    _lengthSlider.integerValue  = _model.length;
    _lengthLabel.integerValue   = _model.length;
    _seriesStepper.integerValue = _model.series;
    _seriesLabel.integerValue   = _model.series;
    
    
    [NSApp beginSheet:_secretsWindow
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}

- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo {
    _model.pepper = [_secret stringValue];
    _model.masterpassword = [_masterpassword stringValue];
    
    // want to make sure we are not accidentally leaving secrets for
    // for some uninted to copy
    _model.pepper = @"";
    _model.masterpassword = @"";
}

- (IBAction)endSecretsWindow:(id)sender {
    [_secretsWindow orderOut:sender];
    [NSApp endSheet:_secretsWindow returnCode:1];
}

- (IBAction)passwdLengthChanged:(NSSlider*)sender {
    _lengthLabel.integerValue = sender.integerValue;
}

- (IBAction)seriesChanged:(NSStepper *)sender {
    _seriesLabel.integerValue = sender.integerValue;
}

- (IBAction)generatePassword:(id)sender {
    _model.username = _login.stringValue;
    _model.target = _target.stringValue;
    _model.length = (int)_lengthLabel.integerValue;
    _model.series = (int)_seriesLabel.integerValue;
    
    NSString *passwd = [_model derivedPassword];
    if (passwd)
        [self.derivedPassword setStringValue: passwd];
}

- (void)dealloc
{
    NSLog(@"Main window deallocated");
}

@end
