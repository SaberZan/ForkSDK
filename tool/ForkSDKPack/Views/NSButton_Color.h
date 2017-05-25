//
//  NSButton+NSButton_Color.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorButtonCell : NSButtonCell
{
    BOOL bClick;
}
@property (nonatomic,retain) NSColor *normal;
@property (nonatomic,retain) NSColor *hover;
@property (nonatomic,retain) NSColor *push;
@property (nonatomic,retain) NSColor *disable;
@end

@interface NSButton (NSButton_Color)
- (void)setHoverColor:(NSColor *)textColor;
- (void)setNormalColor:(NSColor *)textColor;
- (void)setPushColor:(NSColor *)textColor;
- (void)setDisableColor:(NSColor *)textColor;
- (void)setHeightLight:(BOOL)b;
@end
