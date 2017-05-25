//
//  BDGameSDK+DataModel+Pay.h
//  BDPlatformSDK
//
//  Created by BeiQi56 on 15/1/18.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  支付请求操作结果
 */
typedef NS_ENUM(unsigned, BDGSDKPayResultType) {
    BDGSDKPayResultTypeCanceled,    // 支付已取消
    BDGSDKPayResultTypeCommitted,   // 支付订单已提交，结果未知
    BDGSDKPayResultTypeSuccessed,   // 支付成功
    BDGSDKPayResultTypeFailed,      // 支付失败
};


/**
 *  支付请示参数（由API生成：[BDGameSDK orderInfoWithCooOrderSerial: productName: totalPriceCent: extInfo]）
 */
@protocol BDGSDKPayOrderInfo <NSObject>

- (NSString*)cooOrderSerial;        // 订单号由（数字、字母、下划线、连接字符）组成，长度不超过128位。
- (NSString*)productName;           // 商品名称
- (unsigned long)totalPriceCent;    // 小于10w元，以分为单位
- (NSString*)extInfo;               // 可选，最长500个字符，服务器通知时原样回传

@end




#pragma mark -

/**
 *  支付订单状态
 */
typedef NS_ENUM (unsigned int, BDGSDKOrderStatus) {
    BDGSDKOrderStatusInitialized = 0,    //订单已初始化
    BDGSDKOrderStatusSuccessed   = 1,    //订单成功
    BDGSDKOrderStatusFailed      = 2,    //订单失败
};


/**
 *  支付订单信息
 */
@protocol BDGSDKOrderResult <NSObject>

- (NSString*)cooOrderSerial;        // 已经发起的支付请求订单
- (NSString*)statusDescription;     // 订单的状态描述
- (BDGSDKOrderStatus)status;        // 订单状态
- (unsigned long)orderPriceCent;    // 订单的支付金额

@end
