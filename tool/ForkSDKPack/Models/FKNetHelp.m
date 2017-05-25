//
//  FKNetHelp.m
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/15.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKNetHelp.h"
#import "FKUrlParHelp.h"

static NSString *HttpMethodStringWithEnum(HttpMethod method){
    switch (method) {
        case GET:
            return @"GET";
            break;
        case POST:
            return @"POST";
            break;
        case PUT:
            return @"PUT";
            break;
        case PATCH:
            return @"PATCH";
            break;
        case DELETE:
            return @"DELETE";
            break;
        default:
            break;
    }
    return nil;
}

@implementation FKNetHelp

+ (instancetype)getInstance{
    static dispatch_once_t onceToken;
    static FKNetHelp *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FKNetHelp alloc] init];
    });
    return sharedInstance;
}


- (void)sendGetRequestWithUrl:(NSString*)url
                    withParms:(NSDictionary*)params
                  whenSuccess:(FKNetworkRequestSuccessCallback)success
                    andFailed:(FKNetworkRequestFailedCallback)failed{
    
    NSURL *getUrl = [FKUrlParHelp urlWithDictionary:params andBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:getUrl];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    
    [self _postNotication:0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self _postNotication:1];
                               
                               if ( connectionError ) {
                                   [self _postNotication:-1];
                                   failed( connectionError );
                               }
                               else
                               {
                                   NSDictionary *responseDic = [NSJSONSerialization
                                                              JSONObjectWithData:data
                                                              options:NSJSONReadingMutableLeaves
                                                              error:nil];
                                   success( responseDic );
                               }
                               
    }];
}

- (void)sendPostRequestWithUrl:(NSString*)url
                     withParms:(NSDictionary*)params
                   whenSuccess:(FKNetworkRequestSuccessCallback)success
                     andFailed:(FKNetworkRequestFailedCallback)failed{
    NSURL *postUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    if ( params && params.allKeys>0 ) {
        NSData *postDatas = [NSJSONSerialization
                             dataWithJSONObject:params
                             options:NSJSONWritingPrettyPrinted
                             error:nil];
        
        NSString *str = [[NSString alloc] initWithData:postDatas
                                              encoding:NSUTF8StringEncoding];
        postDatas = [NSData dataWithBytes:[str UTF8String] length:[str length]];
        
        [request setValue:[NSString stringWithFormat:@"%u",(unsigned int)postDatas.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postDatas];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30];
    
    [self _postNotication:0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self _postNotication:1];
                               if ( connectionError ) {
                                   [self _postNotication:-1];
                                   failed( connectionError );
                               }
                               else
                               {
                                   NSDictionary *responseDic = [NSJSONSerialization
                                                                JSONObjectWithData:data
                                                                options:NSJSONReadingMutableLeaves
                                                                error:nil];
                                   success( responseDic );
                               }
                               
                           }];
}


- (void)sendRequestWithUrl:(NSString *)url
                 withParms:(NSDictionary *)parmas
                    method:(HttpMethod)method
               whenSuccess:(FKNetworkRequestSuccessCallback)success
                 andFailed:(FKNetworkRequestFailedCallback)failed{
    
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    
    if ( parmas && parmas.allKeys>0 ) {
        NSData *requestDatas = [NSJSONSerialization
                             dataWithJSONObject:parmas
                             options:NSJSONWritingPrettyPrinted
                             error:nil];
        
        NSString *str = [[NSString alloc] initWithData:requestDatas
                                              encoding:NSUTF8StringEncoding];
        requestDatas = [NSData dataWithBytes:[str UTF8String] length:[str length]];
        
        [request setValue:[NSString stringWithFormat:@"%u",(unsigned int)requestDatas.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:requestDatas];
    }
    
    [request setHTTPMethod: HttpMethodStringWithEnum(method) ];
    [request setTimeoutInterval:30];
    
    [self _postNotication:0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self _postNotication:1];
                               if ( connectionError ) {
                                   [self _postNotication:-1];
                                   failed( connectionError );
                               }
                               else
                               {
                                   NSDictionary *responseDic = [NSJSONSerialization
                                                                JSONObjectWithData:data
                                                                options:NSJSONReadingMutableLeaves
                                                                error:nil];
                                   success( responseDic );
                               }
                               
                           }];
}

- (void)_postNotication:(int)status{
    if ( 0==status )
        [[NSNotificationCenter defaultCenter] postNotificationName:kFKNotificationConsts_NetworkBegin
                                                            object:self];
    else if ( 1==status )
        [[NSNotificationCenter defaultCenter] postNotificationName:kFKNotificationConsts_NetworkEnd
                                                            object:self];
    else if ( -1==status )
        [[NSNotificationCenter defaultCenter] postNotificationName:kFKNotificationConsts_NetworkError
                                                            object:self];
}
@end
