//
//  XYHelp.m
//  ForSDK_TEST
//
//  Created by apple on 15/7/20.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "XYHelp.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>
#import "FKAspects.h"
#import "FKUser.h"
#import "FKNetHelp.h"
#import "FKMacro.h"
#import "ForkSDK.h"
#import "FKDataManager.h"

@interface XYHelp (){
    @private
    id          m_pInstance;
    FKUser      *m_pUser;
    BOOL        m_bLogined;
}
@end

@implementation XYHelp

- (BOOL)initializationPlatform{
    do {
        m_pUser = [FKUser new];
        
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
        
        //init platform sdk
        m_pInstance = ((id(*)(id, SEL))objc_msgSend)( NSClassFromString(@"SuspendedButton"),NSSelectorFromString(@"sharedSuspendedButton"));
        if ( !m_pInstance ) {
            FKLog(@"SuspendedButton类初始化失败");
            break;
        }
        
        //init platform sdk success
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
            [self.delegate onInitResult:YES message:@"XYGame插件初始化成功"];
        }
        
        return YES;
    } while (0);
    
    //init platform sdk faird
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"XYGame插件初始化失败"];
    }
    
    return NO;
}

#pragma mark - protocol
- (void)login{
    //config
    FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
    //set appId appKey delegate
    ((void(*)(id, SEL, id, id, id))objc_msgSend)(m_pInstance, NSSelectorFromString(@"setAppId:appKey:delegate:"), config.appId, config.appKey, self);
    
    //set test with debug mode
    ((void(*)(id, SEL, BOOL))objc_msgSend)(m_pInstance, NSSelectorFromString(@"setTest:"), self.debugMode);
}

- (FKUser *)getLoginUser{
    return m_pUser;
}

- (void)logout{
    ((void(*)(id, SEL))objc_msgSend)(m_pInstance, NSSelectorFromString(@"cleanupUserData"));
}

- (BOOL)isSupportedPlatformCenter{
    return NO;
}

- (void)enterPlatformCenter{
    FKLog(@"XYGame不支持控制进入平台中心");
}

- (BOOL)isSupportedFloatToolBar{
    return NO;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"不支持隐藏浮动工具栏");
}

- (void)accountSwitch{
    FKLog(@"不支持代码控制切换账号");
}

- (BOOL)isLogined{
    return m_pUser.channelToken && m_pUser.channelUserName;
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{

    //config
    FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
    
    //instance spm
    id pay = ((id(*)(id, SEL))objc_msgSend)( NSClassFromString(@"PayManager"), NSSelectorFromString(@"spm") );
    //set delegate
    ((void(*)(id, SEL, id))objc_msgSend)( pay, NSSelectorFromString(@"setDelegate:"), self );
    
    //pay //TODO:
    ((void(*)(id, SEL, id, id, id, id, id, id, id, id, id))objc_msgSend)( pay,
                                                                         NSSelectorFromString(@"setProductOrderNo:productId:productInfo:productNum:productPrice:note:state:burl:appScheme:"),
                                                                         orderNo,
                                                                         orderNo,
                                                                         name,
                                                                         @"1",
                                                                         [NSString stringWithFormat:@"%ld",price],
                                                                         name,
                                                                         @"1",
                                                                         config.callBackUrl,
                                                                         [FKDataManager getSchemes]);
}

#pragma mark -- imp platform login delegate
- (void)requestFinished:(NSString *)username sessionid:(NSString *)sessionid{
    
    if ( sessionid ) {
        typeof(self) __weak _self = self;
        NSString* uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //验证渠道登陆
        [self authWithContent:@{@"sessionid": sessionid, @"uin":username, @"uuid":uuid} callBack:^(BOOL success) {
            if ( success ) {
                
                m_pUser.channelUserName = username;
                m_pUser.channelToken = sessionid;
                
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"XYGame用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"XYGame用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"XYGame用户登录失败"];
            }
        }
    }
}

- (void)cancelLogin{
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLoginCancel message:@"XYGame用户已经取消登录"];
        }
    }
}

#pragma mark -- imp platform pay delegate

//支付结束，YES为成功完成支付，NO为支付失败或用户手动取消
- (void)finishedPay:(BOOL)isSuccess{
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            
            if ( isSuccess ) {
                [self.delegate onPayResult:kPaySuccess
                                   message:@"XYGame支付成功"];
            }
            else{
                [self.delegate onPayResult:kPayFail
                                   message:@"XYGame支付失败"];
            }
        }
    }
}

- (void)appstorePay{
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            
            [self.delegate onPayResult:kPayUnKnow
                                   message:@"XYGame支付检测失败，未知原因"];
        }
    }
}

#pragma mark -- imp application delegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        
        //alipay noti
        id alipay = ((id(*)(id, SEL))objc_msgSend)( NSClassFromString(@"AlipaySDK"), NSSelectorFromString(@"defaultService") );
        //set delegate
        ((void(*)(id, SEL, id, id))objc_msgSend)( alipay, NSSelectorFromString(@"processOrderWithPaymentResult:standbyCallback:"), url, ^(NSDictionary *resultDic) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AlipayCallback"
                                                                object:[resultDic
                                                                        objectForKey:@"resultStatus"]];
        } );
        
    }
    
    return YES;
}

@end
