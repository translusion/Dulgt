//
//  TLPaperBackupController.h
//  Secret Formula
//
//  Created by Erik Engheim on 5/29/14.
//  Copyright (c) 2014 Erik Engheim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TLPaperBackupController : NSWindowController
@property (nonatomic, copy) NSString *backupString;
@property (nonatomic, readonly, strong) NSView *contentView;
@end
