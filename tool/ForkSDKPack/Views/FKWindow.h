//
//  FKWindow.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/8.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FKWindow : NSWindow
@property (nonatomic, strong) NSView *titleTopView;
@property (nonatomic) NSButton *closeButton;
@property (nonatomic) NSButton *minButton;
@property (nonatomic) NSButton *maxButton;
@end
