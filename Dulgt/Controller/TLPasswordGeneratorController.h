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
@end
