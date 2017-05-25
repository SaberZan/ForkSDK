//
//  FKProtocol.h
//  ForSDK_TEST
//
//  Created by xygame.com on 15/7/16.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//  SDK协议

/*
              ________   _________   _____      __   _    ______   _______     __   _
             /  _____/  / _____  /  / _   \    / / .'.'  / ____/  / ___   \   / / .'.'
            /  /____   / /    / /  / /_) /    / /-'.'   / /___   / /   '. |  / /-'.'
           /  _____/  / /    / /  / _  ,'    / _  |    /___  /  / /    / /  / _  |
     __   /  /       / /____/ /  / / \ \    / / | |   ____/ /  / /___.' /  / / | |
    / /  /__/       /________/  /_/   \_\  /_/  |_|  /_____/  /_______.'  /_/  |_|
   / /_________________________________________________________
  /___________________________________________________________/   R   O   B   I   N
 
 */

@class FKUser;
@protocol ForkSDKDelegate;

@protocol FKProtocol <NSObject>

@optional

/**
 *  初始化
 *
 *  @param appId  玄云游戏appId
 *  @param appKey 玄云游戏appKey
 */
- (void)initWithAppId:(NSString *)appId
               appKey:(NSString *)appKey;

/**
 *  delegate
 */
@property (nonatomic, assign) id<ForkSDKDelegate> delegate;

/**
 *  是否开启Debug模式
 *
 *  @param isDebug BOOL
 */
- (void)setDebugeMode:(BOOL)isDebug;

/**
 *  获取ForkSDK版本号
 *
 *  @return version
 */
- (NSString *)getSDKVersion;

/**
 *  登录
 */
- (void)login;

/**
 *  是否登录
 *
 *  @return  BOOL
 */
- (BOOL)isLogined;

/**
 *  获取已经登录用户信息
 *
 *  @return 用户信息
 */
- (FKUser *)getLoginUser;

/**
 *  登出
 */
- (void)logout;

/**
 *  是否支持平台中心
 *
 *  @return BOOL
 */
- (BOOL)isSupportedPlatformCenter;

/**
 *  进入平台中心的首页界面
 */
- (void)enterPlatformCenter;

/**
 *  是否支持显示隐藏浮动工具栏
 *
 *  @return BOOL
 */
- (BOOL)isSupportedFloatToolBar;

/**
 *  显示/隐藏浮动工具栏
 *
 *  @param centerPoint 浮动工具栏中心位置
 */
- (void)showOrHideFloatToolBar:(BOOL)isShow;

/**
 *  切换账号 游戏方需要在游戏的菜单中添加“切换账号”的入口,方便用户切换账号
 */
- (void)accountSwitch;

/**
 *  游戏支付
 *
 *  @param pruduct 产品
 */
- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price;

@end