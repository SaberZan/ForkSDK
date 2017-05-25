//
//  ConfigurationViewController.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
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

@interface ConfigurationViewController : BaseViewController
@property (weak) IBOutlet NSTextField *appIdInputView;
@property (weak) IBOutlet NSTextField *appKeyInputView;
@property (weak) IBOutlet NSProgressIndicator *indicatorView;
- (IBAction)menuAction:(id)sender;
@end
