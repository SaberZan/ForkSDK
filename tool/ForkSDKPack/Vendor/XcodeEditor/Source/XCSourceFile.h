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
#import "XcodeGroupMember.h"
#import "XcodeSourceFileType.h"

@class XCProject;

@interface XCSourceFile : NSObject<XcodeGroupMember>{
    @private
    XCProject *_project;
    NSNumber *_isBuildFile;
    NSString *_buildFileKey;
}

@property (nonatomic, readonly) XcodeSourceFileType type;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSString *sourceTree;
@property (nonatomic, strong) NSString *path;

+ (XCSourceFile *)sourceFileWithProject:(XCProject *)project key:(NSString *)key type:(XcodeSourceFileType)type
    name:(NSString *)name sourceTree:(NSString *)tree path:(NSString *)path;

- (id)initWithProject:(XCProject *)project key:(NSString *)key type:(XcodeSourceFileType)type name:(NSString *)name
    sourceTree:(NSString *)tree path:(NSString *)path;

/**
* 如果是的,表明编译的文件可以被包括在“XCTarget”。
*/
- (BOOL)isBuildFile;

- (BOOL)canBecomeBuildFile;

- (XcodeMemberType)buildPhase;

- (NSString *)buildFileKey;

/**
* Adds this file to the project as an `xcode_BuildFile`, ready to be included in targets.
*/
- (void)becomeBuildFile;

/**
* Method for setting Compiler Flags for individual build files
*
* @param value String value to set in Compiler Flags
*/
- (void)setCompilerFlags:(NSString *)value;

@end
