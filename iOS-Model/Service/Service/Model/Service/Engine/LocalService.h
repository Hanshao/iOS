//
//  LocalService.h
//  AirCleaner
//
//  Created by Shaojun Han on 9/14/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.0 

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"

/**
 *  UDP处理
 */
@class LocalService;
@protocol LocalServiceDelegate <NSObject>
@required
- (void)localService:(LocalService *)service didRecieve:(NSData *)data address:(NSString *)address;

@optional
- (void)localServiceDidBind:(LocalService *)service;
- (void)localServiceDidClose:(LocalService *)service error:(NSError *)error;
- (void)localServiceDidNotBind:(LocalService *)service error:(NSError *)error;

@end

/**
 * 本地服务类
 * 说明 1.UDP协议，使用AsyncSocket实现
 * 说明 2.Service的子类
 */
@interface LocalService : NSObject

@property (weak, nonatomic) id<LocalServiceDelegate> delegate;

/**
 * 初始化
 * 参数 delegate udp代理
 */
- (instancetype)initWithDelegate:(id<LocalServiceDelegate>)delegate;

/**
 * UDP绑定
 * 参数 queue 代理回调队列
 */
- (void)bindToPort:(UInt16)port;
- (void)bindToPort:(UInt16)port queue:(dispatch_queue_t)queue;

/**
 * UDP关闭
 */
- (void)close;

/**
 * 发送数据
 */
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port;
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
