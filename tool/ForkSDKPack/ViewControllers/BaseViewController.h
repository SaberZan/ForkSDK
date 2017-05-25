//
//  BaseViewController.h
//  ForkSDKPack
//
//  Created by ruikong on 15/10/22.
//  Copyright © 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */
#import <Cocoa/Cocoa.h>

@interface BaseViewController : NSViewController

@property (weak) IBOutlet NSButton *toBackButton;
@property (weak) IBOutlet NSTextField *toBackText;

- (void)drawBackground;

- (void)alert:(NSString *)text;

@end
