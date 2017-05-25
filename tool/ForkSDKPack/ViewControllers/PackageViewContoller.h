//
//  PackageViewContoller.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/10.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */

#import <Cocoa/Cocoa.h>
#import "BaseViewController.h"

@interface PackageViewContoller : BaseViewController

@property (weak) IBOutlet NSComboBox *targetsComboBox;
@property (weak) IBOutlet NSComboBox *platformType;
@property (weak) IBOutlet NSComboBox *angelType;

@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSButton *generateIpaCheckBox;
@property (weak) IBOutlet NSProgressIndicator *indicatorView;
@property (weak) IBOutlet NSButton *packButton;

/**
 *  一键打包
 *
 *  @param sender sender
 */
- (IBAction)parkage:(id)sender;
@end
