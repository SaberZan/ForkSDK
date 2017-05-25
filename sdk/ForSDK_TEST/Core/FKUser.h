//
//  FKUser.h
//  ForSDK_TEST
//
//  Created by xygame.com on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

/*
             ________   _________   _____      __   _    ______   _______     __   _
            /  _____/  / _____  /  / _   \    / / .'.'  / ____/  / ___   \   / / .'.'
           /  /____   / /    / /  / /_) /    / /-'.'   / /___   / /   '. |  / /-'.'
          /  _____/  / /    / /  / _  ,'    / _  |    /___  /  / /    / /  / _  |
    __   /  /       / /____/ /  / / \ \    / / | |   ____/ /  / /___.' /  / / | |
   / /  /__/       /________/  /_/   \_\  /_/  |_|  /_____/  /_______.'  /_/  |_|
  / /_________________________________________________________
 /___________________________________________________________/   R   O   B   I   N
 
 */

#import <Foundation/NSString.h>

@interface FKUser : NSObject

/**  登录验证令牌 */
@property (nonatomic, copy)  NSString *channelToken;
/**  渠道用户ID  */
@property (nonatomic, copy)  NSString *channelUserId;
/**  渠道用户昵称  */
@property (nonatomic, copy)  NSString *channelUserName;

@end
