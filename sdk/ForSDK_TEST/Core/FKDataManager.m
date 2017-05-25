//
//  FKDataManager.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKDataManager.h"
#import "FKMacro.h"
#import "FKNetHelp.h"
#import "Cryptor.h"
#import "LHWBase64.h"

@implementation FKDataManager

+ (instancetype)getInstance{
    static dispatch_once_t onceToken;
    static FKDataManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FKDataManager alloc] init];
        [sharedInstance serialization];
    });
    return sharedInstance;
}

- (void)serialization{
    [self _loadConfigFile:kCONFIG_FILE_PATH];
}

- (uint32_t)getChannelCode{
    return (uint32_t)self.config.channelCode;
}

- (void)_loadConfigFile:(NSString *)file{
    self.config = [[FKConfig alloc] initWithFile:file];
}

- (NSString *)channelStringWithChannelId:(NSInteger)channelId{
    channelId -= 1001;
    NSArray *server_channels = @[@"i4",@"xygame",@"haima",@"itools",@"tongbu",@"baidu_ios",@"kuaiyong",@"pp"];
    if ( channelId>server_channels.count ) {
        return nil;
    }
    return server_channels[ channelId ];
}

/**
 *  请求渠道信息
 */
- (void)requestChannelInfoCompleteCallBack:(void(^)(NSDictionary *info))callback
{
    NSString *channel = [self channelStringWithChannelId:[self getChannelCode]];
    NSString *token = [Cryptor md5Encode:[NSString stringWithFormat:@"%@%@%@%@",self.appId,self.appKey,channel,@/*content nil*/""]];
    
    NSDictionary *parmas = @{ @"appid":self.appId,@"channelappid":channel,@"token":token, @"ptype":@"ios", @"version":@"1.0" };
    
    [[FKNetHelp getInstance] sendGetRequestWithUrl:[kREMOTE_SERVER_URL stringByAppendingPathComponent:kCHANNEL_PATH] withParms:parmas
                                       whenSuccess:^(NSDictionary *result) {
                                           NSString* resultcode = result[@"resultcode"];
                                           int success = 0;
                                           if ( resultcode ) {
                                               success = [resultcode intValue];
                                           }
                                           
                                           if ( 0==success ) {
                                               callback( nil );
                                               return ;
                                           }
                                           
                                           NSDictionary *content = result[@"content"];
                                           NSString *params_str = content[@"params"];
                                           NSString *callBackUrl = content[@"call_back"];
                                           NSArray *params_arr = [NSJSONSerialization JSONObjectWithData:[params_str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                                           
                                           _config.channelConfig = [[FKChannelConfig alloc] initWithParams:params_arr];
                                           _config.channelConfig.callBackUrl = callBackUrl;
                                           
                                           callback( result );
    } andFailed:^(NSError *error) {
        callback( nil );
    }];
}

- (void)requestAuth:(NSString *)content
   completeCallBack:(void(^)(NSDictionary *info))callback;{
    if ( !content || content.length==0 ) {
        callback(nil);
    }
    
    content = [LHWBase64 stringByEncodingData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* EncodeContent = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)content,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    NSString *channel = [self channelStringWithChannelId:[self getChannelCode]];
    NSString *token = [Cryptor md5Encode:[NSString stringWithFormat:@"%@%@%@%@",self.appId,self.appKey,channel,EncodeContent]];
    NSDictionary *parmas = @{ @"appid":self.appId,@"channelappid":channel, @"content":content, @"token":token, @"ptype":@"ios", @"version":@"1.0" };
    
    [[FKNetHelp getInstance] sendGetRequestWithUrl:[kREMOTE_SERVER_URL stringByAppendingPathComponent:kAUTH_PATH] withParms:parmas
                                       whenSuccess:^(NSDictionary *result) {
                                           callback( result );
                                       } andFailed:^(NSError *error) {
                                           callback( nil );
                                       }];
}

+ (NSString *)getAppName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = infoDictionary[@"CFBundleName"];
    if ( !app_Name ) {
        app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    }
    return app_Name;
}

+ (NSString *)getAppVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

+ (NSString *)getSchemes{
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSArray *app_url_types = [infoDictionary objectForKey:@"CFBundleURLTypes"];
    if ( app_url_types && app_url_types.count>0 ) {
        NSDictionary *app_schemes = [app_url_types firstObject];
        NSArray *arr = app_schemes[@"CFBundleURLSchemes"];
        if ( arr && arr.count>0 ) {
            return [arr firstObject];
        }
    }
    
    return nil;
}
@end
