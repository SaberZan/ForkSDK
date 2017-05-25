//
//  TitleTopView.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/8.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "TitleTopView.h"
#import "NSButton_Color.h"

@interface TitleTopView (){
    NSMutableArray *m_buttons;
}
@end
@implementation TitleTopView

- (void)awakeFromNib{
    self.backgroundColor = [NSColor colorWithCalibratedRed:0.016f green:0.306f blue:0.580f alpha:1.00f];
    
    m_buttons = [NSMutableArray new];
    for (int i=100; i<104; i++) {
        NSButton *button = [(NSView *)self viewWithTag:i];
        if ( button ) {
            [m_buttons addObject:button];
            [button setNormalColor:[NSColor whiteColor]];
            [button setHoverColor:[NSColor redColor]];
        }
    }
    
    [self addTrackingRect:[self bounds]
                    owner:self
                 userData:nil
             assumeInside:NO];
    
}

- (void)mouseDown:(NSEvent *)theEvent{
//    for (NSButton *button in m_buttons) {
//        NSPoint pointInView = [theEvent locationInWindow];
//        // 判断是否点击在改变窗口大小区域
//        BOOL resize = NSPointInRect(pointInView, button.frame);
//    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    
}

- (void)mouseExited:(NSEvent *)theEvent{
    
}

- (void)mouseUp:(NSEvent *)theEvent{

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
}

@end
