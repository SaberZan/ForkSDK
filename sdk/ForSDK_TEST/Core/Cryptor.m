//
//  Cryptor.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/8/7.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "Cryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation Cryptor@end

@implementation Cryptor(AES)

+ (NSData *)AES256EncryptWithKey:(NSString *)key
                         forData:(NSData *)data//加密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    
    return nil;
}

+ (NSData *)AES256DecryptWithKey:(NSString *)key
                         forData:(NSData *)data//解密
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    
    return nil;
}

+ (NSString *)newStringInBase64FromData:(NSData *)data //追加64编码
{
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    unsigned char * working = (unsigned char *)[data bytes];
    int srcLen = [data length];
    for (int i=0; i<srcLen; i += 3) {
        for (int nib=0; nib<4; nib++) {
            int byt = (nib == 0)?0:nib-1;
            int ix = (nib+1)*2;
            if (i+byt >= srcLen) break;
            unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
            if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
            [dest appendFormat:@"%c", base64[curr]];
        }
    }
    return dest;
}

+ (NSString *)base64Encode:(NSString *)str
{
    if ([str length] == 0)
        return @"";
    const char *source = [str UTF8String];
    int strlength = strlen(source);
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    NSUInteger i = 0;
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = base64[(buffer[0] & 0xFC) >> 2];
        characters[length++] = base64[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = base64[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = base64[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    NSString *g = [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    return g;
}

+ (NSString *)md5Encode:(NSString *)str{
    if ( !str || str.length==0 ) {
        return nil;
    }
    
    // Create pointer to the string as UTF8
    const char *ptr = [str UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (uint32_t)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}
@end