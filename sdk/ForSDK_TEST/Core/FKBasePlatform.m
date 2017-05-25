//
//  FKBasePlatform.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/16.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKBasePlatform.h"
#import "FKEventListener.h"
#import "FKDataManager.h"
#import "ForkSDK.h"

@interface FKBasePlatform (){
    FKEventListener *m_pEventListener;
}
@end

@implementation FKBasePlatform

+ ( id<FKProtocol> )getInstance{
    static dispatch_once_t onceToken;
    static FKBasePlatform* sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    self = [super init];
    m_pEventListener = [FKEventListener new];
    m_pEventListener.delegate = self;
    self.debugMode = YES;
    return self;
}

- (FKUser* )user{
    if ( !_user ) {
        _user = [FKUser new];
    }
    return _user;
}

- (void)authWithContent:(NSDictionary *)content
               callBack:(void(^)(BOOL success))callBack{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
    NSString *content_json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[FKDataManager getInstance] requestAuth:content_json_string completeCallBack:^(NSDictionary* responds){
        do {
            if ( !responds || responds.allKeys<=0 ) {
                break;
            }
            
            id resultcode_number = responds[@"resultcode"];
            
            int resultcode = 0;
            
            if ( !resultcode_number ) {
                break;
            }
            
            //may be NSNumber or NSString
            resultcode = [resultcode_number intValue];
            
            if ( resultcode!=1 ) {
                break;
            }
            
            callBack( YES );
            return ;
        } while (0);
        
        callBack( NO );
    }];
}

#pragma mark - protocol

- (void)initWithAppId:(NSString *)appId
               appKey:(NSString *)appKey{
    
    if ( self.debugMode ) {
        NSLog(@"\n\n%@\n\n",@FORK_SDK_HELLO);
    }
    
    //init xygame appId appKey
    [[FKDataManager getInstance] setAppId:appId];
    [[FKDataManager getInstance] setAppKey:appKey];
    
    //now start fetch platform infomation with xygame appId appKey
    [[FKDataManager getInstance] requestChannelInfoCompleteCallBack:^(NSDictionary *info) {
        
        
                                                    //here start init platform sdk
                                                    [self initializationPlatform];
        
                                            }];
}

- (NSString *)getSDKVersion{
    return KVERSION_SDK;
}

- (BOOL)initializationPlatform{
    NSLog(@"初始化失败，未初始化 exit(0)");
    exit(0);
}

#pragma mark - protocol
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return YES;
}
@end

