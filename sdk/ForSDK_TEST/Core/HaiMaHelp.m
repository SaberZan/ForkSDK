//
//  HaiMaHelp.m
//  ForSDK_TEST
//
//  Created by apple on 15/7/16.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "HaiMaHelp.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "FKAspects.h"
#import "ForkSDK.h"
#import "FKDataManager.h"

#pragma mark - pay types
typedef enum {
    kZHPayBalanceError,      /*余额不足*/
    kZHPayCreateOrderError,  /*订单创建错误*/
    kZHPayOldOrderError,     /*重复提交订单，请尝试更换订单号*/
    kZHPayNetworkingError,   /*网络不通畅（有可能已购买成功但客户端已超时,建议去自己服务器进行订单查询，以自己服务器为准）*/
    kZHPayServerError,       /*服务器错误*/
    kZHPayOtherError,        /*其他错误*/
}ZH_PAY_ERROR;

@interface HaiMaHelp (){
    @private
    Class   m_platform_class;
    FKUser* m_user;
}
@end

@implementation HaiMaHelp

- (BOOL)initializationPlatform{
    do {
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        /**
         *  @brief 初始化sdk
         *
         *  @param appid 注册时分配的appId
         *  @param test  测试更新模式。为YES时，则不论版本号，肯定提示更新；
         *  @param delegate 设置代理后可接收登录更新等相关回调
         *  @param checkType 当检查更新失败时，控制是否允许跳过强制更新；
         *                   0：不提示检查失败（直接跳过并进入游戏）
         *                   1：不允许跳过（alert只有一个"重新检查"按钮）
         *                   2：允许选择跳过更新（alert有两个按钮，一个“否”，一个“重新检查”）
         *
         *  @note  正式上线时请务必将test改为NO。若您需要设置强制更新，请登录海马后台设置
         *
         */
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        if ( config.appId<=0 ) {
            FKLog( @"获取配置appId出错" );
            break;
        }
        FKLog(@"注意：URL Scheme格式为:ZHPAY-xxxx,其中xxxx为App的Bundle identifier,例如: ZHPAY-com.company.test。(该项不设置会影响 付宝充值等功能。) \n");
        
        //get platform class
        m_platform_class = NSClassFromString(@"ZHPayPlatform");
        //init
        SEL sel = NSSelectorFromString(@"initWithAppId:withDelegate:testUpdateMode:alertTypeCheckFailed:");
        ((void(*)(id, SEL, id, id, BOOL, int))objc_msgSend)(m_platform_class,sel,config.appId, self, NO, 0);
        //set delegate
        ((void(*)(id, SEL, id))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setZHPayDelegate:"), self);
        //设置日志输出
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setLogEnable:"), self.debugMode);
        //设置支持设备方向
        ((void(*)(id, SEL, int))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setSupportOrientation:"), [FKDataManager getInstance].config.interfaceOrientation);
        
        m_user = [FKUser new];
        
        return YES;
        
    } while (0);
    
    return NO;
}

#pragma mark - protocol

- (void)login{
    ((void(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"startLogin"));
}

- (FKUser *)getLoginUser{
    return m_user;
}

- (void)logout{
    ((void(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"startLogout"));
}

- (BOOL)isSupportedPlatformCenter{
    return YES;
}

- (void)enterPlatformCenter{
    ((void(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"showUserCenter"));
}

- (BOOL)isSupportedFloatToolBar{
    return NO;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"海马不支持 显示/隐藏浮动工具栏");
}

- (void)accountSwitch{
    ((void(*)(id, SEL, BOOL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"switchAccount:"), YES);
}

- (BOOL)isLogined{
    return ((BOOL(*)(id, SEL))objc_msgSend)(m_platform_class,NSSelectorFromString(@"isLogined"));
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    
//    @property (nonatomic, copy) NSString *orderId;				    /* 订单号，必须保证唯一 */
//    @property (nonatomic, copy) NSString *productName;				/* 商品名称，不可为空 */
//    @property (nonatomic, copy) NSString *gameName;                 /* 游戏名，可精确到服或区，不可为空 例如：大掌门A区 */
//    @property (nonatomic, copy) NSString *userParams;               /* 开发者自定义参数，服务器异步通知时会原样回传，不超过255个字符 可为空*/
//    @property double productPrice;                                  /* 商品价格，单位：元 需>0 double类型*/
    id orderInfo = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"ZHPayOrderInfo"),NSSelectorFromString(@"new"));
    //orderNo
    ((void(*)(id, SEL, id))objc_msgSend)(orderInfo, NSSelectorFromString(@"setOrderId:"), orderNo);
    ((void(*)(id, SEL, id))objc_msgSend)(orderInfo, NSSelectorFromString(@"setProductName:"), name);
    ((void(*)(id, SEL, id))objc_msgSend)(orderInfo, NSSelectorFromString(@"setGameName:"), [FKDataManager getAppName]);
    ((void(*)(id, SEL, id))objc_msgSend)(orderInfo, NSSelectorFromString(@"setUserParams:"), @"");
    ((void(*)(id, SEL, double))objc_msgSend)(orderInfo, NSSelectorFromString(@"setProductPrice:"), (double)price);
    //start pay
    ((void(*)(id, SEL, id, id))objc_msgSend)(m_platform_class, NSSelectorFromString(@"startPay:delegate:"), orderInfo, self);
}

#pragma mark - platform delegate

- (void)ZHPayLoginSuccess:(id)userInfo {
    
    FKLog(@"账户登陆成功");
    
    //ZHPayUserInfo//userInfo中userId是用户唯一ID,validateToken是登陆验证token //有关登陆验证接口详见登陆有效性服务器对接验证
    NSString *userId = ((id(*)(id, SEL))objc_msgSend)(userInfo, NSSelectorFromString(@"userId")) ;
    NSString *userName = ((id(*)(id, SEL))objc_msgSend)(userInfo, NSSelectorFromString(@"userName"));
    NSString *validateToken = ((id(*)(id, SEL))objc_msgSend)(userInfo, NSSelectorFromString(@"validateToken"));
    
    if ( validateToken && userId ) {
        typeof(self) __weak _self = self;
        //验证渠道登陆
        [self authWithContent:@{@"token": validateToken, @"uid":userId} callBack:^(BOOL success) {
            if ( success ) {
                
                m_user.channelUserId = userId;
                m_user.channelUserName = userName;
                m_user.channelToken = validateToken;
                
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"海马用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"海马用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"海马用户登录失败"];
            }
        }
    }
}

- (void)ZHPayLoginFailed:(NSString *)errorInfo{
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLoginFail message:@"海马登录失败"];
        }
    }
}

- (void)ZHPayLoginCancel{
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLoginCancel message:@"海马账户登录取消"];
        }
    }
}

- (void)ZHPayDidLogout{
    m_user = [FKUser new];
    
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLogoutSuccess message:@"海马账户用户注销成功"];
        }
    }
}

/**
 *  @brief 检查更新回调
 *
 *  @param isSuccess 检查成功返回YES
 *  @param update    发现新版为YES
 *  @param force     本次是否是强制更新，强更为YES
 *
 *  @note  sdk会进行相应提示，开发者收到回调后不用再次提示用户。
 */
//- (void)ZHPayCheckUpdateFinish:(BOOL)isSuccess shouldUpdate:(BOOL)update isForceUpdate:(BOOL)force{
//    
//   FKLog(@"检查更新回调");
//}

/**
 *  @brief SDK界面出现
 *
 *  @note  如登录，账号信息界面等出现时，均会回调此方法。建议判断是否在游戏中途并将游戏临时暂停
 */
- (void)ZHPayViewIn{
     FKLog(@"SDK视图出现");
}

/**
 *  @brief SDK界面退出
 *
 *  @note  如登录，账号信息界面等消失时，均会回调此方法。
 */
- (void)ZHPayViewOut{
    FKLog(@"SDK视图消失");
}



#pragma mark -- 支付回调

/**
 *	@brief	支付成功
 *
 *	@param 	orderInfo 订单信息
 *  @note   收到回调后，SDK服务器会异步通知开发者服务器，建议去自己服务器查询订单是否有效，金额是否正确。
 */
- (void)ZHPayResultSuccessWithOrder:(id)orderInfo{

     if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
         PayResultCode code = kPaySuccess;
         NSString *messgae = @"支付成功";
         
          [self.delegate onPayResult:code message:messgae];
     }
}

/**
 *	@brief	支付失败
 *
 *	@param 	orderInfo  订单信息
 *	@param 	errorType  错误类型，见ZH_PAY_ERROR
 */
- (void)ZHPayResultFailedWithOrder:(id)orderInfo resultCode:(int)errorType{
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayFail;
        NSString *messgae = @"支付失败";
        
     
        
        
        switch (errorType) {
            case kZHPayBalanceError:
            {
                messgae = @"余额不足";
            }
                break;
            case kZHPayCreateOrderError:
            {
                messgae = @"订单创建错误";
            }
                break;
            case kZHPayOldOrderError:
            {
                messgae = @"重复提交订单，请尝试更换订单号";
            }
                break;
            case kZHPayNetworkingError:
            {
                code = kPayNetworkError;
                messgae = @"网络不通畅（有可能已购买成功但客户端已超时,建议去自己服务器进行订单查询，以自己服务器为准";
            }
                break;
            case kZHPayServerError:
            {
                code = kPayNetworkError;
                messgae = @"服务器错误";
            }
                break;
            case kZHPayOtherError:
            {
                messgae = @"其他错误";
            }
                break;
            default:
                break;
        }
        
        [self.delegate onPayResult:code message:messgae];
    }
}

/**
 *	@brief  用户中途取消支付
 *
 *	@param	orderInfo  订单信息
 */
- (void)ZHPayResultCancelWithOrder:(id)orderInfo{
    
      if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayCancel;
        NSString *messgae = @"支付取消";
        [self.delegate onPayResult:code message:messgae];

    }
    
}



@end
