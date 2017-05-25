//
//  FKAnimationButton.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FKAnimationButton.h"

@interface FKAnimationButton (){
    NSTimer *m_timer;
    NSInteger n_offset_y;
}
@end

@implementation FKAnimationButton
@synthesize selectedView = _selectedView;
@synthesize imageView = _imageView;

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    [self _init];
    return self;
}

- (void)awakeFromNib{
    [self _init];
}

- (void)_init{
    self.backgroundColor = [NSColor orangeColor];
    self.layer = [CALayer layer];
    self.layer.backgroundColor = [NSColor orangeColor].CGColor;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds=YES;
    [self addSubview:self.selectedView];
    [self.selectedView addTrackingRect:self.selectedView.frame owner:self userData:nil assumeInside:NO];
    [self addSubview:self.imageView];
}

- (void)startTimer{

}

- (void)update:(id)t{
    
    CGRect r = self.selectedView.frame;
    if ( n_offset_y>15 ) {
        n_offset_y--;
        r.origin.y--;
    }
    else{
        n_offset_y++;
        r.origin.y++;
    }

    self.selectedView.frame = r;
}

- (void)mouseEntered:(NSEvent *)theEvent{
    self.selectedView.alphaValue = 0.4;
    [m_timer fire];
}

- (void)mouseExited:(NSEvent *)theEvent{
    self.selectedView.alphaValue = 0;
    [m_timer invalidate];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.backgroundColor set];
    NSRectFill( dirtyRect );
}

- (BaseView *)selectedView{
    if ( !_selectedView ) {
        _selectedView = [[BaseView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _selectedView.backgroundColor = [NSColor whiteColor];
        _selectedView.alphaValue = 0;
    }
    return _selectedView;
}

- (NSImageView *)imageView{
    if ( !_imageView  ) {
        _imageView = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _imageView;
}

@end
