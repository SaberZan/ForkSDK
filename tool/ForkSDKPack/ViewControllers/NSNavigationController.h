//
//  NSNavigation.h
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
#import <AppKit/AppKit.h>

@protocol NSNavigationControllerDelegate;

@interface NSNavigationController : NSViewController

- (instancetype)initWithRootViewController:(NSViewController *)rootViewController;
- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated;
- (NSViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@property (nonatomic, strong) IBOutlet NSViewController *rootViewController;
@property(nonatomic,readonly,retain) NSViewController *topViewController;
@property(nonatomic, assign) id<NSNavigationControllerDelegate> delegate;
@property(nonatomic,copy) NSArray *viewControllers;
@property (nonatomic, strong) NSView *containerView;
@end

@protocol NSNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(NSNavigationController *)navigationController willShowViewController:(NSViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(NSNavigationController *)navigationController didShowViewController:(NSViewController *)viewController animated:(BOOL)animated;
@end

@interface NSViewController (UINavigationController)
@property(nonatomic,readonly,retain) NSNavigationController *navigationController;
@end
