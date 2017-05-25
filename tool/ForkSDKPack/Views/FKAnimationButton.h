//
//  FKAnimationButton.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseView.h"

@interface FKAnimationButton : NSButton
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong, readonly) BaseView *selectedView;
@property (nonatomic, strong, readonly) NSImageView *imageView;
@end
