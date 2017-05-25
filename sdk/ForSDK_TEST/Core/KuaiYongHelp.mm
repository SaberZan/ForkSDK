//
//  ItoolsHelp.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "KuaiYongHelp.h"
#import "FKMacro.h"
#import "FKUser.h"
#import "FKDataManager.h"
#import "ForkSDK.h"
#import <UIKit/UIKit.h>

@interface KuaiYongHelp (){
    @private
    id m_Instance;
    FKUser *m_user;
}
@end

@implementation KuaiYongHelp

- (BOOL)initializationPlatform{
    do {
        
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        if ( !config.appKey ) {
            FKLog( @"获取配置appKey出错" );
            break;
        }
        
        Class cXSDK = NSClassFromString(@"XSDK");
        
        if ( !cXSDK ) {
            FKLog( @"XSDK插件加载失败" );
            break;
        }
        
        m_Instance = ((id(*)(id, SEL))objc_msgSend)(cXSDK, NSSelectorFromString(@"instanceXSDK"));
        
        /**
         * 设置appKey
         * @param appKey
         * 游戏开发商添加游戏后获得的appKey
         **/
        ((void(*)(id, SEL, id))objc_msgSend)(m_Instance, NSSelectorFromString(@"setAppKey:"), config.appKey);
        NSLog(@"appid:%@  appkey:%@ \n",config.appId,config.appKey);
        /**
         * 设置是否只支持iphone
         **/
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_Instance, NSSelectorFromString(@"setOnlySupportIPhone:"), NO);
        /**
         * 设置是否只支持游戏账号登陆（默认不支持）
         **/
        ((void(*)(id, SEL, BOOL))objc_msgSend)(m_Instance, NSSelectorFromString(@"setISSupportGameNo:"), YES);
        /**
         * 初始化数据，检查更新
         **/
        ((void(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"checkUpdate"));
        ((void(*)(id, SEL, id))objc_msgSend)(m_Instance, NSSelectorFromString(@"setXsdkDelegate:"), self);

        //init user instance
        m_user = [FKUser new];
        
        //平台有初始化回调
        return YES;
        
    } while (0);
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:NO message:@"快用插件初始化失败"];
    }
    
    return NO;
}

#pragma mark - FKProtocol

- (void)login{
    FKCALL(m_Instance, @"login");
}

- (BOOL)isLogined{
    return (m_user.channelToken && m_user.channelToken.length>0);
}

- (FKUser *)getLoginUser{
    return m_user;
}

- (void)logout{
    FKCALL(m_Instance, @"logout");
}

- (BOOL)isSupportedPlatformCenter{
    return NO;
}

- (void)enterPlatformCenter{
    FKLog(@"快用不支持代码进入用户中心 \n");
}

- (BOOL)isSupportedFloatToolBar{
    return NO;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"快用不支持代码控制浮标 \n");
}

- (void)accountSwitch{
    [self logout];
    [self login];
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    //支付
    ((id(*)(id, SEL, id,id,id,id,id))objc_msgSend)(m_Instance
                                                   ,NSSelectorFromString(@"payWithDealSeq:andFee:andPayID:andGamesvr:andSubject:")
                                                   ,orderNo
                                                   ,[NSString stringWithFormat:@"%zd",price]
                                                   ,[FKDataManager getInstance].config.channelConfig.appId
                                                   ,name
                                                   ,name
);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    return (bool)((id(*)(id, SEL, id, id, id, id))objc_msgSend)(m_Instance,NSSelectorFromString(@"handleApplication:openURL:sourceApplication:annotation:")
                        ,application
                        ,url
                        ,sourceApplication
                        ,annotation);
}

#pragma mark - XS FKProtocol
/**
 *  @method-(void)XSDKinitCallBack
 *  游戏初始化结束后回调
 **/
-(void)XSDKCheckUpdateCallBack{
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"快用插件初始化成功"];
    }
}

/**
 *  @method-(void)XSDKloginCallBack:(NSString *)tokenKey
 *  用户登录回调
 *  @param  tokenKey
 **/
-(void)XSDKLoginCallBack:(NSString *)tokenKey{
    if ( tokenKey ) {
        typeof(self) __weak _self = self;
        //验证渠道登陆
        [self authWithContent:@{@"tokenKey": tokenKey} callBack:^(BOOL success) {
            if ( success ) {
                m_user.channelToken = tokenKey;
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginSuccess message:@"快用用户登录成功"];
                    }
                }
            }
            else
            {
                //noti
                if ( _self.delegate ) {
                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                        [_self.delegate onUserActionResult:kLoginFail message:@"快用用户登录失败，Token验证失败！"];
                    }
                }
            }
        }];
        
    }
    else{
        if ( self.delegate ) {
            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                [self.delegate onUserActionResult:kLoginFail message:@"快用用户登录失败"];
            }
        }
    }
}

/**
 *  @method-(void)XSDKLogOutCallBack:(NSString *)guid type:(XSDKLOGOUTTYPE)type
 *  注销方法回调
 *  @param  guid
 *  @param  type
 **/
-(void)XSDKLogOutCallBack:(NSString *)guid type:(int)type{
    FKLog(@"XSDKLogOutCallBack \n");
    
    FKCALL(m_user, @"reset");
    
    NSString *msg = @"个人中心内，退出时回调";
    if ( 1==type ) {
        msg = @"XSDKLogout接口调用时回调";
    }
    
    //noti
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLoginSuccess
                                      message:msg];
        }
    }
}

/**
 *  @methodXSDKGameLoginCallback:(NSString *)username password:(NSString *)password resultBlock:(void (^)(NSString * type))resultBlock
 *  游戏账号登陆回调
 **/
-(void)XSDKGameLoginCallback:(NSString *)username password:(NSString *)password resultBlock:(void (^)(NSString * typeMessage))resultBlock{
    FKLog(@"不支持 \n");
}

/**
 *游戏账号登陆成功回调
 **/
-(void)XSDKGameLoginSuc{
    FKLog(@"不支持 \n");
}

/**
 *  @method-(void)XSDKChangeSubNOCallBack:(NSString *)oldGuid newTokenKey:(NSString *)newTokenKey
 *  切换子账号回调
 **/
-(void)XSDKChangeSubNOCallBack:(NSString *)oldGuid newTokenKey:(NSString *)newTokenKey{
    //验证登陆
    [self XSDKLoginCallBack:newTokenKey];
}

/**
 *  @method - (void)XSDKPayCallback
 *  支付回调
 *  @param isUnfinished
 *  客户端获得的支付结果，CP客户端应在收到此回调后发起服务器验证，获得最终结果
 */
-(void)XSDKPayCallback:(BOOL)isClientSuccess{
    if ( isClientSuccess ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:kPaySuccess message:@"支付成功"];
        }
    }
    else{
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:kPayFail message:@"支付失败"];
        }
    }
}

@end


