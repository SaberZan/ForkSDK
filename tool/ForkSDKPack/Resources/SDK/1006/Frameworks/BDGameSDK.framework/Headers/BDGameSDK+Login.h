//
//  BDGameSDK+Login.h
//  BDGameSDK
//
//  Created by BeiQi56 on 15/1/14.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import "BDGameSDK+BaseInfo.h"

typedef NS_ENUM(NSInteger, BDGameLoginUserChangedType) {
    BDGameLoginUserChangedTypeInvalid,
    BDGameLoginUserChangedTypeLogin,			// 用户登录了
    BDGameLoginUserChangedTypeLogout,			// 用户注销了
    BDGameLoginUserChangedTypeNewAccessToken,	// 用户重新登录了，产生了新的token
    BDGameLoginUserChangedTypeNewUser,			// 用户切换账号了，新的uid
    BDGameLoginUserChangedTypeTimeOut,			// 用户长时间未操作，token超时失效了
};

@interface BDGameSDK (Login)


/**
 *  登录
 *
 *  @param completion 登录操作结果回调
 */
+ (void)loginWithCompletion:(void(^)(BOOL didLogin, NSString* loginUid))completion;


/**
 *  设置已登录用户因会话超时(也有可能是用户在个人中心里手动注销)而导致登录失效情况下的操作
 *
 *  @param operation 异步回调操作，如果为nil，表示不处理。
 */
+ (void)setLoginedUserDidChangeOperation:(void(^)(BDGameLoginUserChangedType changedType))operation;


/**
 *  注销登录，会取消自动登录标记（自动登录密钥仍然有效）
 */
+ (void)logout;


/**
 *  判断当前是否已经登录用户
 *
 *  @return 已经登录用户时，返回YES；否则返回NO
 */
+ (BOOL)isLogined;


/**
 *  获取登录的用户uid，与BDPlatformSDKConfiguration.distributedPlfm有关
 *
 *  @return 如果SDK配置为BDPDistributedPlatformTypeBaidu, 返回用户在百度平台的uid；如果为BDPDistributedPlatformType91，返回用户在91平台的uid(如用于老版本兼容)
 */
+ (NSString*)loginUid;


/**
 *  获取登录用户的会话标识
 *
 *  @return 如果未登录用户，返回nil
 */
+ (NSString*)loginAccessToken;


@end

