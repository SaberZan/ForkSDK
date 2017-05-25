//
//  FKWindow.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/8.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKWindow.h"
#import "_NSThemeWidgetCell.h"
#import <objc/runtime.h>

__weak FKWindow *myWindow;  //point to our window object
CFStringRef (* originalIMP)(id self, SEL _cmd);    //the original coreUIWidgetState;
BOOL hover=NO;				//indicates rollover state


static CFStringRef myCoreUIWidgetState(id self, SEL _cmd)
{
    if (self==myWindow.maxButton.cell || self==myWindow.minButton.cell || self==myWindow.closeButton.cell) {
        if (((NSButtonCell *)self).highlighted) {
            return (__bridge CFStringRef)@"pressed";
        }
        return hover?(__bridge CFStringRef)@"rollover":(__bridge CFStringRef)@"normal";
    }
    
    return originalIMP(self,_cmd);
}

@implementation FKWindow

@synthesize closeButton = _closeButton;
@synthesize minButton = _minButton;
@synthesize maxButton = _maxButton;

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

- (void)awakeFromNib{
    myWindow=self;
    // Method Swizzling
    Method coreUIWidgetStateMethod=class_getInstanceMethod([_NSThemeWidgetCell class], @selector(coreUIState));
    const char *encoding=method_getTypeEncoding(coreUIWidgetStateMethod);
    originalIMP=(void*)method_getImplementation(coreUIWidgetStateMethod);
    class_replaceMethod([_NSThemeWidgetCell class], @selector(coreUIState), (IMP)myCoreUIWidgetState, encoding);
    
//    [self.contentView addSubview:self.titleTopView];
    _closeButton=[NSWindow standardWindowButton:NSWindowCloseButton forStyleMask:0 ];
    _minButton=[NSWindow standardWindowButton:NSWindowMiniaturizeButton forStyleMask:0 ];
    _maxButton=[NSWindow standardWindowButton:NSWindowZoomButton forStyleMask:0 ];
    
    [self.contentView addSubview:_closeButton];
    [self.contentView addSubview:_minButton];
    [self.contentView addSubview:_maxButton];
    
    [_closeButton setFrameOrigin:CGPointMake(5, [self.contentView frame].size.height-_closeButton.frame.size.height-5)];
    [_minButton setFrameOrigin:CGPointMake(25, _closeButton.frame.origin.y)];
    [_maxButton setFrameOrigin:CGPointMake(45, _closeButton.frame.origin.y)];
    
    //make angel
    [self.contentView setLayer:[CALayer layer]];
    [self.contentView layer].cornerRadius = 10;
    [self.contentView layer].masksToBounds=YES;
    ((NSView *)self.contentView).wantsLayer = YES;
    
    //set tracking area
    NSTrackingArea *trackingArea=[[NSTrackingArea alloc]initWithRect:CGRectMake(0, 0, _closeButton.frame.size.width*4, _closeButton.frame.size.height) options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    [_closeButton addTrackingArea:trackingArea];
    
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    hover=YES;
    [self setTitleButtonsNeedDisplay];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    hover=NO;
    [self setTitleButtonsNeedDisplay];
}

-(BOOL)canBecomeKeyWindow
{
    return YES;
}

-(void)setTitleButtonsNeedDisplay{
    [_closeButton setNeedsDisplay:YES];
    [_maxButton setNeedsDisplay:YES];
    [_minButton setNeedsDisplay:YES];
}

-(void)becomeKeyWindow
{
    [super becomeKeyWindow];
    [self setTitleButtonsNeedDisplay];
}

-(void)resignKeyWindow
{
    [super resignKeyWindow];
    [self setTitleButtonsNeedDisplay];
}


- (void)showOrHideTopBar:(BOOL)isShow{
    NSLog(@"%@ \n",isShow?@"显示":@"隐藏");
    NSRect startFrame = self.titleTopView.frame;
    NSRect endFrame = NSMakeRect(0,isShow?(CGRectGetHeight(self.frame)-CGRectGetHeight(startFrame)):CGRectGetHeight(self.frame), startFrame.size.width, startFrame.size.height);
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.titleTopView,NSViewAnimationTargetKey,NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,[NSValue valueWithRect:startFrame],NSViewAnimationStartFrameKey,[NSValue valueWithRect:endFrame],NSViewAnimationEndFrameKey, nil];
    
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[dictionary]];
    animation.duration = 1;
    [animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
    [animation startAnimation];
}

- (BOOL)canBecomeMainWindow {
    return YES;
}


- (NSRect)resizeAreaRect {
    const CGFloat resizeBoxSize = 20.0;
    
    // 窗口右下角 20x20 的区域为改变窗口的区域
    NSRect frame = [self frame];
    NSRect resizeRect = NSMakeRect(frame.size.width - resizeBoxSize, 0,
                                   resizeBoxSize, resizeBoxSize);
    
    return resizeRect;
}


// 处理鼠标按下事件
- (void)mouseDown:(NSEvent *)event {
    NSPoint pointInView = [event locationInWindow];
    
    // 判断是否点击在改变窗口大小区域
    BOOL resize = NSPointInRect(pointInView, [self resizeAreaRect]);
    
    NSWindow *window = self;
    NSPoint originalMouseLocation = [window convertBaseToScreen:[event locationInWindow]];
    NSRect originalFrame = [window frame];
    
    while (YES) {
        // 捕获鼠标拖动或鼠标按键弹起事件
        NSEvent *newEvent = [window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        
        if ([newEvent type] == NSLeftMouseUp) {
            break;
        }
        
        // 计算鼠标移动的偏移
        NSPoint newMouseLocation = [window convertBaseToScreen:[newEvent locationInWindow]];
        NSPoint delta = NSMakePoint(newMouseLocation.x - originalMouseLocation.x,
                                    newMouseLocation.y - originalMouseLocation.y);
        
        NSRect newFrame = originalFrame;
        
        if (!resize) {
            // 移动窗口
            newFrame.origin.x += delta.x;
            newFrame.origin.y += delta.y;
            
        } else {
            NSSize maxSize = [window maxSize];
            NSSize minSize = [window minSize];
            
            // 改变窗口大小
            newFrame.size.width += delta.x;
            newFrame.size.height -= delta.y;
            
            // 控制窗口大小在限制范围内
            newFrame.size.width = MIN(MAX(newFrame.size.width, minSize.width), maxSize.width);
            newFrame.size.height = MIN(MAX(newFrame.size.height, minSize.height), maxSize.height);
            newFrame.origin.y -= newFrame.size.height - originalFrame.size.height;
        }
        
        [window setFrame:newFrame display:YES animate:NO];
    }
}

- (NSView *)titleTopView{
    if ( !_titleTopView ) {
        NSArray *views;
        [[NSBundle mainBundle] loadNibNamed:@"TitleTopView"
                                      owner:nil
                            topLevelObjects:&views];
        for (id object in views) {
            if ( [object isKindOfClass:[NSView class]] ) {
                _titleTopView = object;
                break;
            }
        }
    }
    return _titleTopView;
}

-(void)dealloc
{
    Method coreUIWidgetStateMethod=class_getInstanceMethod([_NSThemeWidgetCell class], @selector(coreUIState));
    const char *encoding=method_getTypeEncoding(coreUIWidgetStateMethod);
    class_replaceMethod([_NSThemeWidgetCell class], @selector(coreUIState), (IMP)originalIMP, encoding);
}
@end
