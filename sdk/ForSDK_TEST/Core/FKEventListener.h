//
//  EventListener.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/8/7.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>

@interface FKEventListener : NSObject
@property (nonatomic, assign) id <UIApplicationDelegate> delegate;
@end
