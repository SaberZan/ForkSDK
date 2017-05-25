//
//  BMGame.h
//  BMGameSDK
//  SDK入口
//  Created by gavin on 14-5-5.
//  Copyright (c) 2014年 Baidu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//账号变更类型
typedef  enum
{
    AccoutChange=0,//切换账号
    AccountFillName,//账号升级
    AccountLogout //注销
}AccountOperationType;

//切换账号结果
typedef enum
{
    ChangeAccountCancle=0,
    GetNewAccessToken,
    ChangeAccountSucess,
    InitUserInfoFail
}ChangeAccountResult;

//Push 环境
typedef NS_ENUM(NSInteger, PushMode){
    PushModeDevelopment, // 开发测试环境
    PushModeProduction, // AppStore 上线环境
};


//账号切换、试玩账号升级
@protocol AccountChangeDelegate <NSObject>

//切换账号、试玩账号升级
- (void)changeAccountDid:(AccountOperationType) type;

@end

@interface BMGame : NSObject
@property (nonatomic,retain)NSString    *appId;
@property (nonatomic,retain)NSString    *appKey;
@property (nonatomic,assign)id<AccountChangeDelegate> accountChangeDelegate;

typedef void(^LoadingSucessCallback)();
typedef void (^InitUserInofCallBack)(int status);
typedef void (^ChangeAccountCallBack)(AccountOperationType type);
typedef void (^SessionTimeOutCallBack)();


//单例方式获取BMGame实例

+ (BMGame *)instance;

//SDK初始化 appID为百度移动游戏的appID
- (void)initSDK:(NSString *)appID  AppKey:(NSString *)appKey IMEI:(NSString *)imei;

//初始化用户信息，登录成功后调用
- (void)initUserInfo:(NSInteger)loginType UID:(NSString *)uid DisplayName:(NSString *)displayName IsBindPhone:(BOOL)isBindPhone BDUSSS:(NSString *)bduss InitUserInofCallBack:(InitUserInofCallBack) initUseInfo;

//显示广告
- (void)showAdvertView;

//关闭广告
- (void)closeAdverView;

//切换账号结果
- (void)changeAccountFinish:(ChangeAccountResult) result;

//显示悬浮窗
- (void)showAssiatentView;

//隐藏悬浮窗
- (void)hideAssistabvView;

//Session失效
- (void)sessonDidTimeOut:(SessionTimeOutCallBack) callBack;

//显示loading页
- (void)showLoadingViewWithWindows:(UIWindow *)window LoadingSucessCallback:(LoadingSucessCallback)loadingSucessCallback;

//push 初始化
- (void)pushInit:(NSString *)appKey LaunchOptions:(NSDictionary *)launchOptions PushMode:(PushMode)mode;

//Push token注册
- (void)pushDeviceTokenRegister:(NSData *)deviceToken;

//收到push响应百度云
- (void)pushHandleNotication:(UIApplication *)application userInfo:(NSDictionary *)userInfo;

@end
