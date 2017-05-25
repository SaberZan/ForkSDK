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
#import "XCSourceFileDefinition.h"

@implementation XCSourceFileDefinition

+ (XCSourceFileDefinition*)sourceDefinitionWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type{
    return [[XCSourceFileDefinition alloc] initWithName:name text:text type:type];
}

+ (XCSourceFileDefinition*)sourceDefinitionWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type{
    return [[XCSourceFileDefinition alloc] initWithName:name data:data type:type];
}

- (id)initWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type{
    self = [super init];
    _fileName = [name copy];
    _data = [[text dataUsingEncoding:NSUTF8StringEncoding] copy];
    _type = type;
    return self;
}

- (id)initWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type{
    self = [super init];
    _fileName = [name copy];
    _data = [data copy];
    _type = type;
    return self;
}

- (id)initWithFilePath:(NSString *)path type:(XcodeSourceFileType)type{
    self = [super init];
    _fileName = [path lastPathComponent];
    _path = [path copy];
    _data = nil;
    _type = type;
    return self;
}
@end