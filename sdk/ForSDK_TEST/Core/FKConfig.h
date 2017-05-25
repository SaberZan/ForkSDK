//
//  FKConfig.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>

extern NSString const *CHANNEL_CODE;
extern NSString const *ITOOLS_CONFIG;
extern NSString const *TONGBU_CONFIG;
extern NSString const *BAIDU_CONFIG;
extern NSString const *AISI_CONFIG;
extern NSString const *XY_CONFIG;
extern NSString const *HAIMA_CONFIG;
extern NSString const *KUAIYONG_CONFIG;
extern NSString const *PP_CONFIG;

@interface FKChannelConfig : NSObject
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong) NSString* appKey;
@property (nonatomic, strong) NSString* callBackUrl;

- (id)initWithDic:(NSDictionary *)dic;

- (id)initWithParams:(NSArray *)params;
@end

@interface FKConfig : NSObject

@property (nonatomic, assign) NSInteger channelCode;
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientation;
@property (nonatomic, strong) FKChannelConfig *channelConfig;

- (id)initWithFile:(NSString *)fileName;

@end

