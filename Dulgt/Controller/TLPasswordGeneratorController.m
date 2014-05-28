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
@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSTextField *passwdLengthField;
@property (weak) IBOutlet NSSlider *passwdLengthSlider;

@end

@implementation TLPasswordGeneratorController {
    NSMutableSet *_logins;
    NSMutableOrderedSet *_usernames, *_targets;
}

- (instancetype)init
{
    self = [super initWithWindowNibName:@"TLPasswordGeneratorWindow"];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _model = [[TLPasswordGenerator alloc] initWithN:(int)[defaults integerForKey:@"N"]
                                                      r:(int)[defaults integerForKey:@"r"]
                                                      p:(int)[defaults integerForKey:@"p"]];
        _secretEncrypted = NO;
        _showSecret = NO;
        _logins = [[NSMutableSet alloc] initWithCapacity:20];
        _usernames = [[NSMutableOrderedSet alloc] initWithCapacity:5];
        _targets = [[NSMutableOrderedSet alloc] initWithCapacity:20];
    }
    return self;
}

- (void)windowDidLoad {
    
    [_secret bind:@"showsText"
         toObject:self
      withKeyPath:@"showSecret"
          options:nil];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int len = (int)[defaults integerForKey:@"lastUsedPasswordLength"];
    _passwdLengthSlider.integerValue = len;
    _passwdLengthField.integerValue = len;
   
    // Makes the print... menu work
    [self.window makeFirstResponder:self];
    
    [self setupToolbar];
    
    [self loadCachedLogins];
    [self changePasswordAndSecret:nil];
}

#pragma mark Toolbar

- (void) setupToolbar {
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"MainToolBar"];
    
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    
    [toolbar setDelegate: self];
    [self.window setToolbar: toolbar];
}

// Delegate methods
- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted {
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdent isEqual: @"ArchivedLogins"]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdent];
        
        [toolbarItem setLabel: @"Archived Logins"];
        
        [toolbarItem setToolTip: @"Show logins for previously generated passwords"];
        [toolbarItem setImage: [NSImage imageNamed: @"ArchivedLogins"]];
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(showArchivedLogins:)];
    } else if([itemIdent isEqual: @"LockSafe"]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdent];
        
        [toolbarItem setLabel: @"Lock"];
        
        [toolbarItem setToolTip: @"Lock Window, requiring memory secret to open again"];
        [toolbarItem setImage: [NSImage imageNamed: @"LockSafe"]];
        
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(changePassword:)];
    } else {
        toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return @[@"LockSafe", NSToolbarPrintItemIdentifier];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return @[@"LockSafe", NSToolbarPrintItemIdentifier, @"ArchivedLogins"];
}

- (void) toolbarWillAddItem: (NSNotification *) notif {
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey: @"item"];
    if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
        [addedItem setLabel:@"Store Paper Secret"];
        [addedItem setToolTip: @"Print encrypted QR code of papersecret"];
    }
}

#pragma mark -

- (void)print:(id)sender {
    [self printDocument:sender];
}

- (void) printDocument:(id) sender {
    NSImageView *view = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
    view.image = [NSImage imageNamed: @"LockSafe"];
    NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView: view];
    [printOperation runOperationModalForWindow: self.window delegate: nil didRunSelector: NULL contextInfo: NULL];
}

- (void)showArchivedLogins:(id)sender {
    NSLog(@"show logins");
}

- (void)loadCachedLogins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cachefilepath = [defaults stringForKey:@"passwordfilepath"];
    NSError *err = nil;
    NSString *cachedLogins = [NSString stringWithContentsOfFile:cachefilepath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSAlert *alert = [NSAlert alertWithError:err];
        alert.alertStyle = NSWarningAlertStyle;
        alert.informativeText = alert.messageText;
        alert.messageText = @"Unable to read info about usernames and targets used for your previously generated passwords.";
        [alert runModal];
    }
    else {
        NSScanner *scanner = [[NSScanner alloc] initWithString:cachedLogins];
        [scanner scanUpToString:@"\n" intoString:nil];
        [scanner scanString:@"\n" intoString:nil];
        while (![scanner isAtEnd]) {
            TLLogin *login = [[TLLogin alloc] initFromScanner:scanner];
            
            if (![_usernames containsObject:login.username]) {
                [_usernames addObject:login.username];
                [_login addItemWithObjectValue:login.username];
            }
            
            [_logins addObject:login];
        }
    }
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

- (IBAction)passwdLengthChanged:(NSControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.integerValue forKey:@"lastUsedPasswordLength"];
    _passwdLengthField.integerValue = sender.integerValue;
}

- (void)controlTextDidChange:(NSNotification *) note {
    NSTextField *txtField = note.object;
    if (txtField == _passwdLengthField) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:txtField.integerValue forKey:@"lastUsedPasswordLength"];
        _passwdLengthSlider.integerValue = txtField.integerValue;
        
    }
}

- (IBAction)finnishedEditingPasswdLength:(NSTextField *)sender {
    if (sender.integerValue < _model.minLength) {
        sender.integerValue = _model.minLength;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:sender.integerValue forKey:@"lastUsedPasswordLength"];
    }
}

- (IBAction)generatePassword:(id)sender {
    _model.username = _login.stringValue;
    _model.target = _target.stringValue;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _model.length = (int)[defaults integerForKey:@"lastUsedPasswordLength"];
    [_model changeCostParamN:(int)[defaults integerForKey:@"N"]
                           r:(int)[defaults integerForKey:@"r"]
                           p:(int)[defaults integerForKey:@"p"]];
    
    TLLogin *login = [_model derivedPassword];
    if (login) {
        if (![_logins containsObject:login]) {
            [_logins addObject:login];
            
            if (![_usernames containsObject:login.username]) {
                [_usernames addObject:login.username];
                [_login addItemWithObjectValue:login.username];
            }
            
            if (![_targets containsObject:login.target]) {
                [_targets addObject:login.target];
                [_target addItemWithObjectValue:login.target];
            }
            
            // cache generated password to file
            NSString *cachefilepath = [defaults stringForKey:@"passwordfilepath"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:cachefilepath]) {
                [fm createFileAtPath:cachefilepath contents:[[login colonSeparatedHeader] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
            }
            
            NSFileHandle *output = [NSFileHandle fileHandleForUpdatingAtPath:cachefilepath];
            [output seekToEndOfFile];
            [output writeData:[[login colonSeparatedData] dataUsingEncoding:NSUTF8StringEncoding]];
            [output closeFile];
        }

        // updated UI
        [self.derivedPassword setStringValue: login.password];
        
        // Put password on clipboard
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *objectsToCopy = @[login.password];
        [pasteboard writeObjects:objectsToCopy];
    }
}

- (IBAction)updateTargetList:(id)sender {
    [_target setStringValue:@""];
    
    NSPredicate *namePred = [NSPredicate predicateWithFormat:@"username LIKE %@", [_login stringValue]];
    
    NSMutableArray *targets = [[NSMutableArray alloc] initWithCapacity:20];
    for (TLLogin *login in [_logins filteredSetUsingPredicate:namePred]) {
        [targets addObject:login.target];
    }
    
    [_target removeAllItems];
    [_target addItemsWithObjectValues:targets];
    
    if (targets.count == 1) {
        _target.stringValue = targets.firstObject;
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
