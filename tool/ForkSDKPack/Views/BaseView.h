//
//  BaseView.h
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragDropViewDelegate <NSObject>
-(void)dragDropViewStateChange:(id)userInfo;
-(void)dragDropViewFileList:(NSArray*)fileList;
-(void)dragDropViewDidEnd:(id)sender;
@end

@interface BaseView : NSView
@property (assign) IBOutlet id<DragDropViewDelegate> delegate;
@property (nonatomic, strong) NSColor *backgroundColor;

- (void)registerForDragged;
@end
