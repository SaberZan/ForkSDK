//
//  FKMacro.h
//  ForSDK_TEST
//
//  Created by ruikong on 15/7/14.
//  Copyright (c) 2015年 xuanyun Technology. All rights reserved.
//

#ifndef ForSDK_TEST_FKMacro_h
#define ForSDK_TEST_FKMacro_h

enum
{
    PLATFORM_AISI=1001,//爱思
    PLATFORM_XY=1002,//玄云游戏
    PLATFORM_HAIMA=1003,//海马
    PLATFORM_ITOOLS=1004,//itools
    PLATFORM_TONGBU=1005,//同步助手
    PLATFORM_BAIDU91=1006,//百度91
    PLATFORM_KUAIYONG=1007,//快用
    PLATFORM_PP=1008,//PP助手
};

#define KVERSION_SDK @"1.0.0"

#define FORK_SDK_HELLO \
"            ________   _________   _____      __   _    ______   _______     __   _\n"\
"           /  _____/  / _____  /  / _   \\    / / .'.'  / ____/  / ___   \\   / / .'.'\n"\
"          /  /____   / /    / /  / /_) /    / /-'.'   / /___   / /   '. |  / /-'.'\n"\
"         /  _____/  / /    / /  / _  ,'    / _  |    /___  /  / /    / /  / _  |\n"\
"   __   /  /       / /____/ /  / / \\ \\    / / | |\   ____/ /  / /___.' /  / / | |\n"\
"  / /  /__/       /________/  /_/   \\_\\  /_/  |_|\  /_____/  /_______.'  /_/  |_|\n"\
" / /_________________________________________________________\n"\
"/___________________________________________________________/   R   O   B   I   N\n"


/**
 FKCALL代表无参数的方法调用，FKCALL1就代表1个参数的方法调用
 ps：只能调用参数为对象的方法
 */

#define FKCALL(obj, op) ((void(*)(id, SEL))objc_msgSend)(obj,NSSelectorFromString(op));

#define FKCALL1(obj, op, op1) ((void(*)(id, SEL, id))objc_msgSend)(obj,NSSelectorFromString(op),op1);

#define FKCALL2(obj, op, op1, op2) ((void(*)(id, SEL, id, id))objc_msgSend)(obj,NSSelectorFromString(op),op1,op2);

#define FKCALL3(obj, op, op1, op2, op3) ((void(*)(id, SEL, id, id, id))objc_msgSend)(obj,NSSelectorFromString(op),op1,op2,op3);

#define FKCALL4(obj, op, op1, op2, op3, op4) ((void(*)(id, SEL, id, id, id, id))objc_msgSend)(obj,NSSelectorFromString(op),op1,op2,op3,op4);

/**
 这是只有一个int参数的方法调用宏
 */
#define FKCALL_Int(obj, op, op1) ((void(*)(id, SEL, NSInteger))objc_msgSend)(obj,NSSelectorFromString(op),op1);

#define FKCALL_Double(obj, op, op1) ((void(*)(id, SEL, double))objc_msgSend)(obj,NSSelectorFromString(op),op1);

#ifdef DEBUG
#define FKTEST 1
#else
#define FKTEST 0
#endif

#define FKLog(args, ...) NSLog(args, ##__VA_ARGS__)
#ifndef DEBUG
#undef FKLog
#define FKLog(args, ...)
#endif

#define FKSTR(OBJ) # OBJ

//config file name
#define kCONFIG_FILE_PATH @"developerinfo.plist"

//Sever uri
#define kREMOTE_SERVER_URL @"http://192.168.2.53"
#define kCHANNEL_PATH @"/sdkapi/Channel/getParams"
#define kAUTH_PATH @"/sdkapi/user/login"

#define FKSingletonM(ClassName) \
+ (instancetype)getInstance{\
static dispatch_once_t onceToken;\
static ClassName *sharedInstance;\
dispatch_once(&onceToken, ^{\
    sharedInstance = [[self alloc] init];\
});\
return sharedInstance;\
}

#endif
