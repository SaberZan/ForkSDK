//
//  BaseView.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (id)init{
    self = [super init];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.backgroundColor set];
    NSBezierPath *path = [NSBezierPath bezierPath];
//    NSRectFill( dirtyRect );
    [path appendBezierPathWithRoundedRect:[self bounds] xRadius:5.0 yRadius:5.0];
    [path fill];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor{
    _backgroundColor = backgroundColor;
    [self displayIfNeeded];
}

- (void)registerForDragged{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        if ( self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewStateChange:)]) {
            [self.delegate dragDropViewStateChange:sender];
        }
        return NSDragOperationLink;
    }
    
    return NSDragOperationNone;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、获取拖动数据中的粘贴板
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList:)]) {
        [self.delegate dragDropViewFileList:list];
    }
    return YES;
}


- (void)draggingExited:(id <NSDraggingInfo>)sender{
    [self dragEnd];
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
    [self dragEnd];
}
- (void)draggingEnded:(id <NSDraggingInfo>)sender{
    [self dragEnd];
}

- (void)dragEnd{
    if ( self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewDidEnd:)]) {
        [self.delegate dragDropViewDidEnd:self];
    }
}
@end
