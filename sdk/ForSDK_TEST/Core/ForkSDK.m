//
//  ForkSDK.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "ForkSDK.h"
#import "FKConfig.h"
#import "FKDataManager.h"
#import "FKMacro.h"
#import <objc/message.h>
#import <Foundation/NSObjCRuntime.h>

@implementation ForkSDKManager

+ ( id<FKProtocol> )getAgentManager{
    id<FKProtocol> agent = nil;
    FKConfig *pConfig = [FKDataManager getInstance].config;
    
    NSArray *platforms = @[ @FKSTR(ASHelp),
                            @FKSTR(XYHelp),
                            @FKSTR(HaiMaHelp),
                            @FKSTR(ItoolsHelp),
                            @FKSTR(TbGameHelp),
                            @FKSTR(Baidu91Help),
                            @FKSTR(KuaiYongHelp),
                            @FKSTR(PPHelp) ];
    
    NSInteger platform_id = pConfig.channelCode-1001;
    
    if ( platform_id>platforms.count ) {
        FKLog(@"load plug-in failure");
        return nil;
    }
    
    agent = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(platforms[ platform_id ]), NSSelectorFromString(@"getInstance"));
    return agent;
}
@end
