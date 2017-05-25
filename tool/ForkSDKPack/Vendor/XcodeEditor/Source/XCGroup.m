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
#import "XCTarget.h"
#import "XCFileOperationQueue.h"
#import "XCSourceFile.h"
#import "XCGroup.h"
#import "XCProject.h"
#import "Utils/XCKeyBuilder.h"
#import "XCSourceFileDefinition.h"
#import "XCSubProjectDefinition.h"
#import "XCProject+SubProject.h"

@implementation XCGroup

+ (XCGroup*)groupWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray*)children{
    return [[XCGroup alloc] initWithProject:project key:key alias:alias path:path children:children];
}

- (id)initWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray*)children{
    self = [super init];
    if (self)
    {
        _project = project;
        _key = [key copy];
        _alias = [alias copy];
        _pathRelativeToParent = [path copy];

        _children = [children mutableCopy];
        if (!_children)
        {
            _children = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

//从父组中移除
- (void)removeFromParentGroup{
    NSDictionary* dictionary = [_project objects][_key];
    NSLog(@"Here's the dictionary: %@", dictionary);
    
    [[_project objects] removeObjectForKey:_key];
    
    dictionary = [_project objects][_key];
    NSLog(@"Here's the dictionary: %@", dictionary);
    
    for (XCTarget* target in [_project targets])
    {
        [target removeMembersWithKeys:[self recursiveMembers]];
    }
    NSLog(@"Done!!!");
}

//付组
- (XCGroup*)parentGroup{
    return [_project groupForGroupMemberWithKey:_key];
}

- (BOOL)isRootGroup{
    return [self pathRelativeToParent] == nil && [self displayName] == nil;
}

//添加一个framework
- (void)addFramework:(XCSourceFileDefinition*)frameworkDefinition isSystem:(BOOL)isSystem type:(XcodeSourceFileType)type toTarget:(NSArray *)targets
{
    if (([self memberWithDisplayName:[frameworkDefinition fileName]]) == nil)
    {
        NSString* path = [frameworkDefinition path];
        NSString* name = [frameworkDefinition fileName];
        NSMutableDictionary* fileReference = (NSMutableDictionary *)[self makeFileReferenceWithPath:path name:name type:type];
        if ( isSystem )
            fileReference[@"sourceTree"] = @"SDKROOT";

        
        NSString* frameworkKey = [[XCKeyBuilder forItemNamed:[frameworkDefinition fileName]] build];
        [_project objects][frameworkKey] = fileReference;
        [self addMemberWithKey:frameworkKey];
    }
    
    NSMutableDictionary *groupData = (NSMutableDictionary *)[self asDictionary];
    
    if ( isSystem )
        groupData[@"sourceTree"] = @"SDKROOT";
    
    [_project objects][_key] = groupData;
    
    //add to targets
    XCSourceFile* frameworkSourceRef = (XCSourceFile*) [self memberWithDisplayName:[frameworkDefinition fileName]];
    [self addSourceFile:frameworkSourceRef toTargets:targets];
}

//添加一个文件夹引用
- (void)addFolderReference:(NSString*)sourceFolder {
    NSDictionary *folderReferenceDictionary = [self makeFileReferenceWithPath:sourceFolder name:[sourceFolder lastPathComponent] type:Folder];
    NSString* folderReferenceKey = [[XCKeyBuilder forItemNamed:[sourceFolder lastPathComponent]] build];
    [self addMemberWithKey:folderReferenceKey];
    [_project objects][folderReferenceKey] = folderReferenceDictionary;
    [_project objects][_key] = [self asDictionary];
}

//添加一个组
- (XCGroup*)addGroupWithPath:(NSString*)path
{
    NSString* groupKeyPath = self.pathRelativeToProjectRoot ? [self.pathRelativeToProjectRoot stringByAppendingPathComponent:path] : path;

    NSString* groupKey = [[XCKeyBuilder forItemNamed:groupKeyPath] build];

    NSArray* members = [self members];
    for (id <XcodeGroupMember> groupMember in members)
    {
        if ([groupMember groupMemberType] == PBXGroupType || [groupMember groupMemberType] == PBXVariantGroupType)
        {

            if ([[[groupMember pathRelativeToProjectRoot] lastPathComponent] isEqualToString:path] ||
                [[groupMember displayName] isEqualToString:path] || [[groupMember key] isEqualToString:groupKey])
            {
                return nil;
            }
        }
    }

    XCGroup* group = [[XCGroup alloc] initWithProject:_project key:groupKey alias:nil path:path children:nil];
    NSDictionary* groupDict = [group asDictionary];

    [_project objects][groupKey] = groupDict;

    [self addMemberWithKey:groupKey];

    NSDictionary* dict = [self asDictionary];
    [_project objects][_key] = dict;

    return group;
}

- (void)addSourceFile:(XCSourceFileDefinition*)sourceFileDefinition
{
    [self makeGroupMemberWithName:sourceFileDefinition.fileName contents:sourceFileDefinition.data
                              type:sourceFileDefinition.type];
    [_project objects][_key] = [self asDictionary];
}

- (void)addSourceFileRef:(XCSourceFileDefinition*)sourceFileDefinition{
    [self makeGroupMemberWithName:sourceFileDefinition.fileName path:sourceFileDefinition.path type:sourceFileDefinition.type];
    NSMutableDictionary *d = (NSMutableDictionary *)[self asDictionary];
    [_project objects][_key] = d;
}

// adds an xcodeproj as a subproject of the current project.
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition
{
    // set up path to the xcodeproj file as Xcode sees it - path to top level of project + group path if any
    [projectDefinition initFullProjectPath:_project.filePath groupPath:[self pathRelativeToParent]];

    // create PBXFileReference for xcodeproj file and add to PBXGroup for the current group
    // (will retrieve existing if already there)
    [self makeGroupMemberWithName:[projectDefinition projectFileName] path:[projectDefinition pathRelativeToProjectRoot] type:XcodeProject];
    [_project objects][_key] = [self asDictionary];

    // create PBXContainerItemProxies and PBXReferenceProxies
    [_project addProxies:projectDefinition];

    // add projectReferences key to PBXProject
    [self addProductsGroupToProject:projectDefinition];
}

// adds an xcodeproj as a subproject of the current project, and also adds all build products except for test bundle(s)
// to targets.
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition toTargets:(NSArray*)targets
{
    [self addSubProject:projectDefinition];

    // add subproject's build products to targets (does not add the subproject's test bundle)
    NSArray* buildProductFiles = [_project buildProductsForTargets:[projectDefinition projectKey]];
    for (XCSourceFile* file in buildProductFiles)
    {
        [self addSourceFile:file toTargets:targets];
    }
    // add main target of subproject as target dependency to main target of project
    [_project addAsTargetDependency:projectDefinition toTargets:targets];
}

// removes an xcodeproj from the current project.
- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition
{
    if (projectDefinition == nil)
    {
        return;
    }

    // set up path to the xcodeproj file as Xcode sees it - path to top level of project + group path if any
    [projectDefinition initFullProjectPath:_project.filePath groupPath:[self pathRelativeToParent]];

    NSString* xcodeprojKey = [projectDefinition projectKey];

    // Remove from group and remove PBXFileReference
    [self removeGroupMemberWithKey:xcodeprojKey];

    // remove PBXContainerItemProxies and PBXReferenceProxies
    [_project removeProxies:xcodeprojKey];

    // get the key for the Products group
    NSString* productsGroupKey = [_project productsGroupKeyForKey:xcodeprojKey];

    // remove from the ProjectReferences array of PBXProject
    [_project removeFromProjectReferences:xcodeprojKey forProductsGroup:productsGroupKey];

    // remove PDXBuildFile entries
    [self removeProductsGroupFromProject:productsGroupKey];

    // remove Products group
    [[_project objects] removeObjectForKey:productsGroupKey];

    // remove from all targets
    [_project removeTargetDependencies:[projectDefinition name]];
}

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition fromTargets:(NSArray*)targets
{
    if (projectDefinition == nil)
    {
        return;
    }

    // set up path to the xcodeproj file as Xcode sees it - path to top level of project + group path if any
    [projectDefinition initFullProjectPath:_project.filePath groupPath:[self pathRelativeToParent]];

    NSString* xcodeprojKey = [projectDefinition projectKey];

    // Remove PBXBundleFile entries and corresponding inclusion in PBXFrameworksBuildPhase and PBXResourcesBuidPhase
    NSString* productsGroupKey = [_project productsGroupKeyForKey:xcodeprojKey];
    [self removeProductsGroupFromProject:productsGroupKey];

    // Remove the PBXContainerItemProxy for this xcodeproj with proxyType 1
    NSString* containerItemProxyKey = [_project containerItemProxyKeyForName:[projectDefinition pathRelativeToProjectRoot] proxyType:@"1"];
    if (containerItemProxyKey != nil)
    {
        [[_project objects] removeObjectForKey:containerItemProxyKey];
    }

    // Remove PBXTargetDependency and entry in PBXNativeTarget
    [_project removeTargetDependencies:[projectDefinition name]];
}

//-------------------------------------------------------------------------------------------
#pragma mark Members

- (NSArray<id<XcodeGroupMember>>*)members
{
    if (_members == nil)
    {
        _members = [[NSMutableArray alloc] init];
        for (NSString* childKey in _children)
        {
            XcodeMemberType type = [self typeForKey:childKey];

            @autoreleasepool
            {
                if (type == PBXGroupType || type == PBXVariantGroupType)
                {
                    [_members addObject:[_project groupWithKey:childKey]];
                }
                else if (type == PBXFileReferenceType)
                {
                    [_members addObject:[_project fileWithKey:childKey]];
                }
            }
        }
    }
    return _members;
}

- (NSArray*)recursiveMembers
{
    NSMutableArray* recursiveMembers = [NSMutableArray array];
    for (NSString* childKey in _children)
    {
        XcodeMemberType type = [self typeForKey:childKey];
        if (type == PBXGroupType || type == PBXVariantGroupType)
        {
            XCGroup* group = [_project groupWithKey:childKey];
            NSArray* groupChildren = [group recursiveMembers];
            [recursiveMembers addObjectsFromArray:groupChildren];
        }
        else if (type == PBXFileReferenceType)
        {
            [recursiveMembers addObject:childKey];
        }
    }
    [recursiveMembers addObject:_key];
    return [recursiveMembers arrayByAddingObjectsFromArray:recursiveMembers];
}

- (NSArray*)buildFileKeys
{

    NSMutableArray* arrayOfBuildFileKeys = [NSMutableArray array];
    for (id <XcodeGroupMember> groupMember in [self members])
    {

        if ([groupMember groupMemberType] == PBXGroupType || [groupMember groupMemberType] == PBXVariantGroupType)
        {
            XCGroup* group = (XCGroup*) groupMember;
            [arrayOfBuildFileKeys addObjectsFromArray:[group buildFileKeys]];
        }
        else if ([groupMember groupMemberType] == PBXFileReferenceType)
        {
            [arrayOfBuildFileKeys addObject:[groupMember key]];
        }
    }
    return arrayOfBuildFileKeys;
}

- (id <XcodeGroupMember>)memberWithKey:(NSString*)key
{
    id <XcodeGroupMember> groupMember = nil;

    if ([_children containsObject:key])
    {
        XcodeMemberType type = [self typeForKey:key];
        if (type == PBXGroupType || type == PBXVariantGroupType)
        {
            groupMember = [_project groupWithKey:key];
        }
        else if (type == PBXFileReferenceType)
        {
            groupMember = [_project fileWithKey:key];
        }
    }
    return groupMember;
}

- (id <XcodeGroupMember>)memberWithDisplayName:(NSString*)name
{
    for (id <XcodeGroupMember> member in [self members])
    {
        if ([[member displayName] isEqualToString:name])
        {
            return member;
        }
    }
    return nil;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Protocol Methods

- (XcodeMemberType)groupMemberType
{
    return [self typeForKey:self.key];
}

- (NSString*)displayName
{
    if (_alias)
    {
        return _alias;
    }
    return [_pathRelativeToParent lastPathComponent];
}

- (NSString*)pathRelativeToProjectRoot
{
    if (_pathRelativeToProjectRoot == nil)
    {
        NSMutableArray* pathComponents = [[NSMutableArray alloc] init];
        XCGroup* group = nil;
        NSString* key = [_key copy];

        while ((group = [_project groupForGroupMemberWithKey:key]) != nil && [group pathRelativeToParent] != nil)
        {
            [pathComponents addObject:[group pathRelativeToParent]];
            key = [[group key] copy];
        }

        NSMutableString* fullPath = [[NSMutableString alloc] init];
        for (NSInteger i = (NSInteger) [pathComponents count] - 1; i >= 0; i--)
        {
            [fullPath appendFormat:@"%@/", pathComponents[i]];
        }
        _pathRelativeToProjectRoot = [[fullPath stringByAppendingPathComponent:_pathRelativeToParent] copy];
    }
    return _pathRelativeToProjectRoot;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Utility Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"Group: displayName = %@, key=%@", [self displayName], _key];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private Methods
//-------------------------------------------------------------------------------------------

- (void)addMemberWithKey:(NSString*)key
{

    for (NSString* childKey in _children)
    {
        if ([childKey isEqualToString:key])
        {
            [self flagMembersAsDirty];
            return;
        }
    }
    [_children addObject:key];
    [self flagMembersAsDirty];
}

- (void)flagMembersAsDirty
{
    _members = nil;
}

//-------------------------------------------------------------------------------------------

- (void)makeGroupMenberWithPath:(NSString *)path type:(XcodeSourceFileType)type{
    NSString* filePath;
    XCSourceFile* currentSourceFile = (XCSourceFile*) [self memberWithDisplayName:[path lastPathComponent]];
    if ((currentSourceFile) == nil)
    {
        NSString *refName = [path lastPathComponent];
        NSDictionary* reference = [self makeFileReferenceWithPath:path name:refName type:type];
        NSString* fileKey = [[XCKeyBuilder forItemNamed:path] build];
        [_project objects][fileKey] = reference;
        [self addMemberWithKey:fileKey];
        filePath = [self pathRelativeToProjectRoot];
    }
    else
    {
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
    }
}

- (void)makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
{
    NSString* filePath;
    XCSourceFile* currentSourceFile = (XCSourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil)
    {
        NSString *refName = [name lastPathComponent];
        NSDictionary* reference = [self makeFileReferenceWithPath:name name:refName type:type];
        NSString* fileKey = [[XCKeyBuilder forItemNamed:name] build];
        [_project objects][fileKey] = reference;
        [self addMemberWithKey:fileKey];
        filePath = [self pathRelativeToProjectRoot];
    }
    else
    {
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
    }
}

//-------------------------------------------------------------------------------------------

#pragma mark Xcodeproj methods

// creates PBXFileReference and adds to group if not already there;  returns key for file reference.  Locates
// member via path rather than name, because that is how subprojects are stored by Xcode
- (void)makeGroupMemberWithName:(NSString*)name path:(NSString*)path type:(XcodeSourceFileType)type
{
    XCSourceFile* currentSourceFile = (XCSourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil)
    {
        NSDictionary* reference = [self makeFileReferenceWithPath:path name:name type:type];
        NSString* fileKey = [[XCKeyBuilder forItemNamed:name] build];
        [_project objects][fileKey] = reference;
        [self addMemberWithKey:fileKey];
    }
}

// makes a new group called Products and returns its key
- (NSString*)makeProductsGroup:(XCSubProjectDefinition*)xcodeprojDefinition
{
    NSMutableArray* children = [NSMutableArray array];
    NSString* uniquer = @"";
    for (NSString* productName in [xcodeprojDefinition buildProductNames])
    {
        [children addObject:[_project referenceProxyKeyForName:productName]];
        uniquer = [uniquer stringByAppendingString:productName];
    }
    NSString* productKey = [[XCKeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-Products", uniquer]] build];
    XCGroup* productsGroup = [XCGroup groupWithProject:_project key:productKey alias:@"Products" path:nil children:children];
    [_project objects][productKey] = [productsGroup asDictionary];
    return productKey;
}

// makes a new Products group (by calling the method above), makes a new projectReferences array for it and
// then adds it to the PBXProject object
- (void)addProductsGroupToProject:(XCSubProjectDefinition*)xcodeprojDefinition
{
    NSString* productKey = [self makeProductsGroup:xcodeprojDefinition];

    NSMutableDictionary* PBXProjectDict = [_project PBXProjectDict];
    NSMutableArray* projectReferences = [PBXProjectDict valueForKey:@"projectReferences"];

    NSMutableDictionary* newProjectReference = [NSMutableDictionary dictionary];
    newProjectReference[@"ProductGroup"] = productKey;
    NSString* projectFileKey = [[_project fileWithName:[xcodeprojDefinition pathRelativeToProjectRoot]] key];
    newProjectReference[@"ProjectRef"] = projectFileKey;

    if (projectReferences == nil)
    {
        projectReferences = [NSMutableArray array];
    }
    [projectReferences addObject:newProjectReference];
    PBXProjectDict[@"projectReferences"] = projectReferences;
}

// removes PBXFileReference from group and project
- (void)removeGroupMemberWithKey:(NSString*)key
{
    NSMutableArray* children = [self valueForKey:@"children"];
    [children removeObject:key];
    _project.objects[_key] = [self asDictionary];
    // remove PBXFileReference
    [_project.objects removeObjectForKey:key];
}

// removes the given key from the files arrays of the given section, if found (intended to be used with
// PBXFrameworksBuildPhase and PBXResourcesBuildPhase)
// they are not required because we are currently not adding these entries;  Xcode is doing it for us. The existing
// code for adding to a target doesn't do it, and I didn't add it since Xcode will take care of it for me and I was
// avoiding modifying existing code as much as possible)
- (void)removeBuildPhaseFileKey:(NSString*)key forType:(XcodeMemberType)memberType
{
    NSArray* buildPhases = [_project keysForProjectObjectsOfType:memberType withIdentifier:nil singleton:NO required:NO];
    for (NSString* buildPhaseKey in buildPhases)
    {
        NSDictionary* buildPhaseDict = [[_project objects] valueForKey:buildPhaseKey];
        NSMutableArray* fileKeys = [buildPhaseDict valueForKey:@"files"];
        for (NSString* fileKey in fileKeys)
        {
            if ([fileKey isEqualToString:key])
            {
                [fileKeys removeObject:fileKey];
            }
        }
    }
}

// removes entries from PBXBuildFiles, PBXFrameworksBuildPhase and PBXResourcesBuildPhase
- (void)removeProductsGroupFromProject:(NSString*)key
{
    // remove product group's build products from PDXBuildFiles
    NSDictionary* productsGroup = _project.objects[key];
    for (NSString* childKey in [productsGroup valueForKey:@"children"])
    {
        NSArray* buildFileKeys = [_project keysForProjectObjectsOfType:PBXBuildFileType withIdentifier:childKey singleton:NO required:NO];
        // could be zero - we didn't add the test bundle as a build product
        if ([buildFileKeys count] == 1)
        {
            NSString* buildFileKey = buildFileKeys[0];
            [[_project objects] removeObjectForKey:buildFileKey];
            [self removeBuildPhaseFileKey:buildFileKey forType:PBXFrameworksBuildPhaseType];
            [self removeBuildPhaseFileKey:buildFileKey forType:PBXResourcesBuildPhaseType];
        }
    }
}

//-------------------------------------------------------------------------------------------

#pragma mark Dictionary Representations

- (NSDictionary*)makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type
{
    NSMutableDictionary* reference = [NSMutableDictionary dictionary];
    reference[@"isa"] = [NSString xce_stringFromMemberType:PBXFileReferenceType];
    reference[@"fileEncoding"] = @"4";
    reference[@"lastKnownFileType"] = NSStringFromXCSourceFileType(type);
    if (name != nil)
    {
        reference[@"name"] = [name lastPathComponent];
    }
    if (path != nil)
    {
        reference[@"path"] = path;
    }
    reference[@"sourceTree"] = @"<group>";
    return reference;
}

- (NSDictionary*)asDictionary
{
    NSMutableDictionary* groupData = [NSMutableDictionary dictionary];
    groupData[@"isa"] = [NSString xce_stringFromMemberType:PBXGroupType];
    groupData[@"sourceTree"] = @"<group>";

    if (_alias != nil)
    {
        groupData[@"name"] = _alias;
    }

    if (_pathRelativeToParent)
    {
        groupData[@"path"] = _pathRelativeToParent;
    }

    if (_children)
    {
        groupData[@"children"] = _children;
    }

    return groupData;
}

- (XcodeMemberType)typeForKey:(NSString*)key
{
    NSDictionary* obj = [[_project objects] valueForKey:key];
    return [[obj valueForKey:@"isa"] xce_asMemberType];
}

- (void)addSourceFile:(XCSourceFile*)sourceFile toTargets:(NSArray*)targets
{
    for (XCTarget* target in targets)
    {
        [target addMember:sourceFile];
    }
}

@end