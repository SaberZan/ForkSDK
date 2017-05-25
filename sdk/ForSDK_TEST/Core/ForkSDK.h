//
//  ForkSDK.h
//  ForSDK_TEST
//
//  Created by xygame.com on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//  1.用户系统(登陆，注销，个人中心，图标悬浮) 2.支付系统(渠道支付)

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

#import <Foundation/NSString.h>
#import "FKProtocol.h"
#import "FKUser.h"

typedef enum
{
    kLoginSuccess,                //登录成功
    kLoginNetworkError,           //网络错误
    kLoginFail,                   //登录失败
    kLoginCancel,                 //取消登录
    kLogoutSuccess,               //注销成功
    kLogoutFail,                  //注销失败
    kPlatformEnter,               //进入平台
    kPlatformBack,                //离开平台
    kPausePage,                   //回调后退出暂停页面
    kExitPage,                    //回调后退出退出页面
    kAccountSwitchSuccess,        //切换账号成功
    kOpenShop,                    //回调的商店
    kUserUnknow = 50000           //未知
    
} UserActionResultCode;

typedef enum
{
    kPaySuccess = 0,              //支付成功
    kPayFail,                     //支付失败
    kPayCancel,                   //支付取消
    kPayNetworkError,             //网络错误
    kPayProductionInforIncomplete,//信息不完整
    kPayUnKnow = 30000            //未知原因
    
} PayResultCode;

@protocol ForkSDKDelegate <NSObject>
@optional

/**
 *  Init CallBack
 *
 *  @param isSuccess isSuccess
 *  @param msg       call back message
 */
-(void)onInitResult:(BOOL)isSuccess
            message:(NSString *)msg;

/**
 *  User Action CallBack
 *
 *  @param resultCode UserActionResultCode
 *  @param msg        call back message
 */
-(void)onUserActionResult:(UserActionResultCode)resultCode
                  message:(NSString *)msg;

/**
 *  Pay CallBack
 *
 *  @param payResultCode PayResultCode
 *  @param msg           call back message
 */
-(void)onPayResult:(PayResultCode)payResultCode
           message:(NSString *)msg;

@end

@interface ForkSDKManager : NSObject
/**
 *  FKProtocol
 *
 *  @return FKProtocol
 */
+ ( id<FKProtocol> )getAgentManager;

@end
