//
//  Baidu91Help.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "Baidu91Help.h"
#import "ForkSDK.h"
#import "FKAspects.h"
#import "FKUser.h"
#import "FKNetHelp.h"
#import <UIKit/UIKit.h>
#import "FKDataManager.h"
#import "FKConfig.h"

@interface Baidu91Help (){
@private
    FKUser* m_user;
    id m_Instance;
}
@end

@implementation Baidu91Help

- (BOOL)initializationPlatform{
    do {
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        Class cBDGameSDK = NSClassFromString(@"BDGameSDK");
        m_Instance = cBDGameSDK;
        
        if ( !cBDGameSDK ) {
            FKLog(@"插件BDGameSDK初始化失败！");
            break;
        }
        
        id configuration = ((id(*)(id, SEL, NSString *,NSString *,int,int))objc_msgSend)(cBDGameSDK,
                                                            NSSelectorFromString(@"configurationWithAppId:appKey:domain:distributedPlatform:")
                                                                 ,config.appId
                                                                 ,config.appKey
                                                                 ,0
                                                                 ,0);
        if ( !configuration ) {
            FKLog(@"插件BDGameSDK初始化失败！");
            break;
        }
        
        FKCALL2(cBDGameSDK,@"initGameSDKWith:completion:",configuration,^(BOOL success) {
            NSLog(@"game sdk initial completion = %d", success);
        });
        
        m_user = [FKUser new];
        
        FKCALL1(cBDGameSDK,@"setLoginedUserDidChangeOperation:",(^(int changedType) {
            
            FKLog( @"setLoginedUserDidChangeOperation  %d\n",changedType );
            
            UserActionResultCode resultCode = (UserActionResultCode)-1;
            NSString *msg = @"未知错误";
            
            switch (changedType) {
                case 1:{
                    
                    resultCode = kLoginSuccess;
                    msg = @"登陆成功";
                    m_user.channelUserId = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginUid"));
                    m_user.channelToken = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginAccessToken"));
                    
                    if ( m_user.channelToken && m_user.channelUserId ) {
                        typeof(self) __weak _self = self;
                        //验证渠道登陆
                        [self authWithContent:@{@"token":m_user.channelToken,@"uid":m_user.channelUserId} callBack:^(BOOL success) {
                            if ( success ) {
                                
                                //noti
                                if ( _self.delegate ) {
                                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                                        [_self.delegate onUserActionResult:kLoginSuccess message:@"百度用户登录成功"];
                                    }
                                }
                            }
                            else
                            {
                                //noti
                                if ( _self.delegate ) {
                                    if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                                        [_self.delegate onUserActionResult:kLoginFail message:@"百度用户登录失败，Token验证失败！"];
                                    }
                                }
                            }
                        }];
                        
                    }
                    else{
                        if ( self.delegate ) {
                            if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                                [self.delegate onUserActionResult:kLoginFail message:@"百度用户登录失败"];
                            }
                        }
                    }
            
                    
                }
                case 3:{
                    //用户重新登录了，产生了新的token
                    resultCode = kLoginSuccess;
                    msg = @"用户重新登录了，产生了新的token";
                    
                    NSString *uid = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginUid"));
                    m_user.channelUserId = uid;
                    m_user.channelToken = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginAccessToken"));
                }
                case 4:
                {
                    //用户切换账号了，新的uid
                    resultCode = kLoginSuccess;
                    msg = @"用户切换账号了，新的uid";
                    
                    NSString *uid = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginUid"));
                    m_user.channelUserId = uid;
                    m_user.channelToken = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginAccessToken"));
                }
                    break;
                case 2:{
                    //用户注销了
                    m_user = nil;
                    resultCode = kLogoutSuccess;
                    msg = @"用户注销了";
                }
                case 5:
                {
                    //用户长时间未操作，token超时失效了
                    resultCode = kLoginFail;
                    msg = @"用户长时间未操作，token超时失效了";
                }
                    break;
                default:
                    break;
            }
            
            //noti
            if ( self.delegate ) {
                if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                    [self.delegate onUserActionResult:resultCode message:msg];
                }
            }
            
        }));
        
        //init ok noti
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
            [self.delegate onInitResult:YES
                                message:@"NdComPlatform插件初始化成功"];
        }
        
        return YES;
        
    } while (0);
    
    //init noti
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:NO
                            message:@"NdComPlatform插件初始化失败"];
    }
    
    return NO;
}

-(void)login{
    
    BOOL isLogined = ((BOOL(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"isLogined"));
    if (isLogined) {
        FKCALL(m_Instance, @"logout");
    }
    
    FKCALL1(m_Instance, @"loginWithCompletion:",^(BOOL didLogin, NSString *loginUid) {
        FKLog( @"用户登陆成功  %@\n",loginUid );
        if ( didLogin ) {
            m_user.channelUserId = loginUid ;
            m_user.channelToken = ((id(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"loginAccessToken"));
        }
    });
}

- (BOOL)isLogin{
    return ((BOOL(*)(id, SEL))objc_msgSend)(m_Instance, NSSelectorFromString(@"isLogined"));
}

- (FKUser *)getLoginUser{
    return m_user;
}

-(void)logout{
    FKCALL(m_Instance, @"logout");
}

- (BOOL)isSupportedPlatformCenter{
    return NO;
}

- (void)enterPlatformCenter{
    FKLog(@"百度不支持代码控制进入平台中心");
}

- (BOOL)isSupportedFloatToolBar{
    return NO;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    FKLog(@"百度不支持代码控制显示隐藏浮标");
}

- (void)accountSwitch{
    [self login];
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    //构建支付信息
    id pBDGSDKPayOrderInfo = ((id(*)(id, SEL, id,id,NSInteger,id))objc_msgSend)(m_Instance, NSSelectorFromString(@"orderInfoWithCooOrderSerial:productName:totalPriceCent:extInfo:")
                                    ,orderNo
                                    ,name
                                    ,price*100
                                    ,name);
    
    //支付
    FKCALL3(m_Instance, @"payWithInfo:serverNotifyUrl:completion:"
           ,pBDGSDKPayOrderInfo
           ,nil/*callback url*/
           ,^(NSError* error, int payResult){
               
               NSString *msg = @"未知结果";
               PayResultCode payCode = kPayUnKnow;
               
               //成功
               if ( 2==payResult ) {
                   payCode = kPaySuccess;
                   msg = @"支付成功";
               }
               else if ( 0==payResult ){
                   payCode = kPayCancel;
                   msg = @"支付已取消";
               }
               else if ( 3==payResult ){
                   payCode = kPayFail;
                   msg = @"支付失败";
               }
               else if ( 1==payResult ){
                   payCode = kPayUnKnow;
                   msg = @"支付订单已提交，结果未知";
               }
               
               //noti
               if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
                   [self.delegate onPayResult:payCode message:msg];
               }
           
           });
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return ((BOOL(*)(id, SEL,id url,id so,id an))objc_msgSend)(NSClassFromString(@"BDGameSDK"), NSSelectorFromString(@"applicationOpernUrl:withSourceApplication:annotation:"), url, sourceApplication,annotation);
}

@end
