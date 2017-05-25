//
//  FKNetHelp.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void ( ^FKNetworkRequestSuccessCallback )( NSDictionary *result );
typedef void ( ^FKNetworkRequestFailedCallback )( NSError* error );

#define kFKNotificationConsts_NetworkBegin                @"kFKNotificationConsts_NetworkBegin"
#define kFKNotificationConsts_NetworkEnd                  @"kFKNotificationConsts_NetworkEnd"
#define kFKNotificationConsts_NetworkError                @"kFKNotificationConsts_NetworkError"
#define kFkNotificationConsts_ServerError                 @"kFkNotificationConsts_ServerError"

typedef enum _HttpMethod{
    GET,
    POST,
    PUT,
    PATCH,
    DELETE
}HttpMethod;

@interface FKNetHelp : NSObject

+ (instancetype)getInstance;

- (void)sendGetRequestWithUrl:(NSString*)url
                    withParms:(NSDictionary*)params
                  whenSuccess:(FKNetworkRequestSuccessCallback)success
                    andFailed:(FKNetworkRequestFailedCallback)failed;

- (void)sendPostRequestWithUrl:(NSString*)url
                    withParms:(NSDictionary*)params
                  whenSuccess:(FKNetworkRequestSuccessCallback)success
                    andFailed:(FKNetworkRequestFailedCallback)failed;

- (void)sendRequestWithUrl:(NSString *)url
                 withParms:(NSDictionary *)parmas
                    method:(HttpMethod)method
               whenSuccess:(FKNetworkRequestSuccessCallback)success
                 andFailed:(FKNetworkRequestFailedCallback)failed;
@end
