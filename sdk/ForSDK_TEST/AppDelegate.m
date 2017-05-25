//
//  AppDelegate.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "AppDelegate.h"
#import "FKViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FKViewController *vc =  [FKViewController new];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = vc;
    [_window makeKeyAndVisible];
    
    return YES;
}
@end
