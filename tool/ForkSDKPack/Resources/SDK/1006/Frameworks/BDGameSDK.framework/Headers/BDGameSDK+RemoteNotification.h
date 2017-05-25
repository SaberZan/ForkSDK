//
//  BDGameSDK+RemoteNotification.h
//  BDPlatformSDK
//
//  Created by BeiQi56 on 15/1/21.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import "BDGameSDK+BaseInfo.h"

@class UIApplication;


//Push 环境
typedef NS_ENUM(NSInteger, BDPushMode){
    BDPushModeDevelopment, // 开发测试环境
    BDPushModeProduction, // AppStore 上线环境
};


/**
 *  采用百度云推送，需要将push证书生成pem文件上传到百度云平台（Development/Production）
 *  详见http://push.baidu.com/doc/ios/api
 */
@interface BDGameSDK (RemoteNotification)

/**
 *  消息推送－初始化
 *  在ApplicationDelegate 中的 xxxdidFinishLaunchingWithOptions:协议里调用
 *
 *  @param API_Key          在百度云平台生成的API_Key
 *  @param launchOptions    ApplicationDelegate的参数
 */
+ (void)pushInitWithAPIKey:(NSString *)apiKey  launchOptions:(NSDictionary *)launchOptions  pushMode:(BDPushMode)pushMode;

/**
 *  消息推送－注册设备信息
 *  在ApplicationDelegate 中的 xxxdidRegisterForRemoteNotificationsWithDeviceToken: 协议里调用
 *
 *  @param deviceToken ApplicationDelegate的参数
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/**
 *  消息推送－响应收到的消息
 *  在ApplicationDelegate 中的 xxxdidReceiveRemoteNotification: 协议里调用
 *
 *  @param userInfo    ApplicationDelegate的参数
 *  @param application ApplicationDelegate的参数
 */
+ (void)handleRemoteNotication:(NSDictionary *)userInfo  withApplication:(UIApplication*)application;

@end
