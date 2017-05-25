//
//  BDGameSDK+DataModel+BaseInfo.h
//  BDGameSDK
//
//  Created by BeiQi56 on 15/1/16.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  SDK接入模式
 */
typedef NS_ENUM(unsigned, BDGSDKDomainType) {
    BDGSDKDomainTypeRelease,    // 发布包模式
    BDGSDKDomainTypeDebug,      // 开发者调试模式
};


/**
 *  发布包选择所要发布的平台
 */
typedef NS_ENUM(unsigned, BDGDistributedPlatformType) {
    BDGDistributedPlatformTypeBaidu,    // 发布到百度平台
    BDGDistributedPlatformType91,       // 发布到91平台
};


/**
 *  SDK初始配置信息
 */
@protocol BDGSDKConfiguration <NSObject>

- (NSString*)stringAppID;   // 应用ID
- (NSString*)stringAppKey;  // 应用Key
- (BDGDistributedPlatformType)distributedPlfm;  // 默认为BDGDistributedPlatformTypeBaidu，该字段影响[BDGameSDK loginUid]
- (BDGSDKDomainType)domainType;                 // 默认为BDGSDKDomainTypeRelease

@end
