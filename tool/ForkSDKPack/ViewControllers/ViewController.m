//
//  ViewController.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/8.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */

#import "ViewController.h"
#import "BaseView.h"
#import "NSNavigationController.h"
#import "ConfigurationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"

@interface ViewController ()<DragDropViewDelegate>{
    int _selectType;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectType = 0;
    
    //background
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [NSImage imageNamed:@"background_pattern.png"];
    imageView.imageScaling = NSImageScaleAxesIndependently;
    [self.view addSubview:imageView positioned:NSWindowBelow
               relativeTo:self.view.subviews[0]];
    
    //set tracking area
    NSTrackingArea *trackingArea=[[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.exportButton.frame.size.width, self.exportButton.frame.size.height)
                                  options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited
                                  owner:self
                                  userInfo:nil];
    
    [self.exportButton addTrackingArea:trackingArea];
    
    trackingArea=[[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.nextButton.frame.size.width, self.nextButton.frame.size.height)
                                                              options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited
                                                                owner:self
                                                             userInfo:@{@"key":@"value"}];
    [self.nextButton addTrackingArea:trackingArea];
    
    self.importText.alphaValue=0;
    self.nextText.alphaValue=0;
    self.nextButton.enabled = NO;
    [DataManager getInstance].base_xcodeproj_dir = @"/Users/ruikong/Desktop/ForkSDK/IOS/demotest/demotest.xcodeproj";
    [DataManager getInstance].platform = 1004;
    [DataManager getInstance].originImage = [[NSImage alloc] initWithContentsOfFile:@"/Users/ruikong/Desktop/ForkSDK/IOS/demotest/icon.png"];
    
    self.exportButton.target = self;
    self.exportButton.action = @selector(importAction);
    self.nextButton.target = self;
    self.nextButton.action = @selector(nextAction);
    
    self.helpButton.target = self;
    self.helpButton.action = @selector(helpAction:);
    
    //拖拽View
    BaseView *drapView = [[BaseView alloc] initWithFrame:self.view.frame];
    drapView.backgroundColor=[NSColor clearColor];
    [drapView registerForDragged];
    drapView.delegate = self;
    [self.view addSubview:drapView];
    
}

-(void)dragDropViewStateChange:(id)userInfo{
    [self.addFileButton setImage:[NSImage imageNamed:@"+_overlay.png"]];
}

-(void)dragDropViewFileList:(NSArray*)fileList{
    NSLog(@"dragDropViewFileList %@\n",fileList);
    if ( [fileList count]>0 ) {
        
        NSString *filePath = fileList[0];
        
        if ( _selectType==0 ) {
            if ( ![[DataManager getInstance] isAvailableProjectPath:filePath] ) {
                [self alert:@"请选择正确的工程文件?"];
                return;
            }
            
            [DataManager getInstance].base_xcodeproj_dir = filePath;
            
            self.titleText.stringValue = @"请选择项目ICON图片(尽量大一点，建议512*512或1024*1024)";
            
            _selectType = 1;
        }
        else{
            
            if ( ![[DataManager getInstance] isAvailableImagePath:filePath] ) {
                [self alert:@"请选择正确的ICON图片?"];
                return;
            }
            
            self.titleText.stringValue = @"请点击下一步，进行平台配置";
            
            [DataManager getInstance].originImagePath = filePath;
            
            [self.imageButton setImage:[DataManager getInstance].originImage];
            
            self.nextButton.enabled = YES;
        }

    }
}

- (void)alert:(NSString *)text{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:text];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.view.window
                  completionHandler:nil];
}

-(void)dragDropViewDidEnd:(id)sender{
    [self.addFileButton setImage:[NSImage imageNamed:@"+_normal.png"]];
}

- (void)nextAction{
    ConfigurationViewController *configViewController = [self.storyboard instantiateControllerWithIdentifier:@"ConfigurationViewController"];
    [self.navigationController pushViewController:configViewController animated:YES];
}

- (void)importAction{
    
    [self seleFile];
}

-(void)helpAction:(NSButton*)sender{
    NSPopover *popover = [[NSPopover alloc] init];
    [popover setBehavior: NSPopoverBehaviorTransient];
    NSViewController *vc = [self.storyboard instantiateControllerWithIdentifier:@"poper"];
    [popover setContentViewController:vc];
    [popover setContentSize:vc.view.frame.size];
    [popover showRelativeToRect: NSMakeRect(CGRectGetMinX(sender.frame)-5, CGRectGetMaxY(sender.frame)-CGRectGetHeight(sender.frame)/2, 5, 5)
                         ofView: self.view
                  preferredEdge: NSMaxXEdge];
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        if ( !theEvent.trackingArea.userInfo ) {
            self.importText.alphaValue=1;
        }
        else
        {
            if (self.nextButton.enabled)
            self.nextText.alphaValue=1;
        }
    } completionHandler:^{
        
    }];
    [[NSAnimationContext currentContext] setDuration:1];
    
}

- (void)mouseExited:(NSEvent *)theEvent{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        if ( !theEvent.trackingArea.userInfo ) {
            self.importText.alphaValue=0;
        }
        else
        {
            if (self.nextButton.enabled)
            self.nextText.alphaValue=0;
        }
    } completionHandler:^{
        
    }];
    [[NSAnimationContext currentContext] setDuration:1];
}

- (void)menuAction:(id)sender{
    NSViewController* viewController = [self.storyboard instantiateControllerWithIdentifier:@"dabao"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)seleFile{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:_selectType==0?@"请选择 工程文件.xcodeproj":@"请选择 工程ICON文件.png(建议大于等于512*512)"];
    [panel setPrompt:@"确定"];
    panel.canChooseDirectories=YES;
    panel.canChooseFiles = YES;
    panel.allowedFileTypes = @[@"xcodeproj",@"png"];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if ( 1==result ) {
            NSLog(@"%@",panel.URLs);
            NSArray *urls = panel.URLs;
            if ( urls.count<=0 ) {
                return;
            }
            NSString *filePath = [[urls firstObject] path];
            
            if ( _selectType==0 ) {
                if ( ![[DataManager getInstance] isAvailableProjectPath:filePath] ) {
                    [self alert:@"请选择正确的工程文件?"];
                    return;
                }
                
                [DataManager getInstance].base_xcodeproj_dir = filePath;
                
                self.titleText.stringValue = @"请选择项目ICON图片(尽量大一点，建议512*512或1024*1024)";
                
                _selectType = 1;
            }
            else{
                
                if ( ![[DataManager getInstance] isAvailableImagePath:filePath] ) {
                    [self alert:@"请选择正确的ICON图片?"];
                    return;
                }
                
                self.titleText.stringValue = @"请点击下一步，进行平台配置";
                
                [DataManager getInstance].originImagePath = filePath;
                
                [self.imageButton setImage:[DataManager getInstance].originImage];
                
                self.nextButton.enabled = YES;
            }
            
        }
    }];
}
@end
