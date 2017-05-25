//
//  PackageViewContoller.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/10.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "PackageViewContoller.h"
#import "BaseView.h"
#import "NSNavigationController.h"
#import "FileUtil.h"
#import "DataManager.h"

@interface PackageViewContoller ()<NSComboBoxDelegate,NSComboBoxDataSource>{
    @private
    NSArray *m_pCanPackagePlatform;
}
@end

@implementation PackageViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    //background
    [self drawBackground];
    
    m_pCanPackagePlatform = [[DataManager getInstance].config getCanUsePlatforms];
    
    //setup view
    self.platformType.usesDataSource = NO;
    self.targetsComboBox.usesDataSource = NO;
    
    //set plarform content
    NSMutableArray *platform_names = [NSMutableArray new];
    [platform_names addObject:@"全部已配置渠道"];
    for (NSNumber *platform_number in m_pCanPackagePlatform) {
        [platform_names addObject:PlatformNameFromPlatform( platform_number.intValue )];
    }
    [self.platformType addItemsWithObjectValues:platform_names];
    [self.platformType selectItemAtIndex:0];
    
    //set target names content
    NSArray *target_names_arr = [[FileUtil getInstance] getOriginalTargetsNames];
    [self.targetsComboBox addItemsWithObjectValues:target_names_arr];
    [self.targetsComboBox selectItemAtIndex:0];
    
    //set log block
    typeof(self) __weak _self = self;
    [FileUtil getInstance].logCallBack = ^(NSString *lineLog){
        [_self addLogString:lineLog];
    };
    
    //can package plarform
    if (m_pCanPackagePlatform.count<=0){
        self.packButton.enabled = NO;
    }
    self.indicatorView.hidden = YES;
    
    //log
    [self addLogString:@"##########################################################################"];
    [self addLogString:@"ForkSDK init"];
    [self addLogString:@"ready package..."];
    [self addLogString:@"wait package..."];
}

- (void)addLogString:(NSString *)msg{
    self.logTextView.string = [self.logTextView.string stringByAppendingFormat:@"\nForkSDK:%@", msg];
    [self.logTextView scrollToEndOfDocument:self];
}

- (IBAction)parkage:(id)sender{
    typeof(self) __weak _self = self;
    //no package platforms
    if (m_pCanPackagePlatform.count<=0){
        return;
    }
    //log test
    [self addLogString:@"packing..."];
    [self addLogString:@"mkdir build"];
    [self addLogString:@"cd build"];
    [self addLogString:@"cmake .."];
    [self addLogString:@"make"];
    
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimation:self];
    _self.packButton.enabled = NO;
    
    //target name
    NSArray *target_names_arr = [[FileUtil getInstance] getOriginalTargetsNames];
    NSString *target_name = target_names_arr[ [self.targetsComboBox indexOfSelectedItem] ];
    
    //平台
    int platform = (int)[self.platformType indexOfSelectedItem];
    //角标方向
    int angelType = (int)[self.angelType indexOfSelectedItem];
    
    if ( -1==platform ) {
        platform = 0;
    }
    
    if ( -1==angelType ) {
        angelType = 2;
    }
    
    //设置角标方向
    [DataManager getInstance].angelDirection = angelType;
    //设置是否打包IPA
    [DataManager getInstance].canGenerateIpa = self.generateIpaCheckBox.state;
    //target name
    [DataManager getInstance].buildTargetName = target_name;
    
    //处理打包平台
    NSArray *pack_platforms = nil;
    //全部平台
    if ( 0==platform ) {
        pack_platforms = [m_pCanPackagePlatform copy];
    }
    //单个平台
    else{
        pack_platforms = @[ m_pCanPackagePlatform[ platform-1 ] ];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        
        for (NSNumber *platformNumber in pack_platforms) {
            int t = [platformNumber intValue];
            [DataManager getInstance].platform = t;
            
            //生成支持文件
            [[FileUtil getInstance] makeSupportFiles];
            //复制，处理工程
            [[FileUtil getInstance] copyAndMakeXcodeproj];
        }
        
        //打包完毕回调主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"打包完毕 \n");
            [self addLogString:@"打包完毕"];
            
            _self.packButton.enabled = YES;
            _self.indicatorView.hidden = YES;
            [_self.indicatorView stopAnimation:self];
            
            [self alert:@"打包成功!"];
            
            [[NSWorkspace sharedWorkspace] openFile:[DataManager getInstance].base_project_dir];
            
        });
        
    });
}


@end
