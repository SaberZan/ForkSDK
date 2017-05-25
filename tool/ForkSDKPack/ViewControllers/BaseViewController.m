//
//  BaseViewController.m
//  ForkSDKPack
//
//  Created by ruikong on 15/10/22.
//  Copyright © 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */
#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( self.toBackButton ) {
        NSTrackingArea *trackingArea=[[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, self.toBackButton.frame.size.width, self.toBackButton.frame.size.height)
                                                                  options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited
                                                                    owner:self
                                                                 userInfo:nil];
        [self.toBackButton addTrackingArea:trackingArea];
        
        self.toBackButton.action = @selector(back:);
        self.toBackButton.target = self;
        
    }
    
    if ( self.toBackText ) {
        self.toBackText.alphaValue = 0;
    }
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        self.toBackText.alphaValue=1;
    } completionHandler:^{
        
    }];
    [[NSAnimationContext currentContext] setDuration:1];
}

- (void)mouseExited:(NSEvent *)theEvent{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        self.toBackText.alphaValue=0;
    } completionHandler:^{
        
    }];
    [[NSAnimationContext currentContext] setDuration:1];
}

- (void)drawBackground{
    //background
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [NSImage imageNamed:@"background_pattern.png"];
    imageView.imageScaling = NSImageScaleAxesIndependently;
    [self.view addSubview:imageView positioned:NSWindowBelow
               relativeTo:self.view.subviews[0]];
}

- (void)alert:(NSString *)text{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:text];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.view.window
                  completionHandler:nil];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
