//
//  PPHelp.m
//  ForSDK_TEST
//
//  Created by apple on 15/8/5.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "PPHelp.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "FKAspects.h"
#import "FKUser.h"
#import "FKNetHelp.h"
#import "FKMacro.h"
#import "ForkSDK.h"
#import "FKDataManager.h"

/**
 * @brief 直接支付错误码
 */
typedef enum{
    /**
     * 购买成功
     */
    PPPayResultCodeSucceed	= 0,
    /**
     * 进入充值并兑换流程
     */
    PPPayResultCodePayAndExchange	= 1,
    /**
     * 禁止访问
     */
    PPPayResultCodeForbidden = 1001,
    /**
     * 该用户不存在
     */
    PPPayResultCodeUserNotExist = 1002,
    /**
     * 必选参数丢失
     */
    PPPayResultCodeParamLost = 1003,
    /*
     * PP币余额不足
     */
    PPPayResultCodeNotSufficientFunds = 1004,
    /**
     * 该游戏数据不存在
     */
    PPPayResultCodeGameDataNotExist = 1005,
    /**
     * 开发者数据不存在
     */
    PPPayResultCodeDeveloperNotExist = 1006,
    /**
     * 该区数据不存在
     */
    PPPayResultCodeZoneNotExist = 1007,
    /**
     * 系统错误
     */
    PPPayResultCodeSystemError = 1008,
    /**
     * 购买失败
     */
    PPPayResultCodeFail = 1009,
    /**
     * 与开发商服务器通信失败，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602
     */
    PPPayResultCodeCommunicationFail = 1010,
    /**
     * 开发商服务器未成功处理该订单，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602
     */
    PPPayResultCodeUntreatedBillNo = 1011,
    /**
     * 用户中途取消
     */
    PPPayResultCodeCancel = 1012,
    /**
     * 您的账户存在异常，PP币余额无法正常使用，建议您联系PP客服，电话：020-38276673，QQ：800055602
     */
    PPPayResultCodeAccountIsLocked = 1013,
    /**
     * 非法访问，可能用户已经下线
     */
    PPPayResultCodeUserOffLine = 999,
    
}PPPayResultCode;

typedef enum {
    PPSDKInterfaceOrientationMaskTypeLandscape, //横屏
    PPSDKInterfaceOrientationMaskTypePortrait,  //竖屏
}PPSDKInterfaceOrientationMaskType;
/**
 *  银联支付结果 通知
 */
#define PP_CUPPAY_RESULT_NOTIFICATION_  @"PPCUPPayResultNotification"

@interface PPHelp (){
    @private
    FKUser* m_user;
    id  m_object_handle;
}
@end

@implementation PPHelp

- (BOOL)initializationPlatform{
    do {
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        FKLog( @"注意：PP助手SDK需要在URLTypes里面添加urlscheme 为teiron + AppId" );
        
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        if ( config.appId<=0 || !config.appKey ) {
            FKLog( @"获取配置appId，appKey出错" );
            break;
        }
        
        id objc =  ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"PPAppPlatformKit"),NSSelectorFromString(@"share"));
        
        if ( !objc ) {
            FKLog( @"PPAppPlatformKit插件加载失败" );
            break;
        }
        
        //是否开启调试日志，可选（默认不开启）
        ((void(*)(id, SEL, BOOL))objc_msgSend)(objc,NSSelectorFromString(@"setIsOpenNSlogData:"),self.debugMode);
        NSLog(@"%@   %@ \n",config.appId, config.appKey);
        m_object_handle = objc;
        
        /**
         *  游戏基本信息（必须设置，且在startPPSDK方法之前设置）
         *
         *  @param delegate SDK代理[强引用]
         *  @param appId    游戏AppId
         *  @param appKey   游戏appKey
         */
        ((id(*)(id, SEL, id,NSInteger,id))objc_msgSend)(objc,
                                                        NSSelectorFromString(@"setupWithDelegate:appId:appKey:"),
                                                        self,
                                                        [config.appId intValue],
                                                        config.appKey);
        //开启SDK加载流程（只允许调用一次,已做限制）
        FKCALL(objc,@"startPPSDK");
    
        m_user = [FKUser new];
        
        //pp有初始化成功回调
        return YES;
    } while (0);
    
    //init platform sdk faird
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"AsPlatformSDK插件初始化失败"];
    }
    
    return NO;
}

- (void)login{
    FKCALL(m_object_handle,@"login");
}

- (FKUser *)getLoginUser{
    return m_user;
}

- (void)logout{
    FKCALL(m_object_handle,@"logout");
}

- (BOOL)isSupportedPlatformCenter{
    return YES;
}

- (void)enterPlatformCenter{
    FKCALL(m_object_handle,@"showSDKCenter");
}

- (BOOL)isSupportedFloatToolBar{
    return NO;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"pp不支持 显示/隐藏浮动工具栏");
}

- (void)accountSwitch{
    FKLog(@"pp没有切换状态的接口,请调用退出，再重新登陆");
}

- (BOOL)isLogined{
    BOOL isLogin = ((int(*)(id, SEL))objc_msgSend)(m_object_handle,NSSelectorFromString(@"loginState"));
    return isLogin;
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    
    /**
     *  兑换道具，账户余额必须大于道具金额，否则失败且无回调
     *
     *  @param paramPrice     商品价格，价格必须大于等于1的int型
     *  @param paramBillNo    商品订单号，订单号长度勿超过30位，无特殊符号
     *  @param paramBillTitle 商品名称
     *  @param paramRoleId    角色id，若无请填写0
     *  @param paramZoneId    开发者中心后台配置的分区id,若无请填写0
     */
    ((id(*)(id, SEL, NSInteger,id,id,id,NSInteger))objc_msgSend)(m_object_handle,
                                                                 NSSelectorFromString(@"exchangeGoods:BillNo:BillTitle:RoleId:ZoneId:"),
                                                                 price,
                                                                 orderNo,
                                                                 name,
                                                                 @"0",
                                                                 0);
    
}

#pragma mark -- 实现协议上代理回调
//插件初始化完成回调
- (void)ppDylibLoadSucceedCallBack{
    if([self.delegate respondsToSelector:@selector(onInitResult:message:)]){
        [self.delegate onInitResult:YES message:@"初始化插件成功"];
    }
}

/**
 *  登录成功后的回调
 */
- (void)ppLoginSuccessCallBack:(NSString *)paramStrToKenKey callBack:(id)block{
    
    if ( paramStrToKenKey ) {
        typeof(self) __weak _self = self;
        //验证渠道登陆
        [self authWithContent:@{@"sid": paramStrToKenKey} callBack:^(BOOL success) {
            if ( success ) {
                
                m_user.channelToken = paramStrToKenKey;
                
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"PP助手用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"PP助手用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"PP助手用户登录失败"];
            }
        }
    }
}

/**
 *  用户中心显示完成回调
 */
- (void)ppCenterDidShowCallBack{
    if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
        [self.delegate onUserActionResult:kPlatformEnter message:@"PP助手用户中心显示完成"];
    }
}

/**
 *  用户中心关闭完成回调
 */
- (void)ppCenterDidCloseCallBack{
    if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
        [self.delegate onUserActionResult:kPlatformBack message:@"PP助手用户中心关闭完成"];
    }
}

/**
 *  注销后回调
 */
- (void)ppLogOffCallBack{
    if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
        [self.delegate onUserActionResult:kLogoutSuccess message:@"pp助手注销成功"];
    }
}

/**
 *  余额充足时直接购买后执行该回调（注意：余额不足时，需充值购买，不执行该回调）
 *
 *  @param paramPPPayResultCode 购买状态码
 */
- (void)ppPayResultCallBack:(PPPayResultCode)resultCode{
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayUnKnow;
        NSString *messgae = @"未知错误";
        switch (resultCode) {
            case PPPayResultCodeSucceed: //购买成功
            {
                code = kPaySuccess;
                messgae = @"购买成功";
            }
                break;
                
            case PPPayResultCodePayAndExchange: //进入充值并兑换流程
            {
                FKLog(@"进入充值并兑换流程");
                messgae = @"进入充值并兑换流程";
                return;
            }
                break;
            case PPPayResultCodeUserOffLine://非法访问，可能用户已经下线
            {
                code = kPayFail;
                messgae = @"非法访问，可能用户已经下线";
            }
                break;
            case PPPayResultCodeForbidden://禁止访问
            {
                code = kPayFail;
                messgae = @"禁止访问";
            }
                break;
            case PPPayResultCodeUserNotExist://该用户不存在
            {
                code = kPayFail;
                messgae = @"该用户不存在";
            }
                break;

            case PPPayResultCodeParamLost://必选参数丢失
            {
                code = kPayFail;
                messgae = @"必选参数丢失";
            }
                break;

            case PPPayResultCodeNotSufficientFunds://PP币余额不足
            {
                code = kPayFail;
                messgae = @"PP币余额不足";
            }
                break;

            case PPPayResultCodeGameDataNotExist://该游戏数据不存在
            {
                code = kPayFail;
                messgae = @"该游戏数据不存在";
            }
                break;

            case PPPayResultCodeDeveloperNotExist://开发者数据不存在
            {
                code = kPayFail;
                messgae = @"开发者数据不存在";
            }
                break;

            case PPPayResultCodeZoneNotExist://该区数据不存在
            {
                code = kPayFail;
                messgae = @"该区数据不存在";
            }
                break;

            case PPPayResultCodeSystemError://系统错误
            {
                code = kPayFail;
                messgae = @"系统错误";
            }
                break;

            case PPPayResultCodeFail://购买失败
            {
                code = kPayFail;
                messgae = @"购买失败";
            }
                break;
            case PPPayResultCodeCommunicationFail://与开发商服务器通信失败，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602
            {
                code = kPayFail;
                messgae = @"与开发商服务器通信失败，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602";
            }
                break;
            case PPPayResultCodeUntreatedBillNo:// 开发商服务器未成功处理该订单，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602
            {
                code = kPayFail;
                messgae = @"开发商服务器未成功处理该订单，如果长时间未收到商品请联系PP客服：电话：020-38276673　 QQ：800055602";
            }
                break;

            case PPPayResultCodeCancel://用户取消
            {
                code = kPayCancel;
                messgae = @"用户中途取消";
            }
                break;
            case PPPayResultCodeAccountIsLocked:// 您的账户存在异常，PP币余额无法正常使用，建议您联系PP客服，电话：020-38276673，QQ：800055602
            {
                code = kPayFail;
                messgae = @"您的账户存在异常，PP币余额无法正常使用，建议您联系PP客服，电话：020-38276673，QQ：800055602";

            }
                break;
            default:
                
                break;
        }
        
        //noti
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:code message:messgae];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    /**
     *  处理支付宝客户端唤回后的回调数据
     *  处理支付宝客户端通过URL启动App时传递的数据,需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
     *  需同时在URLTypes里面添加urlscheme 为teiron + AppId,
     *
     *  @param paramURL 启动App的URL
     */
    if ([url.host isEqualToString:@"safepay"]) {
        ((void(*)(id, SEL, id))objc_msgSend)(m_object_handle, NSSelectorFromString(@"alixPayResult:"), url);
    }
    return YES;
    

}


@end
