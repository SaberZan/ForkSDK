//
//  FKUser.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKUser.h"

@implementation FKUser

- (void)reset{
    self.channelToken = nil;
    self.channelUserId = nil;
    self.channelUserName = nil;
}

- (BOOL)isLogined{
    return self.channelToken || self.channelUserName;
}
@end
