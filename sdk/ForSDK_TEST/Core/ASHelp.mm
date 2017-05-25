//
//  ASHelp.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "ASHelp.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

#import "ForkSDK.h"
#import "FKDataManager.h"

@interface ASHelp ()<UITextFieldDelegate>{
    @private
    FKUser* m_user;
    id  m_object_handle;
}
@end

@implementation ASHelp

- (BOOL)initializationPlatform{
    /*
     * 设置爱思平台的初始化参数
     * appId，appKey： 请从爱思后台获取，后台地址 http://dev.i4.cn ，登录账号是游戏方申请的开发者账号
     * logData： 设置为 YES 时，控制台会显示网络请求的数据；设置为 NO 时，控制台不会有网络请求的数据显示
     * closeRecharge： 设置为 YES 时，关闭充值功能；设置为 NO 时，打开充值功能
     * closeRechargeAlertMessage： 为关闭充值功能的提示语
     * isHiddenCloseButtonOnAsLoginView:设置为YES时隐藏登陆界面的关闭按钮
     * longComet： 设置为 YES 时，为充值并兑换道具，爱思平台服务器会给游戏方服务器发送兑换道具成功或失败的消息；设置为 NO 时，为先打开爱思充值页面，给账户充值，将人民币兑换为爱思币。
     特别提醒：“- (void)asPayResultCallBack:(AsPayResultCode)paramPayResultCode”方法只会在账户的爱思币余额 >= 道具面额 时，才会执行，爱思币 < 道具面额 的情形下，该支付回调方法不会执行。
     爱思币 < 道具面额 的情形下，执行 "- (void)asRechangeAndPayResultCallBack:(AsRechageResultCode)rechangeResultCode" 方法 。
     */
    do {
        
        FKChannelConfig *config = [FKDataManager getInstance].config.channelConfig;
        
        if ( !config ) {
            FKLog( @"获取配置出错" );
            break;
        }
        
        if ( config.appId<=0 || !config.appKey ) {
            FKLog( @"获取配置appId，appKey出错" );
            break;
        }
        
        id instance = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"AsInfoKit"),NSSelectorFromString( @"sharedInstance"));
        
        if ( !instance ) {
            FKLog( @"AsInfoKit插件加载失败" );
            break;
        }
        
        ((void(*)(id, SEL, int))objc_msgSend)(instance, NSSelectorFromString(@"setAppId:"), [config.appId intValue]);
        ((void(*)(id, SEL, NSString*))objc_msgSend)(instance, NSSelectorFromString(@"setAppKey:"), config.appKey);
        
        //setup sdk
        FKCALL_Int(instance,@"setAppId:",[config.appId integerValue]);
        FKCALL_Int(instance,@"setLogData:",self.debugMode);
        FKCALL_Int(instance,@"setCloseRecharge:",NO);
        FKCALL1(instance,@"setCloseRechargeAlertMessage:",@"充值功能暂时不开放");
        FKCALL_Int(instance,@"setLongComet:",YES);
        FKCALL_Int(instance,@"setIsHiddenCloseButtonOnAsLoginView:",NO);
        
        //obc
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        if ( !vc ) {
            FKLog( @"rootViewController获取为nil" );
            break;
        }
        
        FKCALL1(instance,@"setRootViewController:",vc);
        
        id asPlatform =  ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"AsPlatformSDK"), NSSelectorFromString(@"sharedInstance"));
        
        if ( !asPlatform ) {
            FKLog( @"AsPlatformSDK插件加载失败" );
            break;
        }
        
        m_object_handle = asPlatform;
        FKCALL(asPlatform,@"checkGameUpdate");
        FKCALL1(asPlatform,@"setDelegate:",self);
        
        m_user = [FKUser new];
        
        //init platform sdk success
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
            [self.delegate onInitResult:YES message:@"AsPlatformSDK插件初始化成功"];
        }
        
        return YES;
    } while (0);
    
    //init platform sdk faird
    if ( self.delegate && [self.delegate respondsToSelector:@selector(onInitResult:message:)] ) {
        [self.delegate onInitResult:YES message:@"AsPlatformSDK插件初始化失败"];
    }
    
    return NO;
}

#pragma mark - FKProtocol
-(void)login{
    FKCALL(m_object_handle, @"showLogin");
}

- (FKUser *)getLoginUser{
    return m_user;
}

-(void)logout{
    FKCALL(m_object_handle, @"logout");
}

- (BOOL)isSupportedPlatformCenter{
    return true;
}

- (void)enterPlatformCenter{
    FKCALL(m_object_handle, @"showCenter");
}

- (BOOL)isSupportedFloatToolBar{
    return true;
}

- (void)showOrHideFloatToolBar:(BOOL)isShow{
    
}

- (void)accountSwitch{
    
}

- (void)payForProductOrderNo:(NSString *)orderNo
                        name:(NSString *)name
                       price:(NSUInteger)price{
    
    /**
     * @brief     兑换道具
     * @noti      只有余额大于道具金额时候才有客户端回调。余额不足的情况取决与LongComet参数，LongComet = YES，则为充值兑换。回调给服务端，LongComet = NO ，则只是打开充值界面
     * @param     INPUT paramPrice      商品价格，价格必须为大于等于1的int类型
     * @param     INPUT paramBillNo     商品订单号，订单号长度请勿超过30位，参有特殊符号
     * @param     INPUT paramBillTitle  商品名称
     * @param     INPUT paramRoleId     角色id，回传参数，若无请填0
     * @param     INPUT paramZoneId     无效参数，传0即可
     * @return    无返回
     */
//    - (void)exchangeGoods:(int)paramPrice BillNo:(NSString *)paramBillNo BillTitle:(NSString *)paramBillTitle RoleId:(NSString *)paramRoleId ZoneId:(int)paramZoneId;
    
    ((void(*)(id, SEL, NSInteger,id,id,id,NSInteger))objc_msgSend)(m_object_handle,
                                                       NSSelectorFromString(@"exchangeGoods:BillNo:BillTitle:RoleId:ZoneId:")
                                                       ,price
                                                       ,orderNo
                                                       ,name
                                                       ,@"0"
                                                       ,0);
}


#pragma mark - UIAPPLicationDelegate
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return YES;
}

#pragma mark - ai si delelgate
/**
 * @brief   余额大于所购买道具
 * @param   INPUT   paramAsPayResultCode       接口返回的结果编码
 * @return  无返回
 */
- (void)asPayResultCallBack:(int)paramPayResultCode{
    
    if ( 0==paramPayResultCode ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:kPaySuccess message:@"购买成功，爱思余额大于所购买道具"];
        }
    }
    else
    {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            
            PayResultCode resultCode = kPayUnKnow;
            NSString *msg = @"未知错误";
            
            switch ( paramPayResultCode ) {
                case 1://用户离线，禁止访问
                    resultCode = kPayNetworkError;
                    msg = @"用户离线，禁止访问";
                    break;
                case 2://非法访问，可能用户已经下线
                    resultCode = kPayNetworkError;
                    msg = @"非法访问，可能用户已经下线";
                    break;
                case 3://爱思币余额不足 必选参数丢失
                    resultCode = kPayProductionInforIncomplete;
                    msg = @"爱思币余额不足 必选参数丢失";
                    break;
                case 4://消费金额填写不正确
                    resultCode = kPayProductionInforIncomplete;
                    msg = @"消费金额填写不正确";
                    break;
                case 5://用户中途取消
                    resultCode = kPayCancel;
                    msg = @"用户中途取消";
                    break;
                default:
                    break;
            }
            
            //noti
            if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
                [self.delegate onPayResult:resultCode message:msg];
            }
        }
    }

    FKLog(@"asPayResultCallBack paramPayResultCode:%d\n",paramPayResultCode);
}


//2.0.2新增接口,爱思币余额不足购买道具的回调
/**
 * @brief   余额小于所购买道具,充值的回调
 * @param   INPUT   paramAsPayResultCode       接口返回的结果编码
 * @return  无返回
 */
- (void)asRechangeAndPayResultCallBack:(int)rechangeResultCode{
    
    //爱思币余额不足,支付成功
    if ( 0==rechangeResultCode ) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:kPaySuccess message:@"支付成功"];
        }
    }
    else{

        PayResultCode resultCode = kPayUnKnow;
        NSString *msg = @"爱思币余额不足,支付结果未知";
        
        if (1==rechangeResultCode){
            resultCode = kPayFail;
            msg = @"爱思币余额不足,支付失败";
        }
        
        if ( self.delegate && [self.delegate respondsToSelector:@selector(onPayResult:message:)] ) {
            [self.delegate onPayResult:resultCode message:msg];
        }
    }

    FKLog(@"asRechangeAndPayResultCallBack rechangeResultCode:%d\n",rechangeResultCode);
}

/**
 * @brief   验证更新成功后
 * @noti    分别在非强制更新点击取消更新和暂无更新时触发回调用于通知弹出登录界面
 * @return  无返回
 */
- (void)asVerifyingUpdatePassCallBack{
    FKLog(@"asVerifyingUpdatePassCallBack do nothing\n");
}

/**
 * @brief   登录成功回调
 * @param   INPUT   paramToken       字符串token
 * @return  无返回
 */
- (void)asLoginCallBack:(NSString *)paramToken{
    
    //set user data
    m_user.channelToken = paramToken;
    u_int64_t currentUserId = (u_int64_t)((int(*)(id, SEL))objc_msgSend)(m_object_handle, NSSelectorFromString(@"currentUserId"));
    m_user.channelUserId = [NSString stringWithFormat:@"%llu",currentUserId];
    
    
    typeof(self) __weak _self = self;
    //验证渠道登陆
    [self authWithContent:@{@"token": paramToken} callBack:^(BOOL success) {
        if ( success ) {
            //noti
            if ( _self.delegate ) {
                if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                    [_self.delegate onUserActionResult:kLoginSuccess message:@"爱思用户登录成功"];
                }
            }
        }
        else
        {
            //noti
            if ( _self.delegate ) {
                if ( [_self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
                    [_self.delegate onUserActionResult:kLoginFail message:@"爱思用户登录失败, Token验证失败"];
                }
            }
        }
    }];
}


/**
 * @brief   关闭登录页面后的回调
 * @param   INPUT   paramAsPageCode       接口返回的页面编码
 * @return  无返回
 */
- (void)asCloseLoginViewCallBack:(int)paramPageCode{
    FKLog(@"asCloseLoginViewCallBack do nothing\n");
    //noti
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kExitPage message:@"爱思用户关闭登录页面"];
        }
    }
}

/**
 * @brief   注销后的回调
 * @return  无返回
 */
- (void)asLogOffCallBack{
    //noti
    if ( self.delegate ) {
        if ( [self.delegate respondsToSelector:@selector(onUserActionResult:message:)] ) {
            [self.delegate onUserActionResult:kLogoutSuccess message:@"爱思用户注销登录"];
        }
    }
    FKLog( @"asLogOffCallBack\n" );
}
@end


