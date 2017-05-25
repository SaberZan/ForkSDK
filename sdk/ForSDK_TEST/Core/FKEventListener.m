//
//  EventListener.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/8/7.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKEventListener.h"

@implementation FKEventListener

- (id)init{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handelOpenUrl:)
                                                 name:@"openURL"
                                               object:nil];
    
    return self;
}

- (void)handelOpenUrl:(NSNotification *)userInfo{
    
    NSArray *paramArray = userInfo.userInfo[@"infoArray"];
    
    [self.delegate application:paramArray[0]
                       openURL:paramArray[1]
             sourceApplication:paramArray[2]
                    annotation:paramArray[3]];
}

@end
