//
//  FKConfig.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *CHANNEL_CODE;
extern NSString const *ITOOLS_CONFIG;
extern NSString const *TONGBU_CONFIG;
extern NSString const *BAIDU_CONFIG;
extern NSString const *AISI_CONFIG;
extern NSString const *XY_CONFIG;
extern NSString const *HAIMA_CONFIG;
extern NSString const *KUAIYONG_CONFIG;
extern NSString const *PP_CONFIG;

@class FKChannelConfig;

extern const NSString* NSKeyFromPlatform(int type);
extern NSString *NSServerPlatformKeyWithPlatform(int channelCode);
extern int channelCodeWithNSServerPlatformKey(NSString *platformKey);
extern NSString* NSShemeWithPlatform(int channelCode, FKChannelConfig* config);

//单渠道配置信息
@interface FKChannelConfig : NSObject
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* appKey;
@property (nonatomic, strong) NSString* packName;
//通过字典初始化
- (id)initWithDic:(NSDictionary *)dic;
//通过参数初始化
- (id)initWithParams:(NSArray *)params;
//转换成字典
- (NSDictionary *)toDic;
@end

@interface FKConfig : NSObject

@property (nonatomic, strong,readonly) NSMutableDictionary *channelConfig;

#if 0
- (void)setConfig:(FKChannelConfig *)config
     forPlantform:(int)type;

- (FKChannelConfig *)configForType:(int)type;

- (id)initWithFile:(NSString *)file;

- (void)save;

//加密到文件
- (void)encodeToFile:(NSString *)filePath;

#endif

/**
 *  请求渠道APPID
 *
 *  @param appId  APPID
 *  @param appKey APPKEY
 */
- (void)fetchChannelInfo:(NSString *)appId
                  appKey:(NSString *)appKey
                callBack:(void(^)(BOOL success))callback;

//获取可打包平台
- (NSArray *)getCanUsePlatforms;

- (void)saveConfigFileWithChannelCode:(int)channelCode
                             dirction:(NSString *)dirction
                             filePath:(NSString *)filePath;
@end

