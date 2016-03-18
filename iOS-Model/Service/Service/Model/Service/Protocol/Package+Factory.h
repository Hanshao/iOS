//
//  Protocol+Factory.h
//  AirCleaner
//
//  Created by Shaojun Han on 9/15/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.2.0

#import "Package.h"

static const UInt8 CodeOfFinder             = 0x23;         // 设备发现
static const UInt8 CodeOfLock               = 0x24;         // 锁定设备

static const UInt8 CodeOfHeart              = 0x61;         // 心跳包
static const UInt8 CodeOfQuery              = 0x62;         // 查询设备信息
static const UInt8 CodeOfRename             = 0x63;         // 设备别名
static const UInt8 CodeOfFirUpdate          = 0x64;         // firmware 更新

static const UInt8 CodeOfResolve            = 0x81;         // 解析工作服务器
static const UInt8 CodeOfAskAccess          = 0x82;         // 请求接入
static const UInt8 CodeOfOnlineQuery        = 0x83;         // 设备Online/Offline查询
static const UInt8 CodeOfOnlineUpdate       = 0x84;         // 设备状态更新码
static const UInt8 CodeOfAskFirVersion      = 0x85;         // 固件版本码
static const UInt8 CodeOfSubscribe          = 0x86;         // 订阅

/**
 * 辅助函数
 * 校验和
 * 十六进制字符串转UInt8数组
 * 生成Header的函数
 */
UInt8 CheckSum(UInt8 *byte, NSUInteger size);
NSString *UInt8s2Hex(UInt8 *src, NSUInteger size);
void Hex2UInt8s(NSString *hex, UInt8 *dest, NSUInteger size);
Header HeaderMake(BOOL request, BOOL lock, const UInt8 mac[6], UInt8 length,
                  UInt16 serial, UInt8 company, UInt8 type, UInt16 author);
/**
 * 数据包工厂类
 * 负责数据的封包和解包
 */
@interface Package (Factory)

/**
 * 序列号
 * 当前序列号
 * +1并返回新的序列号
 */
+ (UInt16)serial;
+ (UInt16)grow;

/**
 * 检查包是否合法
 */
+ (BOOL)isSerialOkay:(Package *)package;
+ (BOOL)isRecieveOkay:(Package *)package;

/**
 * resolveWorkServer
 * 0x81 解析工作服务器包
 * 参数 serial 序列号
 * 参数 company 公司码
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成的回调
 */
typedef void (^ResolveParser)(NSString *mac, NSString *ip, UInt16 port, UInt16 author);
+ (Package *)resolveWorkServer:(UInt16)serial company:(UInt8)company type:(UInt8)type author:(UInt16)author;
+ (void)resolveWorkServer:(Package *)package completion:(ResolveParser)completion;

/**
 * joinWorkServer
 * 0x82 请求接入服务包
 * 参数 serial 序列号
 * 参数 joinCode 接入码
 * 参数 username 用户名
 * 参数 password 密码
 * 参数 author 授权码
 * 参数 package 数据包
 * 参数 completion 解析完成的回调
 */
typedef void (^JoinParser)(NSString *mac, UInt8 result);
+ (Package *)joinWorkServer:(UInt16)serial account:(NSString *)account key:(NSString *)key company:(UInt8)company
                       type:(UInt8)type author:(UInt16)author joinCode:(unsigned char *)joinCode joinSize:(int)joinSize;
+ (void)joinWorkServer:(Package *)package completion:(JoinParser)completion;

/**
 * onlineQuery
 * 0x83 查询设备在线/离线包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 lock 锁定设备
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 completion 解析完成回调
 */
typedef void (^OnlineQueryParser)(NSString *mac, UInt8 status);
+ (Package *)onlineQuery:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
                    type:(UInt8)type author:(UInt16)author;
+ (void)onlineQuery:(Package *)package completion:(OnlineQueryParser)completion;

/**
 * onlineUpdate
 * 0x84 设备在线/离线状态更新包
 * 该包仅有服务器发送，客户端只负责接收处理
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 status 设备在离线状态
 * 参数 package 服务器数据包
 * 参数 completion 完成解析时的回调
 */
typedef void (^OnlineParser)(NSString *mac, UInt8 reserved, UInt8 status);
+ (void)onlineUpdate:(Package *)package completion:(OnlineParser)completion;

/**
 * firmwareVersion
 * 0x85 查询固件最新版本号包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型吗
 * 参数 author 授权码
 * 参数 package 服务器数据包
 * 参数 compeltion 完成时的回调
 * 参数 version APP版本
 * 参数 urlString 升级地址
 */
typedef void (^FirmwareParser)(NSString *mac, UInt8 package, NSString *version, NSString *urlString);
+ (Package *)firmwareVersion:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
                        type:(UInt8)type author:(UInt16)author;
+ (void)firmwareVersion:(Package *)package completion:(FirmwareParser)completion;

/**
 * subscribe
 * 0x86 订阅设备事件
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 device 设备类型
 * 参数 code 订阅码
 * 参数 param 订阅参数
 * 参数 package 服务器数据包
 * 参数 compeltion 完成时的回调
 */
typedef void (^SubscribeParser)(NSString *mac, UInt8 result);
+ (Package *)subscribe:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
                  type:(UInt8)type author:(UInt16)author code:(UInt8)code enable:(BOOL)enable;
+ (void)subscribe:(Package *)package completion:(SubscribeParser)completion;

/**
 * heart
 * 0x61 心跳包 标记上时间的和没有标记上时间的心跳包
 * 心跳解析 解析结果[timeInterval], timeInterval下次心跳间隔
 * 参数 serial 数据包序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 心跳返回数据包
 * 参数 completion 解析完成时回调
 */
typedef void (^HeartParser)(NSString *mac, NSInteger style, NSTimeInterval timeInterval);
+ (Package *)heart:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
              type:(UInt8)type author:(UInt16)author;
+ (void)heart:(Package *)package completion:(HeartParser)completion;

/**
 * query
 * 0x62 查询模块信息包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 hardVersion 硬件版本
 * 参数 softVersion 软件版本
 * 参数 nickName 设备别名
 */
typedef void (^QueryParser)(NSString *mac, NSInteger style, NSString *hardVersion, NSString *softVersion, NSString *nickName);
+ (Package *)query:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)author;
+ (void)query:(Package *)package completion:(QueryParser)completion;

/**
 * rename
 * 0x63 设置模块别名
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 name 重命名的名字
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
typedef void (^RenameParser)(NSString *mac, NSInteger style, UInt8 result);
+ (Package *)rename:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
               type:(UInt8)type author:(UInt16)author name:(NSString *)name;
+ (void)rename:(Package *)package completion:(RenameParser)completion;

/**
 * firmwareUpdate
 * 0x64 设备固件升级
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
typedef void (^FirmwareUpdateParser)(NSString *mac, NSInteger style, UInt8 result);
+ (Package *)firmwareUpdate:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
                       type:(UInt8)type author:(UInt16)author url:(NSString *)url;
+ (void)firmwareUpdate:(Package *)package completion:(FirmwareUpdateParser)completion;

/**
 * find
 * 0x23 设备发现包
 * 参数 serial 序列号
 * 参数 type 设备类型码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 ip 设备IP地址,点分十进制表示
 * 参数 mac 设备mac地址，十六进制表示
 */
typedef void (^FinderParser)(NSString *mac, NSString *ip, UInt8 company, UInt8 type, UInt16 author);
+ (Package *)finder:(UInt16)serial company:(UInt8)company type:(UInt8)type author:(UInt16)author;
+ (Package *)finder:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)author;
+ (void)finder:(Package *)package completion:(FinderParser)completion;

/**
 * lock
 * 0x24 锁定或解锁设备包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
typedef void (^UlockParser)(NSString *mac, BOOL lock, UInt8 result);
+ (Package *)ulock:(UInt16)serial mac:(NSString *)mac company:(UInt8)company
              type:(UInt8)type author:(UInt16)author lock:(BOOL)lock;
+ (void)ulock:(Package *)package completion:(UlockParser)completion;

@end
