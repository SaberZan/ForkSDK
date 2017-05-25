//
//  TMHook.h
//  Interceptor
//
//  Created by ruikong on 4/17/15.
//  Copyright (c) 2015年 Ruikong Technology. All rights reserved.
//

#import "FKHook.h"
#import "FKAspects.h"
#import <UIKit/UIKit.h>
#import "FKDataManager.h"
#import <objc/runtime.h>
#import "FKMacro.h"

@implementation FKHook

+ (void)load
{
    [super load];
    [FKHook sharedInstance];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FKHook *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FKHook alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        //Monitoring
        IMP applicationOpenURLImp = imp_implementationWithBlock(^(id _self,id id1,id id2,id id3,id id4) {
            FKLog( @"[AppDelegate application:openURL:sourceApplication:annotation:] handeled" );
        });
        class_addMethod(NSClassFromString(@"AppDelegate"), @selector(application:openURL:sourceApplication:annotation:), applicationOpenURLImp, "v@:@@@@");
        
        IMP applicationDidEnterBackgroundImp = imp_implementationWithBlock(^(id _self, id _application) {
            FKLog(@"[applicationDidEnterBackground %@] \n", _application);
        });
        class_addMethod(NSClassFromString(@"AppDelegate"), @selector(applicationDidEnterBackground:), applicationDidEnterBackgroundImp, "v@:@");
        
        //Monitoring [AppDelegate applicationDidEnterBackground:application]
        [NSClassFromString(@"AppDelegate") aspect_hookSelector:@selector(applicationDidEnterBackground:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
            FKLog(@"[APPDelegate applicationDidEnterBackground:application] \n");
        } error:NULL];
        
        //Monitoring [AppDelegate applicationDidEnterBackground:application]
        [NSClassFromString(@"AppDelegate") aspect_hookSelector:@selector(application:openURL:sourceApplication:annotation:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
            NSDictionary *infoDict = @{@"infoArray" : [aspectInfo arguments]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL"
                                                                object:[aspectInfo instance]
                                                              userInfo:infoDict];
        } error:NULL];
        
//        [UIViewController aspect_hookSelector:@selector(viewDidLoad)
//                                  withOptions:AspectPositionAfter
//                                   usingBlock:^(id<AspectInfo> aspectInfo){
//            [self viewDidLoad:[aspectInfo instance]];
//        } error:NULL];
    }
    return self;
}
@end
