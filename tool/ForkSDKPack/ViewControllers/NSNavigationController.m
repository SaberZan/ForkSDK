//
//  NSNavigation.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/9.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//
/*
 _______  ______   ______   .       ______    _____    .
 |______ |      | |_____/   |   .  |______   |     \   |   ,
 |       |      | |    \    |__/          |  |      )  |__/
 |       |______| |     \_  |  \_.  ______|  |_____/   |  \_
 */
#import "NSNavigationController.h"
#import "BaseView.h"

static NSNavigationController* pStaticNav = nil;

@interface NSNavigationController ()<NSAnimationDelegate>
@property (nonatomic, strong) NSMutableArray *viewControllersQueue;
@end

@implementation NSNavigationController : NSViewController

- (id)init{
    self = [super init];
    [self _init];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    [self _init];
    return self;
}

- (void)loadView{
    self.view = [[BaseView alloc] initWithFrame:CGRectMake(0, 0, 900, 570)];
    [self.view addSubview:self.containerView];
}

- (void)_init{
    pStaticNav = self;
}

- (instancetype)initWithRootViewController:(NSViewController *)rootViewController{
    self = [self init];
    self.rootViewController = rootViewController;
    return self;
}

- (void)setRootViewController:(NSViewController *)rootViewController{
    _rootViewController = rootViewController;
    
    [self.viewControllersQueue addObject:rootViewController];
    [self addChildViewController:rootViewController];
    [self.containerView addSubview:rootViewController.view];
}

- (void)pushViewController:(NSViewController *)viewController
                  animated:(BOOL)animated{
    
    if ( !viewController ) {
        return;
    }
    
    NSViewController *fvc = [self.viewControllersQueue lastObject];
    NSView *fv = fvc.view;
    NSViewController *tvc = viewController;
    NSView *tv = viewController.view;
    
    [self addChildViewController:tvc];
    
    if ( !animated ){
        [self.containerView addSubview:tv];
        
        [fvc removeFromParentViewController];
        [fv removeFromSuperview];
        
    }else{
        CGRect r = tv.frame;
        r.origin.x = self.containerView.frame.size.width;
        tv.frame = r;
        
        [self.containerView addSubview:tv];
        
        r.origin.x = 0;
        
        CGRect r1 = fv.frame;
        r1.origin.x = -r1.size.width/2;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            fv.animator.frame = r1;
            tv.animator.frame = r;
            
        } completionHandler:^{
            [fvc removeFromParentViewController];
            [fv removeFromSuperview];
        }];
        [[NSAnimationContext currentContext] setDuration:0.6];
    }
    
    [self.viewControllersQueue addObject:viewController];
}

- (NSViewController *)popViewControllerAnimated:(BOOL)animated{
    if ( self.viewControllersQueue.count<=1 ) {
        return nil;
    }
    
    NSInteger count = self.viewControllersQueue.count;
    NSViewController *vc = self.viewControllersQueue[count-1-1];
    
    [self popToViewController:vc animated:animated];
    
    return vc;
}

- (NSArray *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated{
    do {
        if ( self.viewControllersQueue.count<=1 ) {
            break;
        }
        
        NSViewController *fvc = [self.viewControllersQueue lastObject];
        NSView *fv = fvc.view;
        NSViewController *tvc = viewController;
        NSView *tv = viewController.view;
        
        [self addChildViewController:tvc];
        
        
        void (^removeBlock)()  = ^(){
            //退出后面所有控制器
            NSInteger index = [self.viewControllersQueue indexOfObject:tvc];
            NSInteger count = self.viewControllersQueue.count;
            for (NSInteger i=index+1; i<count; i++) {
                NSViewController *temVc = self.viewControllersQueue[i];
                [temVc removeFromParentViewController];
                [temVc.view removeFromSuperview];
                [self.viewControllersQueue removeObject:temVc];
            }
        };
        
        if ( !animated ){
            
            CGRect r = tv.frame;
            r.origin.x = 0;
            tv.frame = r;
            
            [self.containerView addSubview:tv];
            
            removeBlock();
        }else{
            
            CGRect r = tv.frame;
            r.origin.x = -r.size.width/2;
            tv.frame = r;
            
            [self.containerView addSubview:tv];
            
            r.origin.x = 0;
            
            CGRect r1 = fv.frame;
            r1.origin.x = self.containerView.frame.size.width;
            
            [[NSAnimationContext currentContext] setDuration:0.4];
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                
                tv.animator.frame = r;
                fv.animator.frame = r1;
                
            } completionHandler:^{
                //退出后面所有控制器
                removeBlock();
            }];
        }
        
    } while (0);
    return self.viewControllersQueue;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    if ( self.viewControllersQueue.count<=1 ) {
        return nil;
    }
    NSViewController *vc = [self.viewControllersQueue firstObject];
    [self popToViewController:vc animated:animated];
    
    return self.viewControllersQueue;
}

- (NSMutableArray *)viewControllersQueue{
    if ( !_viewControllersQueue ) {
        _viewControllersQueue = [NSMutableArray new];
    }
    return _viewControllersQueue;
}

- (NSViewController *)topViewController{
    return [self.viewControllersQueue lastObject];
}

- (NSArray *)viewControllers{
    return [self.viewControllers copy];
}

- (NSView *)containerView{
    if (!_containerView){
        _containerView = [[BaseView alloc] initWithFrame:CGRectMake(0, 0, 900, 570)];
        _containerView.layer = [CALayer layer];
        _containerView.layer.backgroundColor=[NSColor greenColor].CGColor;
    }
    return _containerView;
}
@end


@implementation NSViewController (UINavigationController)
- (NSNavigationController *)navigationController{
    return pStaticNav;
}
@end
