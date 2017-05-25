//
//  DataManager.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/11.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "DataManager.h"

NSString* NSStringFromPlatform(PLATFORM_TYPE type){
    return [NSString stringWithFormat:@"%d",(int)type];
}

NSString* PlatformNameFromPlatform(PLATFORM_TYPE type){
    switch (type) {
        case 1001:
            return @"爱思";
            break;
        case 1002:
            return @"玄云游戏";
        case 1003:
            return @"海马";
        case 1004:
            return @"Itools";
        case 1005:
            return @"同步助手";
        case 1006:
            return @"百度91";
        case 1007:
            return @"快用";
        case 1008:
            return @"PP助手";
            break;
        default:
            break;
    }
    return @"";
}

NSString *PlatformFlag(PLATFORM_TYPE type){
    switch (type) {
        case 1001:
            return @"i4";
            break;
        case 1002:
            return @"xy";
        case 1003:
            return @"haima";
        case 1004:
            return @"Itools";
        case 1005:
            return @"tb";
        case 1006:
            return @"baidu";
        case 1007:
            return @"ky";
        case 1008:
            return @"pp";
            break;
        default:
            break;
    }
    return @"";
}

@implementation DataManager
@synthesize base_xcodeproj_dir = _base_xcodeproj_dir;
+ (instancetype)getInstance{
    static dispatch_once_t onceToken;
    static DataManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    return sharedInstance;
}

- (void)setBase_xcodeproj_dir:(NSString *)base_xcodeproj_dir{
    _base_xcodeproj_dir = base_xcodeproj_dir;
    NSString *base_path = [base_xcodeproj_dir stringByDeletingLastPathComponent];
    self.base_project_dir = base_path;
}

- (void)setOriginImagePath:(NSString *)originImagePath{
    _originImagePath = originImagePath;
    [self setOriginImage:[[NSImage alloc] initWithContentsOfFile:originImagePath]];
}

- (BOOL)isAvailableProjectPath:(NSString *)path{
    NSString *ext = [path lastPathComponent];
    if ( [ext hasSuffix:@".xcodeproj"] ) {
        return YES;
    }
    return NO;
}

- (BOOL)isAvailableProject{
    return YES;
}

- (BOOL)isAvailableImagePath:(NSString *)path{
    NSString *ext = [path lastPathComponent];
    if ( [ext hasSuffix:@".png"] ) {
        return YES;
    }
    return NO;
}

- (NSString *)platformString{
    return [NSString stringWithFormat:@"%d",(int)self.platform];
}

- (FKConfig *)config{
    if ( !_config ) {
        _config = [FKConfig new];
    }
    return _config;
}

@end
