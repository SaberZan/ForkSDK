//
//  TbGameHelp.m
//  ForSDK_TEST
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "TbGameHelp.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "FKAspects.h"
#import "FKUser.h"
#import "FKNetHelp.h"
#import "FKMacro.h"
#import "ForkSDK.h"
#import "FKDataManager.h"

extern NSString * const TBLeavedPlatformOrderKey; /*离开平台时UserInfo字典中充值订单Key*/
#define FKTBInitDidFinishNotify @"kTBInitDidFinishNotify"/* 初始化完毕时发出的通知 */
#define FKTBLoginNotification @"kTBLoginNotification"   /* 登录完成的通知(登录成功后发出) */
#define FKTBPlatformLeavedNotification @"TBPlatformLeavedNotification" /* 离开平台界面时，会发送该通知 */
#define FKTBPlatformLogoutNotification @"TBPlatformLogoutNotification"  /* 用户注销通知*/
#define FKTBKeyOfLeavingTypeKey @"TBKeyOfLeavingType"/*离开平台时UserInfo字典中离开类型Key*/
#define FKTBLeavedPlatformOrderKey @"TBKeyOfLeavingOrder"/*离开平台时UserInfo字典中充值订单Key*/


/**
 *	离开平台的类型
 */
typedef enum{
    TBPlatformLeavedDefault = 0,    /* 离开未知平台（预留状态）*/
    TBPlatformLeavedFromLogin,      /* 离开注册、登录页面 */
    TBPlatformLeavedFromUserCenter, /* 包括个人中心、游戏推荐、论坛 */
    TBPlatformLeavedFromUserPay,    /* 离开充值页（包括成功、失败）*/
}TBPlatformLeavedType;

@interface TbGameHelp (){
    @private
    id m_plat_obj;
    FKUser* m_user;
    BOOL m_isLogined;
}
@end

@implementation TbGameHelp
- (BOOL)initializationPlatform{
    //    FKLog(@"%@",TBLeavedPlatformTypeKey);
    /*初始化结束通知，登录等操作务必在收到该通知后调用！！*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitFinished)
                                                 name:FKTBInitDidFinishNotify
                                               object:Nil];
    /*登录成功通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginFinished)
                                                 name:FKTBLoginNotification
                                               object:nil];
    /*注销通知（个人中心页面的注销也会触发该通知，注意处理*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogout)
                                                 name:FKTBPlatformLogoutNotification
                                               object:nil];
    /*离开平台通知（包括登录页面、个人中心页面、web充值页等*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leavedSDKPlatform:)
                                                 name:FKTBPlatformLeavedNotification
                                               object:nil];
    
    do {
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        if ( config.appId<=0 ) {
            FKLog( @"获取配置appId出错" );
            break;
        }
        
        m_user = [FKUser new];
        m_plat_obj = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"TBPlatform"), NSSelectorFromString(@"defaultPlatform"));
        
        if ( !m_plat_obj ) {
            FKLog( @"TBPlatform插件加载失败！" );
            break;
        }
        
        ((void(*)(id, SEL, int, int, BOOL))objc_msgSend)(m_plat_obj,NSSelectorFromString(@"TBInitPlatformWithAppID:screenOrientation:isContinueWhenCheckUpdateFailed:")
                                                         ,[config.appId intValue]
                                                         ,UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown|UIInterfaceOrientationLandscapeRight
                                                         ,NO);
        
        return YES;
        
    } while (0);
    
    //init platform sdk faird
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"同步助手插件初始化失败"];
    }

    return NO;
    
}

#pragma mark - protocol
- (void)login{
//     [[TBPlatform defaultPlatform] TBLogin:0];
     FKCALL_Int(m_plat_obj,@"TBLogin:",0);
}

- (FKUser *)getLoginUser{
    return m_user;
}

- (void)logout{
    FKCALL_Int(m_plat_obj,@"TBLogout:",0);
}

- (BOOL)isSupportedPlatformCenter{
    return YES;
}

- (void)enterPlatformCenter{
    FKCALL_Int(m_plat_obj,@"TBEnterUserCenter:",0);
//   - (void)TBEnterUserCenter:(int)nFlag;
}

- (BOOL)isSupportedFloatToolBar{
    return YES;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    if(isShow){
//        - (void)TBShowToolBar:(TBToolBarPlace)place isUseOldPlace:(BOOL)isUseOldPlace;
        ((void(*)(id, SEL, int, BOOL))objc_msgSend)(m_plat_obj
                                                    ,NSSelectorFromString(@"TBShowToolBar:isUseOldPlace:")
                                                    ,3
                                                    ,YES);
    }else{
        FKCALL(m_plat_obj, @"TBHideToolBar");
    }
}

- (void)accountSwitch{
    FKCALL(m_plat_obj, @"TBSwitchAccount");
}

- (BOOL)isLogined{
    return ((BOOL(*)(id, SEL))objc_msgSend)(m_plat_obj,NSSelectorFromString(@"TBIsLogined"));
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    
    /**
     *  进行虚拟币充值或商品购买（需登录，同步后台记录充值账号记录）
     *
     *  @param orderSerial     合作商订单号，必须保证唯一，双方对帐的唯一标记(最大长度255)
     *
     *  @param needPayRMB      需要支付的金额，单位：元（大于0，否则进入自选金额界面）
     *
     *  @param payDescription  支付描述，发送支付成功通知时，返回给开发者(不能包含中文，最大长度255)
     *
     *  @param delegate        回调对象，见TBBuyGoodsProtocol协议
     *
     *  @result 错误码
     */
    ((void(*)(id, SEL, id, NSInteger, id, id))objc_msgSend)(m_plat_obj
                                                      , NSSelectorFromString(@"TBUniPayForCoin:needPayRMB:payDescription:delegate:")
                                                      , orderNo
                                                      , price
                                                      , name
                                                      , self);
    

    ;
    
}


#pragma mark -- 实现协议上代理回调
/**
 *  SDK初始化结束通知（登录等操作务必放到初始化完成的通知里！！！！）
 */
- (void)sdkInitFinished{
    if([self.delegate respondsToSelector:@selector(onInitResult:message:)]){
        [self.delegate onInitResult:YES message:@"TBGame初始化插件成功！"];
    }
}

/**
 *  离开平台
 */
- (void)leavedSDKPlatform:(NSNotification *)notification{
    NSDictionary *notifyUserInfo = notification.userInfo;
    TBPlatformLeavedType leavedFromType = (TBPlatformLeavedType)[[notifyUserInfo objectForKey:
                                                                  FKTBKeyOfLeavingTypeKey] intValue];
    switch (leavedFromType) {
            //从登录页离开
        case TBPlatformLeavedFromLogin:{
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kPlatformBack message:@"从登录页离开平台"];
            }
        }
            break;
            /* 包括个人中心、游戏推荐、论坛 */
        case TBPlatformLeavedFromUserCenter:{
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kPlatformBack message:@"包括个人中心、游戏推荐、论坛离开平台"];
            }
        }
            break;
            ///* 离开充值页（包括成功、失败）*/
        case TBPlatformLeavedFromUserPay:{
            //查询订单是否成功
            
            NSString *orderNo = notifyUserInfo[ FKTBLeavedPlatformOrderKey ];
            /**
             *  查询支付是成功
             *
             *  @param strCooOrderSerial	支付订单号
             *
             *  @param delegate	    	回调对象，回调接口参见 TBPayDelegate
             *
             *  @result 错误码
             */
//            - (int)TBCheckPaySuccess:(NSString*)strCooOrderSerial
//        delegate:(id<TBCheckOrderDelegate>)delegate;
            
            ((int(*)(id, SEL, id, id))objc_msgSend)(m_plat_obj, NSSelectorFromString(@"TBCheckPaySuccess:delegate:")
                                                                    , orderNo
                                                                    , self);
        }
            break;
        default:
            break;
    }
}

/**
 *  登录结束通知
 */
- (void)loginFinished{
//    m_user.token = paramStrToKenKey;
//    TBPlatformUserInfo
    
    m_user.channelUserId = ((id(*)(id, SEL))objc_msgSend)(m_plat_obj, NSSelectorFromString(@"userID"));
    m_user.channelUserName = ((id(*)(id, SEL))objc_msgSend)(m_plat_obj, NSSelectorFromString(@"nickName"));
    m_user.channelToken = ((id(*)(id, SEL))objc_msgSend)(m_plat_obj, NSSelectorFromString(@"sessionID"));
    
    [self showOrHideFloatToolBar:YES];
    
    if ( m_user.channelToken ) {
        
        typeof(self) __weak _self = self;
        //验证渠道登陆
        [self authWithContent:@{@"session": m_user.channelToken, @"username":m_user.channelUserName?m_user.channelUserName:@""} callBack:^(BOOL success) {
            if ( success ) {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"同步助手用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"同步助手用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"同步助手用户登录失败"];
            }
        }
    }
}

/**
 *  注销通知
 */
- (void)didLogout{
    m_user = [FKUser new];
    
    [self showOrHideFloatToolBar:NO];
    if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
        [self.delegate onUserActionResult:kLogoutSuccess message:@"TB助手注销成功"];
    }

    
}
/**
 *	使用推币直接购买商品成功
 *
 *	@param 	order 	订单号
 */
- (void)TBBuyGoodsDidSuccessWithOrder:(NSString*)order{
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPaySuccess;
        NSString *messgae = @"支付成功";
        
        [self.delegate onPayResult:code message:messgae];
    }
}

/**
 *	使用推币直接购买商品失败
 *
 *	@param 	order      订单号
 *	@param 	errorType  错误类型，见TB_BUYGOODS_ERROR
 */
- (void)TBBuyGoodsDidFailedWithOrder:(NSString *)order resultCode:(int)errorType{
    
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayFail;
        NSString *messgae = @"支付失败";
        
        [self.delegate onPayResult:code message:messgae];
    }

}

/**
 *	推币余额不足，进入充值页面（开发者需要手动查询订单以获取充值购买结果）
 *
 *	@param 	order 	订单号
 */
- (void)TBBuyGoodsDidStartRechargeWithOrder:(NSString*)order{
    
}

/**
 *  跳提示框时，用户取消
 *
 *	@param	order	订单号
 */
- (void)TBBuyGoodsDidCancelByUser:(NSString *)order{
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayCancel;
        NSString *messgae = @"支付取消";
        [self.delegate onPayResult:code message:messgae];
        
    }

}


/**
 *  手动查询充值结果回调协议
 */
//@protocol TBCheckOrderDelegate <NSObject>
//
//@optional

/**
 *  查询订单结束
 *
 *  @param orderString 订单号
 *  @param amount      订单金额（单位：分）
 *  @param statusType  订单状态（详细说明见TBCheckOrderStatusType定义）
 */
- (void)TBCheckOrderFinishedWithOrder:(NSString *)orderString
                               amount:(int)amount
                               status:(NSInteger)statusType{
    enum{
        
        TBCheckOrderStatusWaitingForPay = 0, /* 待支付（已经创建第三方充值订单，但未支付）*/
        
        TBCheckOrderStatusPaying        = 1, /* 充值中（用户支付成功，正在通知开发者服务器，未收到处理结果）*/
        
        TBCheckOrderStatusFailed        = 2, /* 失败 */
        
        TBCheckOrderStatusSuccess       = 3, /* 成功（通知开发者服务器并收到处理成功结果，充值完毕））*/
        
    };
    
    PayResultCode code = kPayUnKnow;
    NSString *messgae = @"支付失败，未知错误";
    switch (statusType) {
        case TBCheckOrderStatusSuccess:
            code = kPaySuccess;
            messgae = @"支付成功";
            break;
        case TBCheckOrderStatusWaitingForPay:
            code = kPayCancel;
            messgae = @"待支付（已经创建第三方充值订单，但未支付）";
            break;
        case TBCheckOrderStatusFailed:
            code = kPayFail;
            messgae = @"支付失败";
            break;
        case TBCheckOrderStatusPaying:
            code = kPaySuccess;
            messgae = @"充值中（用户支付成功，正在通知开发者服务器，未收到处理结果）";
            break;
        default:
            break;
    }

    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        [self.delegate onPayResult:code message:messgae];
    }
}
/**
 *  查询订单失败（网络不通畅，或服务器返回错误）
 */
- (void)TBCheckOrderDidFailed:(NSString*)order{
    if([self.delegate respondsToSelector:@selector(onPayResult:message:)]){
        PayResultCode code = kPayNetworkError;
        NSString *messgae = @"支付网络错误";
        [self.delegate onPayResult:code message:messgae];
    }
}

@end
