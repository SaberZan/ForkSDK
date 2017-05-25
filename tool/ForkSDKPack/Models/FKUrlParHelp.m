//
//  FKUrlParHelp.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKUrlParHelp.h"

@implementation FKUrlParHelp
+ (NSURL *)urlWithDictionary:(NSDictionary *)dic
                  andBaseURL:(NSURL *)baseurl
{
    NSURL *urls = nil;
    if ( !dic || dic.allKeys<=0) {
        return baseurl;
    }
    
    NSString *path = [baseurl path];
    urls = [NSURL URLWithString:[[baseurl absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", LHWQueryStringFromParametersWithEncoding(dic, NSUTF8StringEncoding)]];
    return urls;
}
@end


@interface LHWQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;
- (id)initWithField:(id)field value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation LHWQueryStringPair
- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    self.field = field;
    self.value = value;
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return LHWPercentEscapedQueryStringPairMemberFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", LHWPercentEscapedQueryStringPairMemberFromStringWithEncoding([self.field description], stringEncoding), LHWPercentEscapedQueryStringPairMemberFromStringWithEncoding([self.value description], stringEncoding)];
    }
}
@end

NSString * LHWPercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    NSString * const kFKCharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    NSString * const kFKCharactersToLeaveUnescaped = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kFKCharactersToLeaveUnescaped, (__bridge CFStringRef)kFKCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

NSString * LHWQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding)
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (LHWQueryStringPair *pair in LHWQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * LHWQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return LHWQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * LHWQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue =[dictionary objectForKey:nestedKey];
            //dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:LHWQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:LHWQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in set) {
            [mutableQueryStringComponents addObjectsFromArray:LHWQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[LHWQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}


