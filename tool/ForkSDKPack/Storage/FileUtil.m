//
//  FileUtil.m
//  ForkSDKPack
//
//  Created by ruikong on 15/8/11.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#import "FileUtil.h"
#import "DataManager.h"
#import "XCProject.h"
#import "XCTarget.h"
#import "XCProjectBuildConfig.h"
#import "XcodeSourceFileType.h"
#import "XCSourceFile.h"
#import "XCGroup.h"
#import "XCSourceFileDefinition.h"


#define FORK_SDK_NAME @"ForkSDK"

@implementation FileUtil

+ (instancetype)getInstance{
    static dispatch_once_t onceToken;
    static FileUtil *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FileUtil alloc] init];
    });
    return sharedInstance;
}

- (BOOL)canAddFile:(NSString *)fileName{
    NSString *file_name = [fileName lastPathComponent];

    NSArray *suffixs = @[@".bundle",
                         @".framework",
                         @".a",
                         @".dylib",
                         @".tbd",
                         @".png",
                         @".xcassets",
                         @".plist",
                         @".h",
                         @".m",
                         @".mm",
                         @".cpp"];
    for (NSString *ext in suffixs) {
        if ( [file_name hasSuffix:ext] ) {
            return YES;
        }
    }
    return NO;
}

- (XcodeSourceFileType)typeWithFileName:(NSString *)fileName{
    NSString *file_name = [fileName lastPathComponent];
    if ( [file_name hasSuffix:@".bundle"] ) {
        return Bundle;
    }
    else if ( [file_name hasSuffix:@".framework"] ){
        return Framework;
    }
    else if ( [file_name hasSuffix:@".a"] ){
        return Archive;
    }
    else if ( [file_name hasSuffix:@".dylib"] ){
        return Archive;
    }
    else if ( [file_name hasSuffix:@".tbd"] ){
        return DylibTbdDef;
    }
    else if ( [file_name hasSuffix:@".png"] ){
        return ImageResourcePNG;
    }
    else if ( [file_name hasSuffix:@".xcassets"] ){
        return AssetCatalog;
    }
    else if ( [file_name hasSuffix:@".plist"] ){
        return PropertyList;
    }
    else if ( [file_name hasSuffix:@".h"] ){
        return SourceCodeHeader;
    }
    else if ( [file_name hasSuffix:@".mm"] ){
        return SourceCodeObjCPlusPlus;
    }
    else if ( [file_name hasSuffix:@".m"] ){
        return SourceCodeObjC;
    }
    else if ( [file_name hasSuffix:@".cpp"] ){
        return SourceCodeCPlusPlus;
    }
    else if ( [file_name hasSuffix:@".xib"] ){
        return XibFile;
    }

    return FileTypeNil;
}

- (NSString *)fileNameWithPath:(NSString *)path{
    if ( !path ) {
        return nil;
    }
    path = [path lastPathComponent];
    NSArray *file_name_arr = [path componentsSeparatedByString:@"."];
    if ( file_name_arr.count>0 ) {
        return file_name_arr[0];
    }
    return nil;
}

- (NSString *)documentForkSDKPath{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:@"ForkSDK"];
    return path;
}

- (NSString *)fromForkSDKPath{
    NSString *p = [[NSBundle mainBundle] bundlePath];
    p=[p stringByAppendingPathComponent:[NSString stringWithFormat:@"/Contents/Resources/SDK/"]];
    return p;
}

- (NSString *)fromChannelSDKPathWithIndex:(int)platform{
    NSString *formForkSDKPath = [self fromForkSDKPath];
    return [formForkSDKPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%d",platform]];
}

- (NSString *)toForkSDKPath{
    NSString *project_dir = [DataManager getInstance].base_project_dir;
    return [project_dir stringByAppendingPathComponent:@"/ForkSDK"];
}

- (NSString *)toChannelSDKPathWithIndex:(int)platform{
    NSString *toForkSDKPath = [self toForkSDKPath];
    return [toForkSDKPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%d",platform]];
}

- (NSDictionary *)toChannelSDKPaths{
    NSString *channelSDKPath = [self toChannelSDKPathWithIndex:[DataManager getInstance].platform];
    NSMutableDictionary *channelDic = [NSMutableDictionary new];
    channelDic[@"config"] = [channelSDKPath stringByAppendingPathComponent:@"/config.plist"];
    channelDic[@"developerinfo"] = [channelSDKPath stringByAppendingPathComponent:@"/developerinfo.plist"];
    channelDic[@"framework"] = [channelSDKPath stringByAppendingPathComponent:@"/Frameworks"];
    channelDic[@"icon"] = [channelSDKPath stringByAppendingPathComponent:@"/icon"];
    channelDic[@"images"] = [channelSDKPath stringByAppendingPathComponent:@"/Images.xcassets/AppIcon.appiconset"];
    return channelDic;
}

- (NSString *)getAngelFileNameWithDirection:(int)direction{
    NSArray *arr = @[@"left-top.png", @"right-top.png", @"right-bottom.png", @"left-bottom.png"];
    return arr[direction];
}

- (NSMutableArray *)iconsFiles{
    NSMutableArray *arr = [NSMutableArray new];
    [arr addObject:@[@"Icon-29.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(29, 29))]]];
    [arr addObject:@[@"Icon-40.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(40, 40))]]];
    [arr addObject:@[@"Icon-50.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(50, 50))]]];
    [arr addObject:@[@"Icon-57.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(57, 57))]]];
    [arr addObject:@[@"Icon-58.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(58, 58))]]];
    [arr addObject:@[@"Icon-72.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(72, 72))]]];
    [arr addObject:@[@"Icon-76.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(76, 76))]]];
    [arr addObject:@[@"Icon-80.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(80, 80))]]];
    [arr addObject:@[@"Icon-87.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(87, 87))]]];
    [arr addObject:@[@"Icon-100.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(100, 100))]]];
    [arr addObject:@[@"Icon-114.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(114, 114))]]];
    [arr addObject:@[@"Icon-120.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(120, 120))]]];
    [arr addObject:@[@"Icon-144.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(144, 144))]]];
    [arr addObject:@[@"Icon-152.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(152, 152))]]];
    [arr addObject:@[@"Icon-180.png",[NSValue valueWithSize:NSSizeFromCGSize(CGSizeMake(180, 180))]]];
    return arr;
}

- (void)copyDir:(NSString *)form_dir
          toDir:(NSString *)to_dir{
    do {
        NSFileManager *f = [NSFileManager defaultManager];
        
        if ( ![f fileExistsAtPath:form_dir] ) {
            break;
        }
        
        if ( ![f fileExistsAtPath:to_dir] ) {
            NSError *error = nil;
            [f copyItemAtPath:form_dir
                       toPath:to_dir
                        error:&error];
        }
    } while (0);
}

- (void)copyFile:(NSString *)filePath
      toFilePath:(NSString *)toFilePath{
    do {
        NSFileManager *f = [NSFileManager defaultManager];
        if ( ![f fileExistsAtPath:filePath] ) {
            NSLog(@"ERROR！要拷贝的文件不存在\n");
            break;
        }
        
        if ( ![f fileExistsAtPath:filePath] ) {
            NSError *error = nil;
            [f copyItemAtPath:filePath
                       toPath:filePath
                        error:&error];
        }
        
    } while (0);
}

-(NSImage *)addImage:(NSImage *)image1 toImage:(NSImage *)image2
{
    NSImage *background = image1;
    NSImage *overlay = image2;
    NSImage *newImage = [[NSImage alloc] initWithSize:CGSizeMake(512/2, 512/2)];
    [newImage lockFocus];
    CGRect newImageRect = CGRectZero;
    newImageRect.size = newImage.size;
    [background drawInRect:newImageRect];
    [overlay drawInRect:newImageRect];
    [newImage unlockFocus];
    CGImageRef newImageRef = [newImage CGImageForProposedRect:NULL context:nil hints:nil];
    return [[NSImage alloc] initWithCGImage:newImageRef size:NSSizeFromCGSize(newImageRect.size)];
}

- (NSImage *)reSizeImage:(NSImage *)image toSize:(CGSize)size{
    NSImage *newImage = [[NSImage alloc] initWithSize:CGSizeMake(size.width/2, size.height/2)];
    [newImage lockFocus];
    
    CGRect newImageRect = CGRectZero;
    newImageRect.size = newImage.size;
    
    [image drawInRect:newImageRect];
    [newImage unlockFocus];
    CGImageRef newImageRef = [newImage CGImageForProposedRect:NULL context:nil hints:nil];
    
    return [[NSImage alloc] initWithCGImage:newImageRef size:NSSizeFromCGSize(newImageRect.size)];
}

- (NSImage *)make512x512IconImageWith:(NSImage *)originImage
                                 cornerMaskImagePath:(NSString *)cornerMaskImagePath
                           saveToPath:(NSString *)saveToPath{
    
    NSImage *originImg = originImage;
    NSImage *maskImg = [[NSImage alloc] initWithContentsOfFile:cornerMaskImagePath];
    NSImage *maked512Image = [self addImage:originImg
                                   toImage:maskImg];
    //save
    NSData *imageData = maked512Image.TIFFRepresentation;
    [imageData writeToFile:saveToPath atomically:YES];
    
    return maked512Image;
}

//生成支持文件 (拷贝ForkSDK-->拷贝源工程info.plist-->生成角标-->生成developerinfo.plist文件)
- (void)makeSupportFiles{
    DataManager *data_manager = [DataManager getInstance];
    NSFileManager *file_manager = [NSFileManager defaultManager];
    //打包平台Code
    int platform = data_manager.platform;
    //角标方向
    int angelDirection = data_manager.angelDirection;
    //屏幕支持的方向
    NSString*screenDirection = data_manager.screenDirection;
    //选择的icon图片
    NSImage *originImage = [DataManager getInstance].originImage;
    
    //拷贝ForkSDK
    if ( ![file_manager fileExistsAtPath:self.toForkSDKPath] ) {
        
        [file_manager createDirectoryAtPath:self.toForkSDKPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    //工程里的渠道支持文件路径
    NSString *fromChannelSDKPath = [self fromChannelSDKPathWithIndex:platform];
    //要拷贝到的渠道支持文件路径
    NSString *toChannelSDKPath = [self toChannelSDKPathWithIndex:platform];
    
    //如果渠道文件存在，删除
    if ( [file_manager fileExistsAtPath:toChannelSDKPath] ) {
        [file_manager removeItemAtPath:toChannelSDKPath error:nil];
    }
    
    //拷贝渠道支持文件
    [self copyDir:fromChannelSDKPath
            toDir:toChannelSDKPath];
    
    //要生成的512*512文件名称
    NSString *make512x512ImagePath = [toChannelSDKPath stringByAppendingString:@"/icon512x512.png"];
    //角标mask文件路径
    NSString *angelFilePath = [toChannelSDKPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/icon/%@",[self getAngelFileNameWithDirection:angelDirection]]];
    
    //生成icon512x512.png（角标）
    NSImage *make512x512Image = [self make512x512IconImageWith:originImage
               cornerMaskImagePath:angelFilePath
                        saveToPath:make512x512ImagePath];
    
    //删除平台角标mask文件
    [file_manager removeItemAtPath:[toChannelSDKPath stringByAppendingPathComponent:@"/icon"]
                                               error:nil];
    
    //通过icon512x512.png缩小生成16种尺寸ICON
    NSArray *icon_arr = self.iconsFiles;
    for (NSArray *pIcon in icon_arr) {
        NSImage *reSizeImage = [self reSizeImage:make512x512Image
                                          toSize:[pIcon[1] sizeValue]];
        NSString *saveToPath = [self.toChannelSDKPaths[@"images"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",pIcon[0]]];
        //save
        NSData *imageData = reSizeImage.TIFFRepresentation;
        [imageData writeToFile:saveToPath
                    atomically:NO];
    }
    
    //生成 developerInfo.plist
    NSString *developerinfo_path = self.toChannelSDKPaths[@"developerinfo"];
    [[DataManager getInstance].config saveConfigFileWithChannelCode:platform
                                                           dirction:screenDirection
                                                           filePath:developerinfo_path];
    
    NSLog(@"渠道SDK拷贝制作完成！\n");
}

- (XCTarget *)findTarget:(XCProject *)project projectName:(NSString *)name{
    for (XCTarget* ta in project.targets) {
        if ( [ta isEqualTo:name] ) {
            return ta;
        }
    }
    return [project.targets firstObject];
}

- (void)copyAndMakeXcodeproj{
    NSLog(@"开始拷贝和配置 渠道平台...\n");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    DataManager *dataManager = [DataManager getInstance];
    
    //工程配置文件路径
    NSString *xcodeproje_dir = dataManager.base_xcodeproj_dir;
    //切割工程配置文件名字
    NSArray *xcodeprojeArr = [[xcodeproje_dir lastPathComponent] componentsSeparatedByString:@"."];
    //工程名字
    NSString *project_name = xcodeprojeArr[0];
    //build target name
    NSString *target_name = dataManager.buildTargetName;
    NSString *platform_str = [NSString stringWithFormat:@"%d",dataManager.platform];
    //新工程配置文件路径
    NSString *newXcodeprojeName = [dataManager.base_project_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@-%d.%@",project_name,dataManager.platform,xcodeprojeArr[1]]];
    
    //如果新的工程已经存在，先删除
    if ( [fileManager fileExistsAtPath:newXcodeprojeName] ) {
        [fileManager removeItemAtPath:newXcodeprojeName
                                error:nil];
    }
    
    //复制旧的文件配置到新的配置
    [self copyDir:dataManager.base_xcodeproj_dir
            toDir:newXcodeprojeName];
    
    //修改新工程的.xcscheme 文件
    [self makeXcschemeFileDataWithProjectPath:newXcodeprojeName];
    
    //配置新的工程
    self.projectManager = [[XCProject alloc] initWithFilePath:newXcodeprojeName];
    
    //获取Target
    self.projectTarget = [self findTarget:self.projectManager projectName:target_name];
    
    //获取新的工程的Images.xcassets || Assets.xcassets
    XCSourceFile *images_xcassets_source = [self.projectManager fileWithName:@"Images.xcassets"];
    if ( !images_xcassets_source ) {
        images_xcassets_source = [self.projectManager fileWithName:@"Assets.xcassets"];
    }
    
    if ( images_xcassets_source ) {
        //移除编译
        [self.projectTarget removeMemberWithKey:images_xcassets_source.key];
        //项目移除引用
        [self.projectManager.objects removeObjectForKey:images_xcassets_source.key];
        //保存更改
        [self.projectManager save];
    }
    
    //获取根目录
    XCGroup* root_group = [self.projectManager rootGroup];
    
    //添加 ForkSDK 文件夹到根目录
    XCGroup* forksdk_group = [root_group addGroupWithPath:FORK_SDK_NAME];
    [self.projectManager save];
    
    //配置到渠道的SDK路径 /ForkSDK/平台Code
    NSString *to_channel_path = [self toChannelSDKPathWithIndex:dataManager.platform];
    
    //打包工具中的SDK渠道路径
    NSString *form_channel_path = [FORK_SDK_NAME stringByAppendingPathComponent:platform_str];
    
    //添加系统依赖库
    NSArray *configs_arr = [[NSArray alloc] initWithContentsOfFile:self.toChannelSDKPaths[@"config"]];
    
    for (NSDictionary *config_dir in configs_arr) {
        NSString *path = @"System/Library/Frameworks";
        NSString *name = config_dir[@"name"];
        if ( [config_dir[@"path"] isEqualToString:@"usrlib"] ) {
            path = @"usr/lib";
            
            if ( ![fileManager fileExistsAtPath:[path stringByAppendingPathComponent:name]] ) {
                NSArray *tem_arr = [name componentsSeparatedByString:@"."];
                if ( tem_arr && tem_arr.count>0 ) {
                    name = [NSString stringWithFormat:@"%@.tbd",tem_arr[0]];
                }
            }
        }
        
        path = [path stringByAppendingPathComponent:name];
    
        //文件类型
        XcodeSourceFileType type = [self typeWithFileName:name];
        
        if ( type==Framework || type==Archive || type==DylibTbdDef ) {
            XCSourceFileDefinition *frameworkDefinition = [[XCSourceFileDefinition alloc] initWithFilePath:path type:type];
            [forksdk_group addFramework:frameworkDefinition
                            isSystem:YES
                                    type:type
                                toTarget:@[self.projectTarget]];
        }
    }
    [self.projectManager save];
    
    //删除 系统依赖配置文件
    [fileManager removeItemAtPath:self.toChannelSDKPaths[@"config"]
                  error:nil];
    
    XCGroup *g = [forksdk_group addGroupWithPath:platform_str];
    
    //添加组里面的所有东西的引用到工程
    [self addGroupWithPath:to_channel_path
              relativePath:form_channel_path
                   byGroup:g];

    //添加完毕
    //保存
    [self.projectManager save];
    
    //配置 other linked flag
    [self configOtherLinkFlags];
    
    //配置工程的Info.plist路径
    //要拷贝到的渠道支持文件路径
    NSString *toChannelSDKPath = [self toChannelSDKPathWithIndex:dataManager.platform];
    
    //拷贝源工程Info.plist
    NSString *info_plist_path = [self getInfoPlistFilePath];
    NSString *channel_info_plist_path = [toChannelSDKPath stringByAppendingPathComponent:@"Info.plist"];
    [fileManager copyItemAtPath:info_plist_path
                          toPath:channel_info_plist_path
                           error:nil];
    
    //配置Info.plist bundle id && sheme
    FKChannelConfig *channel_config = dataManager.config.channelConfig[ NSServerPlatformKeyWithPlatform(dataManager.platform) ];
    [self configInfoPlist:channel_config.packName
             UrlTypeSheme:@[@"xygameSheme", NSShemeWithPlatform( dataManager.platform, channel_config )]
                infoPlist:channel_info_plist_path];
    
    NSString *new_config_path = [FORK_SDK_NAME stringByAppendingPathComponent:[NSString stringWithFormat:@"%d/Info.plist",dataManager.platform]];
    //修改info.plist的路径
    [self configInfoPlistFilePath:new_config_path];
    //去掉Info.plist的编译
    NSString *plist_name = [info_plist_path lastPathComponent];
    XCSourceFile *plist_name_source = [self.projectManager fileWithName:plist_name];
    if ( plist_name_source ) {
        //移除编译
        [self.projectTarget removeMemberWithKey:plist_name_source.key];
        //项目移除引用
        [self.projectManager.objects removeObjectForKey:plist_name_source.key];
    }
    [self.projectManager save];
    
    //是否生成IPA
    if ( dataManager.canGenerateIpa ) {
        [self generateIpa:xcodeproje_dir
               targetName:target_name
                  ipaName:[NSString stringWithFormat:@"%@%d.ipa",project_name,dataManager.platform]];
        
    }
    
    NSLog(@"渠道平台配置完毕...\n");
}

- (void)makeXcschemeFileDataWithProjectPath:(NSString *)projectPath{
    NSFileManager *f = [NSFileManager defaultManager];
    DataManager *d = [DataManager getInstance];

    //修改  test.xcscheme 配置
    //遍历寻找
    NSString *xcuserdata = [projectPath stringByAppendingPathComponent:@"xcuserdata"];
    if ( [f fileExistsAtPath:xcuserdata] ) {
        
        NSString *fullsubpath = xcuserdata;
        bool ret = NO;
        NSArray *subpaths = [f subpathsAtPath:xcuserdata];
        for (NSString *subpath in subpaths) {
            fullsubpath = [xcuserdata stringByAppendingPathComponent:subpath];
            if ( [[subpath lastPathComponent] hasSuffix:@".xcscheme"] ) {
                ret = YES;
                break;
            }
        }
        
        //处理
        if ( ret ) {
            NSError *error = nil;
            NSString *str = [NSString stringWithContentsOfFile:fullsubpath
                                                      encoding:NSUTF8StringEncoding error:&error];
            NSString *ReferencedContainer = [NSString stringWithFormat:@"-%d.xcodeproj\">",d.platform];
            if ( !error ) {
                str = [str stringByReplacingOccurrencesOfString:@".xcodeproj\">"
                                                     withString:ReferencedContainer];
                
                [str writeToFile:fullsubpath atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:&error];
                
                if ( error ) {
                    NSLog(@"xcscheme 文件写入出错！");
                }
                
            }
            else
            {
                NSLog(@"xcscheme 文件载入出错！");
            }
            
        }
    }
}

- (void)addGroupWithPath:(NSString *)path
            relativePath:(NSString *)relativePath
                 byGroup:(XCGroup *)group{
    do {
        
        DataManager *dataManager = [DataManager getInstance];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //ForkSDK/渠道ID 目录下所有文件
        NSArray *files_arr =  [fileManager contentsOfDirectoryAtPath:path
                                                    error:nil];
        
        if ( !files_arr || files_arr.count<=0 ) {
            break;
        }
        
        //遍历所有文件
        for (NSString *file in files_arr)
        {
            //文件相对ForkSDK的路径
            NSString *relativeForkSDKPath = [relativePath stringByAppendingPathComponent:file];
            //绝对路径
            NSString* fullPath = [path stringByAppendingPathComponent:file];
            
            BOOL flag = NO;
            //文件是否存在
            if ( [fileManager fileExistsAtPath:fullPath isDirectory:&flag] ) {
                //获取文件属性
                NSDictionary *file_attr = [fileManager fileAttributesAtPath:fullPath
                                             traverseLink:NO];
                //跳过隐藏文件
                if ( [file_attr[@"NSFileExtensionHidden"] integerValue]==1 ) {
                    continue;
                }
                
                //文件类型
                XcodeSourceFileType file_type = [self typeWithFileName:file];
                
                //不是文件夹 或者 是可以识别的类型
                if ( !flag || FileTypeNil!=file_type  ) {
                    
                    //是否是允许添加的类型
                    if ( ![self canAddFile:file] ) {
                        continue;
                    }
                    
                    //静态库类型(.framework || .a )
                    if (file_type==Framework || file_type==Archive)
                    {
                        XCSourceFileDefinition *frameworkDefinition = [[XCSourceFileDefinition alloc] initWithFilePath:file type:file_type];
                        [group addFramework:frameworkDefinition isSystem:NO type:file_type toTarget:@[self.projectTarget]];
                        
                        //framework
                        NSString *searchPath = [[@"$(PROJECT_DIR)" stringByAppendingPathComponent:FORK_SDK_NAME]
                                                stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",dataManager.platform]];
                        searchPath = [searchPath stringByAppendingPathComponent:@"Frameworks"];
                        
                        NSString *SEARCH_PATHS_KEY = file_type==(Archive)?@"LIBRARY_SEARCH_PATHS":@"FRAMEWORK_SEARCH_PATHS";
                            
                        for (NSString* configName in [self.projectTarget configurations]) {
                            XCProjectBuildConfig* configuration = [self.projectTarget configurationWithName:configName];
                            NSMutableArray* headerPaths = [[NSMutableArray alloc] init];
                            [headerPaths addObject:searchPath];
                            [headerPaths addObject:@"$(inherited)"];
                            [configuration addOrReplaceSetting:headerPaths
                                                        forKey:SEARCH_PATHS_KEY];
                        }
                        [self.projectManager save];
                    }
                    else
                    {
                        
                        XCSourceFileDefinition* source = [[XCSourceFileDefinition alloc] initWithFilePath:file type:file_type];
                        [group addSourceFileRef:source];
                        if ( file_type!=SourceCodeHeader ) {
                            [self.projectTarget addMemberWithName:file];
                        }
                        [self.projectManager save];
                    }
                }
                //文件夹类型，递归文件里的文件
                else
                {
                    //继续递归
                    if ( flag ){
                        
                        XCGroup *sub_group = [group addGroupWithPath:file];
                        [self.projectManager save];
                        
                        [self addGroupWithPath:fullPath
                                  relativePath:relativeForkSDKPath
                                       byGroup:sub_group];
                    }

                }
                
            }
        }
        
        return;
    } while (0);
    NSLog(@"配置出错");
    [self cout:@"Error: config error"];
}

- (NSString *)getInfoPlistFilePath{
    NSString *project_base_path = [DataManager getInstance].base_project_dir;
    for (NSString* configName in self.projectTarget.configurations) {
        XCProjectBuildConfig* configuration = [self.projectTarget configurationWithName:configName];
        NSString *info_plist_file_path = (NSString *)[configuration valueForKey:@"INFOPLIST_FILE"];
        if ( !info_plist_file_path ) {
            continue;
        }
        info_plist_file_path = [project_base_path stringByAppendingPathComponent:info_plist_file_path];
        return info_plist_file_path;
    }
    return nil;
}

- (void)configInfoPlistFilePath:(NSString *)path{
    if ( !path ) {
        return;
    }
    for (NSString* configName in self.projectTarget.configurations) {
        XCProjectBuildConfig* configuration = [self.projectTarget configurationWithName:configName];
        [configuration addOrReplaceSetting:path forKey:@"INFOPLIST_FILE"];
    }
}

/**
 *  配置工程的CFBundleIdentifier 和 url shemes
 */
- (void)configInfoPlist:(NSString *)identifier UrlTypeSheme:(NSArray *)url_types infoPlist:(NSString *)info_plist_file_path{
    if ( !identifier || identifier.length==0 ) {
        return;
    }
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:info_plist_file_path] ) {
        return;
    }
    
    NSMutableDictionary *content_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:info_plist_file_path];
    if ( [content_dic.allKeys containsObject:@"CFBundleIdentifier"] ) {
        content_dic[ @"CFBundleIdentifier" ] = identifier;
        //sheme
        NSMutableArray *shemes_arr = [NSMutableArray new];
        if ( [content_dic.allKeys containsObject:@"CFBundleURLTypes"] ) {
            NSArray *CFBundleURLTypes_arr = content_dic[@"CFBundleURLTypes"];
            if ( CFBundleURLTypes_arr && CFBundleURLTypes_arr.count>0 ) {
                [shemes_arr addObjectsFromArray:CFBundleURLTypes_arr];
            }
        }
        
        BOOL flag = YES;
        //如果存在xygame_sheme_supper，说明已经配置过了，不需要再配置
        for (NSArray *arr in shemes_arr) {
            for (NSDictionary *dic in arr) {
                if ( [dic.allValues containsObject:@"xygame_sheme_supper"] ) {
                    flag = NO;
                }
            }
        }
        
        if ( flag ) {
            //配置url shemes
            NSArray *shemes = @[ @{@"CFBundleTypeRole":@"Editor", @"CFBundleURLName":@"xygame_sheme_supper",@"CFBundleURLSchemes":url_types} ];
            [shemes_arr addObject:shemes];
            
            content_dic[ @"CFBundleURLTypes" ] = shemes_arr;
        }
        
        [content_dic writeToFile:info_plist_file_path
                      atomically:YES];
    }
    
    //log test
    [self cout:[NSString stringWithFormat:@"Modify CFBundleIdentifier { %@ }",identifier]];
    [self cout:[NSString stringWithFormat:@"Modify CFBundleURLTypes { %@ }",url_types]];
}

/**
 *  配置OTHER_LD_FLAGS  添加-all_load -Objc -lz
 */
- (void)configOtherLinkFlags{
    for (NSString* configName in self.projectTarget.configurations)
    {
        XCProjectBuildConfig* configuration = [self.projectTarget configurationWithName:configName];
        NSMutableArray* headerPaths = [[NSMutableArray alloc] init];
        [headerPaths addObject:@"-all_load"];
        [headerPaths addObject:@"-Objc"];
        [headerPaths addObject:@"-lz"];
        [configuration addOrReplaceSetting:headerPaths forKey:@"OTHER_LDFLAGS"];
    }
    [self.projectManager save];
    
    [self cout:@"Modify OTHER_LDFLAGS { -all_load -Objc -lz }"];
}

/**
 *  生成Ipa包
 */
- (void)generateIpa:(NSString *)projectPath targetName:(NSString *)targetName ipaName:(NSString *)ipaName{
    NSString *project_base_path = [projectPath stringByDeletingLastPathComponent];
    NSString *project_name = [projectPath lastPathComponent];
    //执行shell
    [self runScript:@[project_base_path, project_name, targetName, ipaName]];
}

/**
 *  执行脚本
 */
- (void)runScript:(NSArray*)arguments {
    [self cout:[NSString stringWithFormat:@"build and generate ipa... { %@ }",arguments]];
    
    typeof(self) __weak _self = self;
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"BuildScript" ofType:@"command"]];
        NSLog(@"path:%@\n",path);
        NSTask *buildTask = [[NSTask alloc] init];
        buildTask.launchPath = path;
        buildTask.arguments  = arguments;

        // Output Handling
        NSPipe *outputPipe = [[NSPipe alloc] init];
        buildTask.standardOutput = outputPipe;
        [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
            NSData *output = [[outputPipe fileHandleForReading] availableData];
            NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
            [_self cout:outStr];
            [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
        }];
        
        //run
        [buildTask launch];
        [buildTask waitUntilExit];
    });
    
    //done
    [[NSNotificationCenter defaultCenter] addObserverForName:NSTaskDidTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@\n", @"完毕");
        [_self cout:@"###############打包完毕###################"];
    }];
}

- (void)cout:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logCallBack( log );
    });
}

- (NSArray *)getOriginalTargetsNames{
    XCProject *project = [[XCProject alloc] initWithFilePath:[DataManager getInstance].base_xcodeproj_dir];
    
    NSMutableArray *target_names_arr = [NSMutableArray new];
    for (XCTarget *target in project.targets) {
        [target_names_arr addObject:target.name];
    }
    return target_names_arr;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end