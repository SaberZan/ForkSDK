//
//  FKBasePlatform.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/16.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIApplication.h>

#import "FKProtocol.h"
#import "FKMacro.h"
#import "FKUser.h"

@interface FKBasePlatform : NSObject<FKProtocol,UIApplicationDelegate>
/* delegate */
@property (nonatomic, assign) id<ForkSDKDelegate> delegate;
/* User */
@property (nonatomic, strong) FKUser *user;
/* debug */
@property (nonatomic, assign) BOOL debugMode;

/**
 *  get single instance
 *
 *  @return instance
 */
+ ( id<FKProtocol> )getInstance;

/**
 *  init platform sdk please override this method
 *
 *  @return success？
 */
- (BOOL)initializationPlatform;

/**
 *  验证渠道登陆
 *
 *  @param content  渠道conent构造
 *  @param callBack callback
 */
- (void)authWithContent:(NSDictionary *)content
               callBack:(void(^)(BOOL success))callBack;


@end

