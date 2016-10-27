//
//  RemoteService.h
//  ProtocolTest
//
//  Created by Shaojun Han on 9/23/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.0

#import <Foundation/Foundation.h>
#import "Service.h"

@class RemoteService;

/**
 * 回调的代理协议定义
 */
@protocol RemoteServiceDelegate <NSObject>
@optional
- (void)remoteService:(RemoteService *)service timeoutWriteWithTag:(long)tag;
- (void)remoteService:(RemoteService *)service didRecieve:(NSData *)data tag:(long)tag;

- (void)remoteServiceDidConnect:(RemoteService *)service;
- (void)remoteServiceDidNotConnect:(RemoteService *)service error:(NSError *)error;
- (void)remoteServiceDidDisconnect:(RemoteService *)service error:(NSError *)error;
@end

/**
 * SSL处理block
 * 参数 SecTrustRef 结构体__SecTrust
 * 返回 BOOL 是否新人某主机
 */
typedef BOOL (^TrustHandler)(SecTrustRef trust);

/**
 * TCP连接服务类
 */
@interface RemoteService : NSObject
/**
 * 代理回调
 */
@property (weak, nonatomic) id<RemoteServiceDelegate> delegate;
/**
 * 初始化
 * 参数 queue 代理线程
 * 参数 delegate 代理
 * 参数 sslSettings SSL配置
 * 参数 trustHandler 检查主机(服务器)证书的回调, 该参数为nil, 则默认信任任何主机, 该block不保证在主线程中回调
 */
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate;
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate sslSettings:(NSDictionary *)sslSettings;
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate sslSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler;
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate queue:(dispatch_queue_t)queue sslSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler;
/**
 * 设置SSL及SSL处理block
 * 说明 基类采用默认实现，即只copy数据，子类必须重载此方法以实现自己的SSL证书配置, 重载时子类不需要使用super调用
 * 参数 sslSettings SSL配置, 若参数为nil, 则不启用SSL协议
 * 参数 trustHandler 检查主机(服务器)证书的回调, 该参数为nil, 则默认信任任何主机, 该block不保证在主线程中回调
 */
- (void)setSSLSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler;

/**
 * 断开连接
 */
- (void)disconnect;

/**
 * 连接服务器
 * 参数 host 主机, 必须为合法主机
 * 参数 port 端口, 必须为合法端口
 * 参数 timeoutInterval 超时时间
 */
- (void)connectToHost:(NSString *)host port:(UInt16)port;
- (void)connectToHost:(NSString *)host port:(UInt16)port timeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 * 发送数据
 * 参数 data 数据
 * 参数 tag 标记, 默认为-1
 * 参数 timeoutInterval 超时时间, 默认60秒
 */
- (void)sendPacket:(NSData *)data;
- (void)sendPacket:(NSData *)data timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)sendPacket:(NSData *)data tag:(long)tag;
- (void)sendPacket:(NSData *)data tag:(long)tag timeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 * 接受数据
 * 参数 size 数据长度
 * 参数 timeoutInterval 超时时间
 */
- (void)recieveDataToSize:(NSUInteger)size tag:(long)tag;
- (void)recieveDataToSize:(NSUInteger)size tag:(long)tag withTimout:(NSTimeInterval)timeoutInteval;

@end
