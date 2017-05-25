//
//  ConfigurationViewController.m
//  ForkSDKPack
//
//  Created by ; on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */

#import "ConfigurationViewController.h"
#import "BaseView.h"
#import "NSNavigationController.h"
#import "PackageViewContoller.h"
#import "DataManager.h"
#import "FKConfig.h"
#import "NSTextField+copy.h"

@implementation ConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //background
    [self drawBackground];
    
    self.indicatorView.hidden=YES;

#if 0
    self.appIdInputView.stringValue = @"fate";
    self.appKeyInputView.stringValue = @"4U8jTMWIq";
#endif
}

- (IBAction)menuAction:(id)sender{
    do {
        
        if ( !self.appIdInputView.stringValue || self.appIdInputView.stringValue.length==0 ) {
            [self alert:@"请输入玄云游戏APPID"];
            break;
        }
        
        if ( !self.appKeyInputView.stringValue || self.appKeyInputView.stringValue.length==0 ) {
            [self alert:@"请输入玄云游戏APPKEY"];
            break;
        }
        
        //fetch platform config
        [self fetchPlatformConfig];
        
    } while (0);
}

- (void)fetchPlatformConfig{
    self.indicatorView.hidden=NO;
    [self.indicatorView startAnimation:nil];
    
    [[DataManager getInstance].config fetchChannelInfo:self.appIdInputView.stringValue appKey:self.appKeyInputView.stringValue callBack:^(BOOL success) {
        self.indicatorView.hidden=YES;
        [self.indicatorView stopAnimation:nil];
        
        if ( success ) {
            NSDictionary *channelConfig = [DataManager getInstance].config.channelConfig;
            if ( channelConfig && channelConfig.allValues>0 ) {
                [self gotoPack];
            }
            else
            {
                [self alert:@"获取渠道参数失败，请至少配置一个渠道"];
            }
        }
        else
        {
            [self alert:@"获取渠道参数失败！请输入正确的appId && appKey!"];
        }
    }];
}

- (void)gotoPack{
    NSViewController *vc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PackageViewContoller"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
