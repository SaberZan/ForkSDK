//
//  FKConfig.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKConfig.h"
#import "FKMacro.h"
#import "Cryptor.h"

#define FKAESDECODEKEY @"xygamecomforksdk"

NSString const *CHANNEL_CODE = @"CHANNEL_CODE";
NSString const *ITOOLS_CONFIG = @"ITOOLS_CONFIG";
NSString const *TONGBU_CONFIG = @"TONGBU_CONFIG";
NSString const *BAIDU_CONFIG = @"BAIDU_CONFIG";
NSString const *AISI_CONFIG = @"AISI_CONFIG";
NSString const *XY_CONFIG = @"XY_CONFIG";
NSString const *HAIMA_CONFIG = @"HAIMA_CONFIG";
NSString const *KUAIYONG_CONFIG = @"KUAIYONG_CONFIG";
NSString const *PP_CONFIG = @"PP_CONFIG";

@implementation FKChannelConfig
- (id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    do {
        
        self.appKey = dic[@"APPKEY"];
        self.appId = dic[@"APPID"];
        
        if ( !self.appKey && !self.appId ) {
            break;
        }
        FKLog(@"渠道配置 APPID%@ && APPKEY %@",self.appId,self.appKey);
        
        return self;
        
    } while (0);
    FKLog(@"渠道配置 APPID && APPKEY 获取失败");
    return nil;
}

- (id)initWithParams:(NSArray *)params{
    self = [super init];
    
    NSLog(@"params:%@\n",params);
    
    if ( params && params.count>0 ) {
        NSDictionary *param_dic = params[0];
        self.appId = param_dic[@"value"];
    }
    
    if ( params && params.count>1 ) {
        NSDictionary *param_dic = params[1];
        self.appKey = param_dic[@"value"];
    }
    
    return self;
}
@end

@implementation FKConfig

- (id)init{
    self = [super init];
    self.channelCode = -1;
    return self;
}

- (id)initWithFile:(NSString *)fileName{
    self = [self init];
    if ( ![self _initialize:fileName] ) {
        FKLog(@"初始化数据失败，请检查 文件：[%@] 配置",fileName);
    }
    else
    {
        FKLog(@"load file [%@] success\n",fileName);
    }
    
    return self;
}

- (BOOL)_initialize:(NSString *)fileName{
    BOOL ret = false;
    do {
        
        if ( !fileName || fileName.length<=0 ) {
            break;
        }
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                             ofType:nil];
        
        if ( !filePath || filePath.length<=0 ) {
            break;
        }
        
#if 0
        NSData *encodeData = [NSData dataWithContentsOfFile:filePath];
        
        if ( !encodeData || encodeData.length<=0 ) {
            break;
        }
        
        NSData *decodeData = [Cryptor AES256DecryptWithKey:FKAESDECODEKEY
                                                   forData:encodeData];

        NSDictionary *config = [self dictionaryWithContentsOfData:decodeData];
        
#endif
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:filePath];

        if ( !config || config.allKeys.count<=0 ) {
            break;
        }
        
        NSNumber *channel = config[ CHANNEL_CODE ];
        if ( channel ) {
            self.channelCode = [channel integerValue];
        }
        
        if ( -1==self.channelCode ) {
            break;
        }
        
        NSInteger channel_id=self.channelCode-1001;
        NSArray *platform_config = @[AISI_CONFIG,XY_CONFIG,HAIMA_CONFIG,ITOOLS_CONFIG,TONGBU_CONFIG,BAIDU_CONFIG,KUAIYONG_CONFIG,PP_CONFIG];
        
        if ( channel_id<0 || channel_id>=platform_config.count ) {
            break;
        }
        
        FKLog(@"load channel config success, channelKey:%@ \n",platform_config[ channel_id ]);
        
#if 0
        NSDictionary *config_dic = config[ platform_config[ channel_id ] ];
        
        self.channelConfig = [[FKChannelConfig alloc] initWithDic:config_dic];
        
#endif
        
        ret = true;
        
    } while (0);
    
    return ret;
}


- (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data,
                                                               kCFPropertyListImmutable,
                                                               NULL);
    if(plist == nil) return nil;
    if ([(__bridge id)plist isKindOfClass:[NSDictionary class]]) {
        return (__bridge NSDictionary *)plist;
    }
    else {
        CFRelease(plist);
        return nil;
    }
}
@end
