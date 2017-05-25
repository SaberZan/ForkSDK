//
//  FKConfig.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKConfig.h"
#import "Cryptor.h"
#import "DataManager.h"
#import "FKNetHelp.h"

#define kREMOTE_SERVER_URL @"http://192.168.2.53/sdkapi/pack/list"

NSString const *CHANNEL_CODE = @"CHANNEL_CODE";
NSString const *SCREEN_DIRECTION = @"SCREEN_DIRECTION";

NSString const *ITOOLS_CONFIG = @"ITOOLS_CONFIG";
NSString const *TONGBU_CONFIG = @"TONGBU_CONFIG";
NSString const *BAIDU_CONFIG = @"BAIDU_CONFIG";
NSString const *AISI_CONFIG = @"AISI_CONFIG";
NSString const *XY_CONFIG = @"XY_CONFIG";
NSString const *HAIMA_CONFIG = @"HAIMA_CONFIG";
NSString const *KUAIYONG_CONFIG = @"KUAIYONG_CONFIG";
NSString const *PP_CONFIG = @"PP_CONFIG";


NSString* NSKeyFromPlatform(int type){
    switch (type) {
        case 1001:
            return AISI_CONFIG;
            break;
        case 1002:
            return XY_CONFIG;
        case 1003:
            return HAIMA_CONFIG;
        case 1004:
            return ITOOLS_CONFIG;
        case 1005:
            return TONGBU_CONFIG;
        case 1006:
            return BAIDU_CONFIG;
        case 1007:
            return KUAIYONG_CONFIG;
        case 1008:
            return PP_CONFIG;
            break;
        default:
            break;
    }
    return @"";
}

NSString *NSServerPlatformKeyWithPlatform(int channelCode){
    channelCode -= 1001;
    NSArray *server_channels = @[@"i4",@"xygame",@"haima",@"itools",@"tongbu",@"baidu_ios",@"kuaiyong",@"pp"];
    if ( channelCode>server_channels.count ) {
        return nil;
    }
    return server_channels[ channelCode ];
}

int channelCodeWithNSServerPlatformKey(NSString *platformKey){
    if ( !platformKey ) {
        return 0;
    }
    NSArray *server_channels = @[@"i4",@"xygame",@"haima",@"itools",@"tongbu",@"baidu_ios",@"kuaiyong",@"pp"];
    int i=0;
    for (NSString *s in server_channels) {
        if ( [s isEqualToString:platformKey] ) {
            return i+1001;
        }
        i++;
    }
    return 0;
}

NSString* NSShemeWithPlatform(int channelCode, FKChannelConfig* config){
    return @"channelSheme";
}

@implementation FKChannelConfig

- (id)initWithDic:(NSDictionary *)dic{
    self = [super init];
    self.appKey = dic[@"APPKEY"];
    self.appId = dic[@"APPID"];
    return self;
}

- (NSDictionary *)toDic{
    return @{@"APPID":self.appId,@"APPKEY":self.appKey};
}

- (id)initWithParams:(NSArray *)params{
    self = [super init];
    
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

@interface FKConfig ()
@property (nonatomic, strong) NSString *encodeFilePath;
@property (nonatomic, strong) NSString *configFilePath;
@end

@implementation FKConfig

- (id)init{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:@"ForkSDK/FKConfig.plist"];
    return [self initWithFile:path];
}

- (id)initWithFile:(NSString *)file{
    self = [super init];
    self.configFilePath = file;
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:file] ) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[file stringByDeletingPathExtension]
                                  withIntermediateDirectories:YES attributes:nil error:nil];
        
        [[NSFileManager defaultManager] createFileAtPath:file
                                                contents:[NSData data]
                                              attributes:nil];
    }
    
    _channelConfig = [[NSMutableDictionary alloc] init];
    [_channelConfig setValuesForKeysWithDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:file]];
    _channelConfig[CHANNEL_CODE] = @([DataManager getInstance].platform);
    
    return self;
}

- (void)setConfig:(FKChannelConfig *)config
     forPlantform:(int)type{
    self.channelConfig[NSKeyFromPlatform(type)] = [config toDic];
    [self save];
}

- (FKChannelConfig *)configForType:(int)type{
    return [[FKChannelConfig alloc] initWithDic:self.channelConfig[NSKeyFromPlatform(type)]];
}

- (void)save{
    if ( _channelConfig ) {
        _channelConfig[CHANNEL_CODE] = @([DataManager getInstance].platform);
        [_channelConfig writeToFile:self.configFilePath
                         atomically:YES];
    }
}

//加密到文件
- (void)encodeToFile:(NSString *)filePath{
    
    [self save];
    
    NSData *data = [Cryptor AES256EncryptWithKey:@"xygamecomforksdk" forData:[NSData dataWithContentsOfFile:self.configFilePath]];
    [data writeToFile:filePath atomically:YES];

    NSLog(@"encodeToFile : %@ \n",filePath);
}

- (void)fetchChannelInfo:(NSString *)appId
                  appKey:(NSString *)appKey
                callBack:(void(^)(BOOL success))callback{
    
    NSString *token = [Cryptor md5Encode:[NSString stringWithFormat:@"%@%@%@",appId,appKey,@"ios"]];
    NSDictionary *parmas = @{ @"appid":appId,@"t":@"ios",@"token":token };
    
    [[FKNetHelp getInstance] sendGetRequestWithUrl:kREMOTE_SERVER_URL withParms:parmas
                                       whenSuccess:^(NSDictionary *result) {
                                           NSString* resultcode = result[@"resultcode"];
                                           int success = 0;
                                           if ( resultcode ) {
                                               success = [resultcode intValue];
                                           }
                                           
                                           if ( 0==success ) {
                                               callback( NO );
                                               return ;
                                           }
                                           
                                           NSArray *content_arr = result[@"content"];
                                           
                                           [self handelParams:content_arr];
                                           
                                           callback( YES );
                                           
                                       } andFailed:^(NSError *error) {
                                           callback( NO );
                                       }];
}


- (void)handelParams:(NSArray *)content_arr{
    do {
        if ( !content_arr || content_arr.count==0 ) {
            break;
        }
        
        _channelConfig = [NSMutableDictionary new];
        for (NSDictionary *content_dic in content_arr) {
            NSArray *params_arr = content_dic[@"params"];
            NSString *pack_name = content_dic[@"pack_name"];
            NSString *name_mark = content_dic[@"name_mark"];
            
            FKChannelConfig* channel_config = [[FKChannelConfig alloc] initWithParams:params_arr];
            channel_config.packName = pack_name;
            
            int channel_code=channelCodeWithNSServerPlatformKey( name_mark );
            if ( 0==channel_code ) {
                continue;
            }
            _channelConfig[ name_mark ] = channel_config;
        }
        
    } while (0);
    
}

- (NSArray *)getCanUsePlatforms{
    NSMutableArray *can_use_platform = [NSMutableArray new];
    
    for (NSString *platform_key in _channelConfig.allKeys) {
        int channel_code = channelCodeWithNSServerPlatformKey( platform_key );
        if (  0==channel_code ) {
            continue;
        }
        
        [can_use_platform addObject:@( channel_code )];
    }
    return can_use_platform;
}

- (void)saveConfigFileWithChannelCode:(int)channelCode
                             dirction:(NSString *)dirction
                             filePath:(NSString *)filePath{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[ CHANNEL_CODE ] = @( channelCode );
    dic[ SCREEN_DIRECTION ] = dirction?dirction:@"1";
    [dic writeToFile:filePath atomically:YES];
}
@end
