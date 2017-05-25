////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import <Foundation/Foundation.h>

//文件操作队列
@interface XCFileOperationQueue : NSObject
{
    @private
    NSString* _baseDirectory;//基础路径
    NSMutableDictionary* _filesToWrite;//要写入的文件和路径
    NSMutableDictionary* _frameworksToCopy;//要拷贝的库
    NSMutableArray* _filesToDelete;//要删除的文件
    NSMutableArray* _directoriesToCreate;//要创建的文件
}

//init
- (id)initWithBaseDirectory:(NSString*)baseDirectory;

- (BOOL)fileWithName:(NSString*)name existsInProjectDirectory:(NSString*)directory;

- (void)queueTextFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents;

- (void)queueDataFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSData*)contents;

- (void)queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory;

- (void)queueDeletion:(NSString*)filePath;

- (void)queueDirectory:(NSString*)withName inDirectory:(NSString*)parentDirectory;

- (void)commitFileOperations;

@end

