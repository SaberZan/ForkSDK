//
//  FKUrlParHelp.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSArray * LHWQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * LHWQueryStringPairsFromKeyAndValue(NSString *key, id value);
NSString * LHWPercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding);
NSString * LHWQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);

@interface FKUrlParHelp : NSObject

+ (NSURL *)urlWithDictionary:(NSDictionary *)dic
                  andBaseURL:(NSURL *)baseurl;

@end
