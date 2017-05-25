//
//  ItoolsHelp.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKBasePlatform.h"
//(@"Itools注意:客户端如何确认支付成功？这里需要客户端和游戏服务器做逻辑处理，客户端SDK没有支付成功的回调。一般情况，用户支付成功5分钟内都会到账（平台异步通知到游戏发货服务器），所以客户端在SDK支付页面关闭后可以和游戏服务器做轮询，如果客户端和游戏服务器有TCP长连接的话可以采用服务器推送的的方式。");
@interface ItoolsHelp : FKBasePlatform@end
