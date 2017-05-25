//
//  BDGameSDK+Pay.h
//  BDGameSDK
//
//  Created by BeiQi56 on 15/1/14.
//  Copyright (c) 2015年 Baidu-91. All rights reserved.
//

#import "BDGameSDK+BaseInfo.h"
#import "BDGameSDK+DataModel+Pay.h"


@interface BDGameSDK (Pay)


/**
*  构建支付信息，供[BDGameSDK payWithInfo:xxx:]使用
*
*  @param cooOrderSerial 订单号由（数字、字母、下划线、连接字符）组成，长度不超过128位
*  @param productName    商品名称
*  @param totalPriceCent 小于10w元，以分为单位
*  @param extInfo        可选，最长500个字符，服务器通知时原样回传
*
*  @return 如果参数不合法，返回nil；否则返回支付信息对象
*/
+ (id<BDGSDKPayOrderInfo>)orderInfoWithCooOrderSerial:(NSString*)cooOrderSerial  productName:(NSString*)productName  totalPriceCent:(unsigned long)totalPriceCent  extInfo:(NSString*)extInfo;


/**
 * 支付
 *
 * @param orderInfo         支付信息，由API生成：[BDGameSDK orderInfoWithCooOrderSerial: productName: totalPriceCent: extInfo]
 * @param stringDebugUrl    支付结果通知服务器地址，需要SDK配置为BDGSDKDomainTypeDebug才有效。
 * @see @class BDGSDKConfiguration
 * @param completion    支付操作结果回调
 */
+ (void)payWithInfo:(id<BDGSDKPayOrderInfo>)orderInfo  serverNotifyUrl:(NSString*)stringDebugUrl  completion:(void(^)(NSError* error, BDGSDKPayResultType payResult))completion;




#pragma mark -

/**
 *  查询支付订单
 *
 *  @param orderSerial 提交支付的订单号
 *  @param completoin  订单查询结果回调
 */
+ (void)queryPayOrderStatusWithCooOrderSerial:(NSString*)orderSerial  completion:(void(^)(NSError* error, id<BDGSDKOrderResult> orderResult))completoin;


@end
