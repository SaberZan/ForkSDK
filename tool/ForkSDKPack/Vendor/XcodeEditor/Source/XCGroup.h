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
@class XCClassDefinition;
@class XCSourceFile;
@class XCSourceFileDefinition;
@class XCSubProjectDefinition;
@class XCTarget;

@interface XCGroup : NSObject <XcodeGroupMember>{
    @private
    NSString* _pathRelativeToProjectRoot;
    NSMutableArray* _children;
    NSMutableArray* _members;
    XCProject* _project;
}

//别名
@property(nonatomic, strong, readonly) NSString* alias;
//相对于付组的相对路径
@property(nonatomic, strong, readonly) NSString* pathRelativeToParent;
//组的唯一键
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong, readonly) NSMutableArray<id<XcodeGroupMember>>* children;

#pragma mark Initializers
+ (XCGroup*)groupWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children;

- (id)initWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children;

#pragma mark Parent group
//从付组中移除
- (void)removeFromParentGroup;
//付组
- (XCGroup*)parentGroup;
//是否是root组
- (BOOL)isRootGroup;

- (void)addFramework:(XCSourceFileDefinition*)frameworkDefinition isSystem:(BOOL)isSystem type:(XcodeSourceFileType)type toTarget:(NSArray *)targets;

- (XCGroup*)addGroupWithPath:(NSString*)path;

- (void)addFolderReference:(NSString*)sourceFolder;

- (void)addSourceFile:(XCSourceFileDefinition*)sourceFileDefinition;

- (void)addSourceFileRef:(XCSourceFileDefinition*)sourceFileDefinition;

/**
 * Adds a sub-project to the group. If the group already contains a sub-project by the same name, the contents will be
 * updated.
 * Returns boolean success/fail; if method fails, caller should assume that project file is corrupt (or file format has
 * changed).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition;

/**
* Adds a sub-project to the group, making it a member of the specified [targets](XCTarget).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition toTargets:(NSArray<XCTarget*>*)targets;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition fromTargets:(NSArray<XCTarget*>*)targets;


#pragma mark Locating children
/**
 * Instances of `XCSourceFile` and `XCGroup` returned as the type `XcodeGroupMember`.
*/
- (NSArray<id<XcodeGroupMember>>*)members;

/**
* Keys of members from this group and any child groups.
*/
- (NSArray<NSString*>*)recursiveMembers;

/**
 * Keys of members from this group
 */
- (NSArray<NSString*>*)buildFileKeys;

/**
 * Returns the child with the specified key, or nil.
*/
- (id <XcodeGroupMember>)memberWithKey:(NSString*)key;

/**
* Returns the child with the specified name, or nil.
*/
- (id <XcodeGroupMember>)memberWithDisplayName:(NSString*)name;


@end
