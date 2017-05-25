//
//  DataManager.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/11.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKConfig.h"

typedef enum _PLATFORM_TYPE
{
    PLATFORM_AISI=1001,//爱思
    PLATFORM_XY=1002,//XY助手
    PLATFORM_HAIMA=1003,//海马
    PLATFORM_ITOOLS=1004,//itools
    PLATFORM_TONGBU=1005,//同步助手
    PLATFORM_BAIDU91=1006,//百度91
    PLATFORM_KUAIYONG=1007,//快用
    PLATFORM_PP=1008,//PP猪手
}PLATFORM_TYPE;

NSString* NSStringFromPlatform(PLATFORM_TYPE type);

NSString *PlatformFlag(PLATFORM_TYPE type);

NSString* PlatformNameFromPlatform(PLATFORM_TYPE type);

@interface DataManager : NSObject
/**
 *  instance
 *
 *  @return instance
 */
+ (instancetype)getInstance;

//工程配置路径
@property (nonatomic, strong) NSString *base_xcodeproj_dir;
//工程基础路径
@property (nonatomic, strong) NSString *base_project_dir;
//平台
@property (nonatomic, assign) PLATFORM_TYPE platform;
//平台字符串
@property (nonatomic, assign) NSString* platformString;
//用户上传的图片
@property (nonatomic, strong) NSImage *originImage;
@property (nonatomic, strong) NSString *originImagePath;

//角标方向
@property (nonatomic, assign) int angelDirection;
//屏幕方向
@property (nonatomic, strong) NSString* screenDirection;
//是否生成IPA
@property (nonatomic, assign) BOOL canGenerateIpa;
//target name
@property (nonatomic, strong) NSString* buildTargetName;

//服务器配置
@property (nonatomic, strong) FKConfig *config;

//是否可用的工程路径
- (BOOL)isAvailableProjectPath:(NSString *)path;
//是否可用的图片路径
- (BOOL)isAvailableImagePath:(NSString *)path;

@end
