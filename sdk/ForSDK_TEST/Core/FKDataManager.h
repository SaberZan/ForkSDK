//
//  FKDataManager.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//  管理SDK数据

#import <Foundation/Foundation.h>
#import "FKConfig.h"

@interface FKDataManager : NSObject

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) FKConfig *config;

/**
 *  instance
 *
 *  @return instance
 */
+ (instancetype)getInstance;

/**
 *  通过本地文件初始化数据
 */
- (void)serialization;

/**
 *  获取本地配置的渠道Code
 *
 *  @return 渠道Code
 */
- (uint32_t)getChannelCode;

/**
 *  请求渠道信息
 */
- (void)requestChannelInfoCompleteCallBack:(void(^)(NSDictionary *info))callback;


/**
 *  验证登陆
 *
 *  @param token    token
 *  @param callback callback
 */
- (void)requestAuth:(NSString *)content
   completeCallBack:(void(^)(NSDictionary *info))callback;

/**
 *  获取APP名称
 *
 *  @return app name
 */
+ (NSString *)getAppName;

/**
 *  获取APP版本号
 *
 *  @return app version
 */
+ (NSString *)getAppVersion;

/**
 *  获取schemes
 *
 *  @return schemes
 */
+ (NSString *)getSchemes;
@end
