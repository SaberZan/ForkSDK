//
//  ViewController.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKViewController.h"
#import "ForkSDK.h"

@interface FKViewController ()<ForkSDKDelegate>
@end

@implementation FKViewController

- (void)loadView{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(100, 100, 100, 100);
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    loginBtn.backgroundColor = [UIColor greenColor];
    [loginBtn addTarget:self action:@selector(loginAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *payBTn = [UIButton buttonWithType:UIButtonTypeCustom];
    payBTn.frame = CGRectMake(220, 100, 100, 100);
    [payBTn setTitle:@"支付" forState:UIControlStateNormal];
    payBTn.backgroundColor = [UIColor redColor];
    [payBTn addTarget:self action:@selector(payAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBTn];
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    centerBtn.frame = CGRectMake(110, 210, 100, 100);
    [centerBtn setTitle:@"用户中心" forState:UIControlStateNormal];
    centerBtn.backgroundColor = [UIColor colorWithRed: 0.1034 green: 0.5858 blue: 0.7623 alpha: 1.0];
    [centerBtn addTarget:self action:@selector(showUserCenter:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:centerBtn];
    
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(220, 210, 100, 100);
    [exitBtn setTitle:@"退出" forState:UIControlStateNormal];
    exitBtn.backgroundColor = [UIColor orangeColor];
    [exitBtn addTarget:self action:@selector(logoutAction:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
    
    [[ForkSDKManager getAgentManager] setDelegate:self];
    //init
    [[ForkSDKManager getAgentManager] initWithAppId:@"sanguo"
                                             appKey:@"4U8jTMWIq"];
}

#pragma mark - forksdk api methods
//登录
- (void)loginAction:(id)sender{
    [[ForkSDKManager getAgentManager] login];
}

//注销
- (void)logoutAction:(id)sender{
    [[ForkSDKManager getAgentManager] logout];
}

//支付
- (void)payAction:(id)sender{
    NSDateFormatter *dataF = [[NSDateFormatter alloc] init];
    [dataF setDateFormat:@"yyyyMMddHHmmss"];
    NSString *order_no = [dataF stringFromDate:[NSDate date]];
    order_no = [NSString stringWithFormat:@"%@%d%d",order_no,arc4random()%999999+1000,arc4random()%999999+1000];
    
    NSLog(@"订单号:%@\n",order_no);
    [[ForkSDKManager getAgentManager] payForProductOrderNo:order_no
                                                      name:@"封魔套装"
                                                     price:1];
}

- (void)requestOrderId{
    
}

//个人中心
- (void)showUserCenter:(id)sender{
    [[ForkSDKManager getAgentManager] enterPlatformCenter];
}

#pragma mark - forksdk protocol
- (void)onInitResult:(BOOL)isSuccess message:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"初始化" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)onPayResult:(PayResultCode)payResultCode message:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)onUserActionResult:(UserActionResultCode)resultCode message:(NSString *)msg{
    NSLog(@"用户动作：%d %@\n",resultCode, msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
