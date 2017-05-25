//
//  ItoolsHelp.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "ItoolsHelp.h"
#import "FKMacro.h"
#import "FKAspects.h"
#import "FKUser.h"
#import "FKNetHelp.h"
#import "FKDataManager.h"
#import "ForkSDK.h"
#import <UIKit/UIKit.h>


/*用户注册完成的通知
 */
#define HX_NOTIFICATION_REGISTER_ @"HX_NOTIFICATION_REGISTER"
/*用户登录成功的通知，用户自动登录后亦会发此通知
 */
#define HX_NOTIFICATION_LOGIN_ @"HX_NOTIFICATION_LOGIN"
/*用户注销的通知
 */
#define HX_NOTIFICATION_LOGOUT_ @"HX_NOTIFICATION_LOGOUT"
/*SDK界面关闭的通知
 */
#define HX_NOTIFICATION_CLOSEVIEW_ @"HX_NOTIFICATION_CLOSEVIEW"
/*V1.5新增 SDK界面在接入充值界面后，用户选择右上角关闭视图后会先触发HX_NOTIFICATION_CLOSEVIEW的通知，接着会触发以下支付界面关闭的通知
 */
#define HX_NOTIFICATION_CLOSE_PAYVIEW_ @"HX_NOTIFICATION_CLOSE_PAYVIEW"
/*V1.7 app有可更新的通知
 */
#define HX_NOTIFICATION_UPDATE_APP_ @"HX_NOTIFICATION_UPDATE_APP"
/*V2.1.0 钱包支付不成功的通知,包含钱包支付失败(余额充足时)以及用户手选 “否” 两种情况
 */
#define HX_NOTIFICATION_WALLET_PAY_FAILED_ @"HX_NOTIFICATION_WALLET_PAY_FAILED"

@interface ItoolsHelp (){
    @private
    Class m_platform_class;
    FKUser* m_user;
}
@end

@implementation ItoolsHelp

- (BOOL)initializationPlatform{
    do {
        //config
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        if ( config.appId<=0 || !config.appKey ) {
            FKLog( @"获取配置appId，appKey出错" );
            break;
        }
        
        //get platform class
        m_platform_class = NSClassFromString(@"HXAppPlatformKitPro");
        
        if ( !m_platform_class ) {
            FKLog( @"HXAppPlatformKitPro插件加载失败" );
            break;
        }
        
        //设置充值平台分配的appid和appkey
        ((void(*)(id, SEL, int, id))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setAppId:appKey:")
                                                  ,config.appId.intValue
                                                  ,config.appKey);
        
        /*! 设置视图支持的旋转方向
         * \param   portrait  为YES时支持默认竖屏方向,NO时不支持
         * \param   portraitUpsideDown   为YES时支持向下竖屏方向,NO时不支持
         * \param   landscapeLeft   为YES时支持向左横屏屏方向,NO时不支持
         * \param   landscapeRight  为YES时支持向右横屏屏方向,NO时不支持
         */
        SEL sel = NSSelectorFromString(@"setSupportOrientationPortrait:portraitUpsideDown:landscapeLeft:landscapeRight:");
        ((void(*)(id, SEL, BOOL, BOOL, BOOL, BOOL))objc_msgSend)(m_platform_class,sel
                                                                 ,YES
                                                                 ,NO
                                                                 ,YES
                                                                 ,YES);
        
        /*! 设置登录窗口是否可以被关闭
         * \param   enabled 为YES时,登录窗口可被关闭,NO时不允许关闭,此值默认为YES(可以被关闭), 如果不允许关闭登录窗口, 请设置为NO
         */
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setLoginViewClosedEnabled:")
                                               ,NO);
        /*! 设置游戏是否支持自动登录
         * \param   enabled 为YES时,打开游戏则可自动登录,NO时将弹出登陆视图,此值默认为YES(可以被关闭), 如果不允许自动登录, 请设置为NO
         */
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setSupportAutoLoginEnbled:")
                                               ,YES);
        /*! 设置游戏是否支持SDK浮标
         * \param   enabled 为YES时,游戏支持浮标,NO时不支持,此值默认为YES(可以被关闭), 如果不允许支持浮标, 请设置为NO
         */
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"setSupportSDKAssistiveTouchEnbled:")
                                               ,YES);
        
        /*! 设置SDK assistive touch初始化时的位置
         * \param   place为TSAssistiveTouchViewAtMiddleLeft时，位于屏幕中间左侧
         *          place为TSAssistiveTouchViewAtMiddleRight时，位于屏幕中间右侧
         *          place为TSAssistiveTouchViewAtTopLeft时，位于屏幕左上方
         *          place为TSAssistiveTouchViewAtTopRight时，位于屏幕右上方
         *          place为TSAssistiveTouchViewAtBottomLeft时，位于屏幕左下方
         *          place为TSAssistiveTouchViewAtBottomRight时，位于屏幕右下方
         */
        //+ (void)setSDKAssistiveTouchAtScreenPlace:(TSAssistiveTouchViewPlace)place;
        
        //设置支付宝回调所需的URL Scheme
        FKCALL1(m_platform_class, @"setAlipayURLScheme:",[FKDataManager getSchemes]);
        
        /*用户注册完成的通知
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsRegCallBack:)
                                                     name:HX_NOTIFICATION_REGISTER_
                                                   object:nil];
        
        //用户登录成功的通知，用户自动登录后亦会发此通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsLoginCallBack:)
                                                     name:HX_NOTIFICATION_LOGIN_
                                                   object:nil];
        //用户注销的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsLogoutCallBack:)
                                                     name:HX_NOTIFICATION_LOGOUT_
                                                   object:nil];
        //SDK界面关闭的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsColoseSdkCallBack:)
                                                     name:HX_NOTIFICATION_CLOSEVIEW_
                                                   object:nil];
        /*V1.5新增 SDK界面在接入充值界面后，用户选择右上角关闭视图后会先触发HX_NOTIFICATION_CLOSEVIEW的通知，接着会触发以下支付界面关闭的通知
         */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsColoseSdkPayCallBack:)
                                                     name:HX_NOTIFICATION_CLOSE_PAYVIEW_
                                                   object:nil];
        
        //V2.1.0 钱包支付不成功的通知,包含钱包支付失败(余额充足时)以及用户手选 “否” 两种情况
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itoolsPayFailureCallBack:)
                                                     name:HX_NOTIFICATION_WALLET_PAY_FAILED_
                                                   object:nil];
        
        //init platform sdk success
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
            [self.delegate onInitResult:YES message:@"Itools插件初始化成功"];
        }
        
        return YES;
    } while (0);
    
    //init platform sdk faird
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"Itools插件初始化失败"];
    }
    
    return NO;
}

- (void)login{
    FKCALL(m_platform_class,@"showLoginView");
    
}

- (FKUser *)getLoginUser{
    return m_user;
}

- (void)logout{
    FKCALL(m_platform_class,@"logout");
}

- (BOOL)isSupportedPlatformCenter{
    return YES;
}

- (void)enterPlatformCenter{
    FKCALL(m_platform_class,@"showPlatformView");
}

- (BOOL)isSupportedFloatToolBar{
    return YES;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"itools不支持 显示/隐藏浮动工具栏");
}

- (void)accountSwitch{
   FKLog(@"itools不支持账号切换");
}

- (BOOL)isLogined{
    return m_user.channelToken && m_user.channelUserId;
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    /*! 消费接口，用于在游戏中购买道具
     * \param   productName  道具名称
     * \param   amount  充值金额 (元)
     * \param   orderIdCom  厂商订单号
     */
//    + (void)payProductWithProductName:(NSString*)productName Amount:(float)amount OrderIdCom:(NSString *)orderIdCom;
    FKLog(@"Itools注意:客户端如何确认支付成功？这里需要客户端和游戏服务器做逻辑处理，客户端SDK没有支付成功的回调。一般情况，用户支付成功5分钟内都会到账（平台异步通知到游戏发货服务器），所以客户端在SDK支付页面关闭后可以和游戏服务器做轮询，如果客户端和游戏服务器有TCP长连接的话可以采用服务器推送的的方式。");
    ((void(*)(id, SEL, id, float, id))objc_msgSend)(m_platform_class
                                                    , NSSelectorFromString(@"payProductWithProductName:Amount:OrderIdCom:")
                                                    ,name
                                                    ,price
                                                    ,orderNo);
}

#pragma mark -- 通知
- (void)itoolsRegCallBack:(NSNotification *)noti{
    FKLog(@"注册成功");
}

//登录成功的回调
- (void)itoolsLoginCallBack:(NSNotification *)info{
    NSString *userId = ((id(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"getUserId")) ;
    NSString *userName = ((id(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"getUserName"));
    NSString *sessionid = ((id(*)(id, SEL))objc_msgSend)(m_platform_class, NSSelectorFromString(@"getSessionId"));
    
    if ( sessionid ) {
        typeof(self) __weak _self = self;
        //验证渠道登陆
        [self authWithContent:@{@"sessionid": sessionid} callBack:^(BOOL success) {
            if ( success ) {
                
                m_user.channelUserId = userId;
                m_user.channelUserName = userName;
                m_user.channelToken = sessionid;
                
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"Itools用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"Itools用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"Itools用户登录失败"];
            }
        }
    }
}

//注销成功的回调
- (void)itoolsLogoutCallBack:(NSNotification *)info{
    m_user = [FKUser new];
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLogoutSuccess message:@"itools账户用户注销成功"];
        }
    }
}

//关闭SDK
- (void)itoolsColoseSdkCallBack:(NSNotification *)info{
    FKLog(@"关闭SDK");
}

- (void)itoolsColoseSdkPayCallBack:(NSNotification *)info{
    FKLog(@"关闭SDK");
}

//支付失败的
- (void)itoolsPayFailureCallBack:(NSNotification *)info{
    //noti
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:kPayFail message:@"支付失败（钱包支付不成功的通知,包含钱包支付失败(余额充足时)以及用户手选 “否” 两种情况）"];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    typeof(self) __weak _self = self;
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
       
        id obj = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"AlipaySDK"), NSSelectorFromString(@"defaultService"));
        
        FKCALL2(obj, @"processOrderWithPaymentResult:standbyCallback:", url, ^(NSDictionary *resultDic) {
            NSLog(@"result = %@", resultDic);
            FKCALL1(NSClassFromString(@"HXAppPlatformKitPro"), @"alipayCallBack:", resultDic);
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            int result = [resultStatus intValue];
            [_self checkResultStatus:result];
        });
    }
    return YES;
}

- (void)checkResultStatus:(NSInteger)resultStatus {
    NSString* msg = @"位置错误";
    PayResultCode payState = kPayUnKnow;
    
    switch (resultStatus) {
        case 9000:
            msg = @"支付宝支付成功";
            payState = kPaySuccess;
            break;
        case 6002:
            msg = @"网络错误";
            payState = kPayNetworkError;
            break;
        case 6001:
            msg = @"支付取消";
            payState = kPayCancel;
            break;
        case 4000:
            msg = @"支付失败";
            payState = kPayFail;
            break;
        default:
            break;
    }
    
    //noti
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:payState message:msg];
        }
    }
}

@end
