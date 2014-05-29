//
//  TLPaperBackupController.m
//  Secret Formula
//
//  Created by Erik Engheim on 5/29/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import "TLPaperBackupController.h"
#import "MIHQRCodeView.h"

@interface TLPaperBackupController ()
@property (weak) IBOutlet MIHQRCodeView *qrCodeView;
@property (weak) IBOutlet NSTextField *paperSecret;

@end

@implementation TLPaperBackupController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"TLPaperBackupController"];
    if (self) {

    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.backupString = @"nothing";
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setBackupString:(NSString *)backupString {
    _qrCodeView.dataValue = [backupString dataUsingEncoding:NSUTF8StringEncoding];
    _paperSecret.stringValue = backupString;
}

- (NSString *)backupString {
    return _paperSecret.stringValue;
}

- (NSView *)contentView {
    return self.window.contentView;
}

@end
