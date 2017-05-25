//
//  BDGameSDK+BaseInfo.h
//  BDGameSDK
//
//  Created by BeiQi56 on 15/1/14.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDGameSDK+DataModel+BaseInfo.h"


@interface BDGameSDK : NSObject

/**
 *  构建初始配置信息，供[BDGameSDK initGameSDKWith:]使用
 *
 *  @param appId               应用ID
 *  @param appKey              应用Key
 *  @param domain              SDK接入模式，默认为BDGSDKDomainTypeRelease
 *  @param distributedPlatform 发布平台，默认为BDGDistributedPlatformTypeBaidu，该字段影响[BDGameSDK loginUid]
 *  @see loginUid
 *
 *  @return 如果参数无效，返回nil
 */
+ (id<BDGSDKConfiguration>)configurationWithAppId:(NSString*)appId  appKey:(NSString*)appKey  domain:(BDGSDKDomainType)domain  distributedPlatform:(BDGDistributedPlatformType)distributedPlatform;

/**
 *  初始化BDGameSDK
 *
 *  @param cfgInfo    配置信息，由API生成：[BDGameSDK configurationWithAppId: appKey: domain: distributedPlatform: appleBundleId:]
 *  @param completion 初始化完成后的操作，如果cfgInfo参数正确，则会有短暂的logo显示，然后再触发completion
 */
+ (void)initGameSDKWith:(id<BDGSDKConfiguration>)cfgInfo  completion:(void(^)(BOOL success))completion;

/**
 *  处理SDK中与第三方App间的跳转。实现UIApplicationDelegate协议里的方法:
 *  - (BOOL)application: openURL: sourceApplication: annotation:
 *  @return 如果SDK有接管跳转信息，返回YES；否则返回NO
 */
+ (BOOL)applicationOpernUrl:(NSURL *)url  withSourceApplication:(NSString *)sourceApplication;


/**
 *  获取BDGameSDK的版本号
 *
 *  @return like @"3.5.0"
 */
+ (NSString*)SDKVersion;


@end

