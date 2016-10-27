//
//  LocalService.h
//  AirCleaner
//
//  Created by Shaojun Han on 9/14/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.0 

#import <Foundation/Foundation.h>
#import "Service.h"

/**
 *  UDP处理
 */
@class LocalService;
@protocol LocalServiceDelegate <NSObject>
@optional
- (void)localService:(LocalService *)service didNotSendWithTag:(long)tag error:(NSError *)error;
- (void)localService:(LocalService *)service didRecieve:(NSData *)data address:(NSString *)address;

- (void)localServiceDidBind:(LocalService *)service;
- (void)localServiceDidClose:(LocalService *)service error:(NSError *)error;
- (void)localServiceDidNotBind:(LocalService *)service error:(NSError *)error;
@end

/**
 * 本地服务类
 * 说明 1.UDP协议，使用AsyncSocket实现
 */
@interface LocalService : NSObject
@property (weak, nonatomic) id<LocalServiceDelegate> delegate;

/**
 * 初始化
 * 参数 delegate udp代理
 */
- (instancetype)initWithDelegate:(id<LocalServiceDelegate>)delegate;

/**
 * UDP关闭
 */
- (void)close;
/**
 * UDP绑定
 * 参数 queue 代理回调队列
 */
- (void)bindToPort:(UInt16)port;
- (void)bindToPort:(UInt16)port queue:(dispatch_queue_t)queue;

/**
 * 发送数据
 * 参数 data 数据
 * 参数 tag 标记, 默认为-1
 * 参数 timeoutInterval 超时时间, 默认60秒
 */
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port;
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port tag:(long)tag;
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port tag:(long)tag timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
