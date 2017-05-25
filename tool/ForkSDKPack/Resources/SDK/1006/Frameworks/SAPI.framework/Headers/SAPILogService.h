//
//  SAPILogService.h
//  SAPILib
//
//  Created by Vinson.D.Warm on 11/26/13.
//  Copyright (c) 2013 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SAPIEnhancedLogItem) {
    PV_Login_EnhancedLog,
    Num_Login_VA_EnhancedLog,
    PV_SLogin_EnhancedLog,
    Num_SLogin_VA_EnhancedLog,
    PV_Reg_EnhancedLog,
    Num_Reg_VA_EnhancedLog,
    PV_QReg_EnhancedLog,
    Num_QReg_VA_EnhancedLog,
};

@interface SAPILogService : NSObject

- (void)silentLoginLog;

- (void)enhancedLogForItem:(SAPIEnhancedLogItem)logItem;

+ (SAPILogService *)sharedInstance;

@end
