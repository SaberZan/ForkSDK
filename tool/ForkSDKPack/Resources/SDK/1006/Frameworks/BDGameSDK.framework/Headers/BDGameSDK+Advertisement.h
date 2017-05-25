//
//  BDGameSDK+Advertisement.h
//  BDPlatformSDK
//
//  Created by BeiQi56 on 15/1/21.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import "BDGameSDK+BaseInfo.h"


@interface BDGameSDK (Advertisement)

/**
 *  显示广告页
 *  在ApplicationDelegate 中的 xxxwillEnterForeground: 协议里调用
 */
+ (void)showAdvertView;

/**
 *  关闭广告页
 *  在ApplicationDelegate 中的 xxxdidEnterBackground: 协议里调用
 */
+ (void)closeAdverView;

@end
