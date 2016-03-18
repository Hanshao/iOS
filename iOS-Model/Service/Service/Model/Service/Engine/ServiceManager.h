//
//  ServiceManager.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/16/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//  0.3.0 增加扩展接口, 结构化

#import <Foundation/Foundation.h>
#import "LocalService.h"
#import "RemoteService.h"
#import "Package+Factory.h"
#import "WifiDevice.h"
#import "WifiManager.h"
#import "NetworkUtil.h"
#import "SSLManager.h"
#import "Service.h"

#define PackageByLocal 0x01
#define PackageByRemote 0x02

#define ServiceLocalOnline      @"ServiceLocalOnline"
#define ServiceLocalOffline     @"ServiceLocalOffline"
#define ServiceRemoteOnline     @"ServiceRemoteOnline"
#define ServiceRemoteOffline    @"ServiceRemoteOffline"

#define ServiceManagerInstance [ServiceManager sharedInstance]

@interface ServiceManager : NSObject

// 在离线状态
@property (nonatomic, assign) BOOL remoteOnline;
@property (nonatomic, assign) BOOL localOnline;

/**
 * 单例
 */
+ (instancetype)sharedInstance;

/**
 * 注册/取消可达性服务
 * 不会主动发起网络可发性事件的注册, 需要显式注册
 */
- (void)registerReachableService;
- (void)removeReachableService;

/**
 * 停止, 清理
 */
- (void)halt;
- (void)revoke;

/**
 * 启动, 账户信息
 */
- (void)launch;
- (void)launchByAccount:(NSString *)account key:(NSString *)key;

/**
 * 对处理队列清理
 * 深度清理, 轻度清理
 */
- (void)clear;
- (void)lightClear;

#pragma mark
#pragma mark 基本方法
- (void)remoteSendPackage:(Package *)package;
- (void)localSendPackage:(Package *)package host:(NSString *)host;
// key值
- (NSString *)keyWithCode:(UInt8)code;
- (NSString *)keyWithSerial:(UInt16)serial;
// 查找/添加/移除观察者
- (NSArray *)handlerWithKey:(NSString *)key mac:(NSString *)mac;
- (void)removeObserver:(id)observer mac:(NSString *)mac key:(NSString *)key;
- (void)addObserver:(id)observer mac:(NSString *)mac key:(NSString *)key handler:(id)handler;
// 添加解析(命令字段, 与观察者结合使用)
- (id)parserWithCode:(UInt8)code;
- (void)addSelector:(SEL)selector parser:(id)parser code:(UInt8)code;
// 添加解析(序列号)
- (void)addSelector:(SEL)selector parser:(id)parser serial:(UInt16)serial;


#pragma mark
#pragma mark 协议
/**
 * 注册发送广播
 * 观察者对感兴趣的事件和设备进行注册
 * 参数 observer 观察者，当为空时，注册失败
 * 参数 device 设备，为空时是所有设备
 * 参数 mac 设备mac地址，地址为nil时表示注册所有设备
 * 参数 completion 完成时回调
 * 参数 package 标识局域网、广域网
 */
// 注册发现包反馈
typedef void (^FinderHandler)(NSString *mac, NSString *ip, UInt8 company, UInt8 type, UInt16 author);
- (void)removeFinderObserver:(id)observer mac:(NSString *)mac;
- (void)addFinderObserver:(id)observer mac:(NSString *)mac handler:(FinderHandler)handler;

// 注册设备信息查询反馈
typedef void (^QueryHandler)(NSInteger style, NSString *hardVersion, NSString *softVersion, NSString *nickName);
- (void)removeQueryObserver:(id)observer mac:(NSString *)mac;
- (void)addQueryObserver:(id)observer mac:(NSString *)mac handler:(QueryHandler)handler;

// 注册设备心跳反馈(注意心跳的handler不是在主线程中执行)
typedef void (^BeatHandler)(NSInteger style, NSTimeInterval timeInterval);
- (void)removeBeatObserver:(id)observer mac:(NSString *)mac;
- (void)addBeatObserver:(id)observer mac:(NSString *)mac handler:(BeatHandler)handler;

// 注册设备锁定反馈
typedef void (^UlockHandler)(BOOL success);
- (void)removeUlockObserver:(id)observer mac:(NSString *)mac;
- (void)addUlockObserver:(id)observer mac:(NSString *)mac handler:(UlockHandler)handler;

// 注册设备重命名反馈
typedef void (^RenameHandler)(NSInteger style, BOOL success);
- (void)removeRenameObserver:(id)observer mac:(NSString *)mac;
- (void)addRenameObserver:(id)observer mac:(NSString *)mac handler:(RenameHandler)handler;

// 注册设备固件升级反馈
typedef void (^FirmwareUpdateHandler)(NSInteger style, BOOL success);
- (void)removeFirmwareUpdateObserver:(id)observer mac:(NSString *)mac;
- (void)addFirmwareUpdateObserver:(id)observer mac:(NSString *)mac handler:(FirmwareUpdateHandler)handler;

// 注册设备远程在/离线
typedef void (^OnlineQueryHandler)(BOOL online);
- (void)removeOnlineQueryObserver:(id)observer mac:(NSString *)mac;
- (void)addOnlineQueryObserver:(id)observer mac:(NSString *)mac handler:(OnlineQueryHandler)handler;

// 注册接入工作服务器的反馈
typedef void (^JoinHandler)(BOOL join);
- (void)removeJoinObserver:(id)observer;
- (void)addJoinObserver:(id)observer handler:(JoinHandler)handler;

// 注册设备上/离线事件
typedef void (^OnlineUpdateHandler)(BOOL online);
- (void)removeOnlineUpdateObserver:(id)observer mac:(NSString *)mac;
- (void)addOnlineUpdateObserver:(id)observer mac:(NSString *)mac handler:(OnlineUpdateHandler)handler;

// 注册订阅事件
typedef void (^SubscribeHandler)(BOOL success);
- (void)removeSubscribeObserver:(id)observer mac:(NSString *)mac;
- (void)addSubscribeObserver:(id)observer mac:(NSString *)mac handler:(SubscribeHandler)handler;

/**
 * 数据包
 * 发送响应数据包
 * 部分数据包仅局域网发送，部分仅因特网发送，
 * 其他的则优先选择局域网发送（设备局域网在线则只局域网，否则考虑因特网，如果因特网也不在线，则不发送）
 */
// 发现包，局域网，handler(基于序列号，可为nil)
- (void)finderWithHandler:(FinderHandler)handler;
- (void)finderWithDevice:(WifiDevice *)device handler:(FinderHandler)handler;
- (void)finderWithMacaddress:(NSString *)mac handler:(FinderHandler)handler;

// 查询设备状态包，局域网/因特网，handler(基于序列号，可为nil)
- (void)queryWithDevice:(WifiDevice *)device handler:(QueryHandler)handler;

// 心跳包，局域网，handler(基于序列号，可为nil)
- (void)beatWithDevice:(WifiDevice *)device handler:(BeatHandler)handler;

// 锁定设备包，局域网，handler(基于序列号，可为nil)
- (void)lockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler;
- (void)unlockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler;

// 设备重命名包，局域网/因特网，handler(基于序列号，可为nil)
- (void)renameWithDevice:(WifiDevice *)device name:(NSString *)name handler:(RenameHandler)handler;

// 设备固件升级包，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareUpdateWithDevice:(WifiDevice *)device url:(NSString *)url handler:(FirmwareUpdateHandler)handler;

// 查询设备是否远程在线，因特网，handler(基于序列号，可为nil)
- (void)onlineQueryWithDevice:(WifiDevice *)device handler:(OnlineQueryHandler)handler;

// 订阅设备事件，因特网，handler(基于序列号，可为nil)
- (void)subscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler;

@end
