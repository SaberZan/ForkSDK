//
//  FileUtil.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/11.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//  1.拷贝处理ForkSDK
//  2.生成icon512x512.png（角标）
//  3.通过icon512x512.png缩小生成16种尺寸ICON
//  4.生成配置文件FKConfig.plist 和 res256加密过的 developerInfo.xml
//  2.工程文件拷贝处理 （添加依赖库）

/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@class XCProject;
@class XCTarget;

@interface FileUtil : NSObject


@property (nonatomic, copy) void(^logCallBack)(NSString *lineLog);
/**
 *  操作工程配置
 */
@property (nonatomic, strong) XCProject *projectManager;
@property (nonatomic, strong) XCTarget *projectTarget;

//获取所有ICON配置
@property (nonatomic, strong,readonly) NSMutableArray *iconsFiles;
//获取 用户/文档/ForkSDK/ 路径
@property (nonatomic, strong,readonly) NSString *documentForkSDKPath;

//应用程序/Content/Resource/ForkSDK/
@property (nonatomic, strong,readonly) NSString *fromForkSDKPath;
//打包到工程的路径 /project/ForkSDK/
@property (nonatomic, strong,readonly) NSString *toForkSDKPath;
//打包到工程的路径 /project/ForkSDK/渠道ID
@property (nonatomic, strong,readonly) NSDictionary *toChannelSDKPaths;

/**
 *  instance
 *
 *  @return instance
 */
+ (instancetype)getInstance;

/**
 *  拷贝目录
 *
 *  @param dir   要拷贝的目录
 *  @param toDir 目标目录
 */
- (void)copyDir:(NSString *)dir
          toDir:(NSString *)toDir;

/**
 *  拷贝文件
 *
 *  @param filePath   文件地址
 *  @param toFilePath 目标地址
 */
- (void)copyFile:(NSString *)filePath
      toFilePath:(NSString *)toFilePath;

/**
 *  合并图片
 *
 *  @param image1 背景
 *  @param image2 覆盖
 *
 *  @return 新图片
 */
- (NSImage *)addImage:(NSImage *)image1
             toImage:(NSImage *)image2;

/**
 *  重新设置图片大小
 *
 *  @param image 图片
 *  @param size  大小
 *
 *  @return 新图片
 */
- (NSImage *)reSizeImage:(NSImage *)image
                  toSize:(CGSize)size;

/**
 *  获取原工程的taget names
 */
- (NSArray *)getOriginalTargetsNames;

/**
 *  生成所需要的所有文件
 */
- (void)makeSupportFiles;

/**
 *  复制和修改新工程
 */
- (void)copyAndMakeXcodeproj;

/**
 *  生成IPA
 */
- (void)generateIpa;

@end
