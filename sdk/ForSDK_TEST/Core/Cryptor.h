//
//  Cryptor.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/8/7.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#import <Foundation/Foundation.h>

@interface Cryptor : NSObject@end

@interface Cryptor (AES)

+ (NSData *)AES256EncryptWithKey:(NSString *)key
                         forData:(NSData *)data;//加密
+ (NSData *)AES256DecryptWithKey:(NSString *)key
                         forData:(NSData *)data;//解密

+ (NSString *)newStringInBase64FromData:(NSData *)data;

+ (NSString *)base64Encode:(NSString *)str;

+ (NSString *)md5Encode:(NSString *)str;

@end

