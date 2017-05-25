//
//  MyNavigateion.m
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
#import "MyNavigateion.h"

@interface MyNavigateion ()@end

@implementation MyNavigateion

- (id)init{
    self = [super init];
    [self drawView];
    return self;
}

- (void)drawView{
    NSViewController *vc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"RootViewController"];
    self.rootViewController = vc;
}

- (id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    [self drawView];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
