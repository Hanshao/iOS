//
//  ServiceDriver.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/16/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//  0.3.1 增加扩展接口, 结构化
//  0.4.0 接口扩展, 增加异常(超时, 网络异常等)回调

#import <Foundation/Foundation.h>
#import "LocalService.h"
#import "RemoteService.h"
#import "Package+Factory.h"
#import "WifiDevice.h"
#import "WifiManager.h"
#import "NetworkUtil.h"
#import "SSLManager.h"
#import "Service.h"

// 通信层上离线通知
extern NSString *const klocalServiceOnlineNoteKey;
extern NSString *const klocalServiceOfflineNoteKey;
extern NSString *const kremoteServiceOnlineNoteKey;
extern NSString *const kremoteServiceOfflineNoteKey;
// 异常时回调类型
typedef NS_ENUM(NSInteger, ServiceError) {
    ServiceUnkownError = 0,
    ServiceTimeoutError = 1,
    ServiceNetworkError = 2,
    ServiceOfflineError = 3
};
typedef void (^ServiceBadHandler)(NSInteger error);
// 数据包类型码(局域网, 互联网)
extern UInt8 const localPackageStyle;
extern UInt8 const remotePackageStyle;
// 单例对象
#define ServiceDriverInstance [ServiceDriver sharedInstance]

/**
 * 服务驱动类
 */
@interface ServiceDriver : NSObject
// 在离线状态
@property (nonatomic, assign, readonly) BOOL remoteOnline;
@property (nonatomic, assign, readonly) BOOL localOnline;

/**
 * 单例
 */
+ (instancetype)sharedInstance;

/**
 * 注册/取消可达性服务
 */
- (void)registerReachableService;
- (void)removeReachableService;

/**
 * 停止, 清理
 */
- (void)halt;   // 只停止
- (void)revoke; // 停止并清理观察者队列

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
// 获取工作服务器授权码
- (UInt16)author;
// 查找/添加/移除观察者
- (NSString *)keyByCode:(UInt8)code;
- (NSArray *)handlersWithKey:(NSString *)key mac:(NSString *)mac;
- (void)removeObserver:(id)observer mac:(NSString *)mac forKey:(NSString *)key;
- (void)addObserver:(id)observer mac:(NSString *)mac forKey:(NSString *)key handler:(id)handler;
// 添加解析(与观察者结合使用)
- (id)parserWithKey:(NSString *)key;
- (void)setSelector:(SEL)selector parser:(id)parser forKey:(NSString *)key;
// 发送数据
- (void)remoteSendPackage:(Package *)package timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)localSendPackage:(Package *)package host:(NSString *)host timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)remoteSendPackage:(Package *)package selector:(SEL)selector parser:(id)parser badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)localSendPackage:(Package *)package host:(NSString *)host selector:(SEL)selector parser:(id)parser badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

#pragma mark
#pragma mark 协议
/**
 * 注册发送广播
 * 观察者对感兴趣的事件和设备进行注册
 * 参数 observer 观察者，当为空时，注册失败
 * 参数 mac 设备mac地址，地址为nil时表示注册所有设备
 * 参数 handler 完成时回调
 * 参数 style 表示局域网/互联网
 */
// 注册发现包反馈
typedef void (^FinderHandler)(NSString *mac, NSString *ip, UInt8 company, UInt8 type, UInt16 author, id obj);
- (void)removeFinderObserver:(id)observer mac:(NSString *)mac;
- (void)addFinderObserver:(id)observer mac:(NSString *)mac handler:(FinderHandler)handler;

// 注册设备信息查询反馈
typedef void (^QueryHandler)(NSInteger style, NSString *hardVer, NSString *softVer, NSString *nickName);
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

// 注册固件版本反馈
typedef void (^FirmwareVerHandler)(NSString *mac, NSString *softVer, NSString *url);
- (void)removeFirmwareVerObserver:(id)observer mac:(NSString *)mac;
- (void)addFirmwareVerObserver:(id)observer mac:(NSString *)mac handler:(FirmwareVerHandler)handler;

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
 * 发送数据报文
 * 部分数据报文仅局域网发送，部分仅因特网发送，
 * 其他的则优先选择局域网发送（设备局域网在线则只局域网，否则考虑因特网，如果因特网也不在线，则不发送)
 * 参数 device 设备
 * 参数 mac 设备mac地址
 * 参数 handler 接收到反馈是回调
 * 参数 badHandler 异常时回调, 包括超时
 * 参数 timeoutInterval 超时时间(发送到接收的时间)
 */
// 发现，局域网，handler(基于序列号，可为nil)
- (void)finderWithTimeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)finderWithDevice:(WifiDevice *)device timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)finderWithMACAddress:(NSString *)mac timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)finderWithHandler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)finderWithDevice:(WifiDevice *)device handler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)finderWithMACAddress:(NSString *)mac handler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 查询设备状态，局域网/因特网，handler(基于序列号，可为nil)
- (void)queryWithDevice:(WifiDevice *)device handler:(QueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 心跳，局域网，handler(基于序列号，可为nil)
- (void)beatWithDevice:(WifiDevice *)device handler:(BeatHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 锁定设备，局域网，handler(基于序列号，可为nil)
- (void)lockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)unlockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 设备重命名，局域网/因特网，handler(基于序列号，可为nil)
- (void)renameWithDevice:(WifiDevice *)device name:(NSString *)name handler:(RenameHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 设备固件版本报文，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareVerWithDevice:(WifiDevice *)device handler:(FirmwareVerHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

// 设备固件升级，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareUpdateWithDevice:(WifiDevice *)device url:(NSString *)url handler:(FirmwareUpdateHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval;

// 查询设备是否远程在线，因特网，handler(基于序列号，可为nil)
- (void)onlineQueryWithDevice:(WifiDevice *)device handler:(OnlineQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval;

// 订阅设备事件，因特网，handler(基于序列号，可为nil)
- (void)subscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval;

@end

