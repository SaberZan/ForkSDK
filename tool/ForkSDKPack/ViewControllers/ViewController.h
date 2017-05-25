//
//  ViewController.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/8.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */
#import <Cocoa/Cocoa.h>

@class BaseView;
@interface ViewController : NSViewController
@property (weak) IBOutlet NSButton *exportButton;
@property (weak) IBOutlet NSButton *addFileButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSTextField *importText;
@property (weak) IBOutlet NSTextField *nextText;
@property (weak) IBOutlet NSTextField *titleText;

@property (weak) IBOutlet NSButton *imageButton;

@property (weak) IBOutlet NSButton *helpButton;
@end

