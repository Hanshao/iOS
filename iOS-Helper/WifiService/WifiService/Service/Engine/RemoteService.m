//
//  RemoteService.m
//  ProtocolTest
//
//  Created by Shaojun Han on 9/23/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "RemoteService.h"

@interface RemoteService ()
<
    GCDAsyncSocketDelegate
>
{
    GCDAsyncSocket      *socket;    // TCP连接套接字
}

@property (strong, nonatomic) dispatch_queue_t      delegateQueue;              // 代理队列
@property (copy, nonatomic) NSDictionary            *sslSettings;       // SSL配置
@property (copy, nonatomic) TrustHandler            trustHandler;       // SSL证书处理block

@end

@implementation RemoteService

- (void)dealloc {
    self.delegate = nil;
    [self disconnect];
}

#pragma mark
#pragma mark 初始化
/**
 * 初始化
 * 参数 queue 代理线程
 * 参数 delegate 代理
 * 参数 sslSettings SSL配置
 * 参数 trustHandler 检查主机(服务器)证书的回调, 该参数为nil, 则默认信任任何主机, 该block不保证在主线程中回调
 */
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate {
    return [self initWithDelegate:delegate sslSettings:nil trustHandler:nil];
}
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate sslSettings:(NSDictionary *)sslSettings {
    return [self initWithDelegate:delegate sslSettings:sslSettings trustHandler:nil];
}
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate sslSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self initWithDelegate:delegate queue:queue sslSettings:sslSettings trustHandler:nil];
}
- (instancetype)initWithDelegate:(id<RemoteServiceDelegate>)delegate queue:(dispatch_queue_t)queue sslSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler {
    if (self = [super init]) {
        self.delegate = delegate;
        self.delegateQueue = queue;
        [self setSSLSettings:sslSettings trustHandler:trustHandler];
    }
    return self;
}
/**
 * 设置SSL及SSL处理block
 * 参数 sslSettings SSL配置
 * 参数 trustHandler 检查主机(服务器)证书的回调, 该参数为nil, 则默认信任任何主机, 该block不保证在主线程中回调
 */
- (void)setSSLSettings:(NSDictionary *)sslSettings trustHandler:(TrustHandler)trustHandler {
    self.sslSettings = sslSettings;
    self.trustHandler = trustHandler;
}

/**
 * 断开连接
 */
- (void)disconnect {
    [socket disconnect];
    socket.delegate = nil;
}
/**
 * 连接服务器
 * 参数 host 主机, 必须为合法主机
 * 参数 port 端口, 必须为合法端口
 * 参数 timeoutInterval 超时时间
 */
- (void)connectToHost:(NSString *)host port:(UInt16)port {
    [self connectToHost:host port:port timeoutInterval:300];  // 默认5分钟超时
}
- (void)connectToHost:(NSString *)host port:(UInt16)port timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self disconnect];
    // 创建连接
    NSError *error = nil;
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    if(YES == [socket connectToHost:host onPort:port withTimeout:timeoutInterval error:&error]) return;
    // 出错
    if ([self.delegate respondsToSelector:@selector(remoteServiceDidNotConnect:error:)]) {
        [self.delegate remoteServiceDidNotConnect:self error:error];
    }
}

/**
 * 发送数据
 * 参数 data 数据
 * 参数 timeoutInterval 超时时间
 */
- (void)sendPacket:(NSData *)data {
    [self sendPacket:data tag:-1 timeoutInterval:60.0];
}
- (void)sendPacket:(NSData *)data timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self sendPacket:data tag:-1 timeoutInterval:timeoutInterval];
}
- (void)sendPacket:(NSData *)data tag:(long)tag {
    [self sendPacket:data tag:tag timeoutInterval:60.0];
}
- (void)sendPacket:(NSData *)data tag:(long)tag timeoutInterval:(NSTimeInterval)timeoutInterval {
    [socket writeData:data withTimeout:timeoutInterval tag:tag];
    NSLog(@"remote write>>>>>>>>>>>>>>>tag = %ld\n%@", tag, [self format:data]);
}

/**
 * 接受数据
 * 参数 size 数据长度
 * 参数 timeoutInterval 超时时间
 */
- (void)recieveDataToSize:(NSUInteger)size tag:(long)tag{
    [self recieveDataToSize:size tag:tag withTimout:-1];
}
- (void)recieveDataToSize:(NSUInteger)size tag:(long)tag withTimout:(NSTimeInterval)timeoutInteval {
    [socket readDataToLength:size withTimeout:timeoutInteval tag:tag];
}


#pragma mark
#pragma mark socket代理
/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 数据包处理
    // NSLog(@"remote did read>>>>>>>>>>>>>>>tag = %ld\n%@", tag, [self format:data]);
    if ([self.delegate respondsToSelector:@selector(remoteService:didRecieve:tag:)]) {
        [self.delegate remoteService:self didRecieve:data tag:tag];
    }
}
/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"remote did write>>>>>>>>>>>>>>>tag = %ld", tag);
}
/**
 * Called if a write operation has reached its timeout without completing.
 */
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    if ([self.delegate respondsToSelector:@selector(remoteService:timeoutWriteWithTag:)]) {
        [self.delegate remoteService:self timeoutWriteWithTag:tag];
    }
    return NO;
}
/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"remote did connect>>>>>>>>>>>>>>>host = %@, port = %u", host, port);
    // 是否启动SSL:若设置了SSL配置则启动SSL握手, 否则不启动并通知连接已经建立
    if (self.sslSettings) {
        [socket startTLS:self.sslSettings];
    } else if ([self.delegate respondsToSelector:@selector(remoteServiceDidConnect:)]) {
        [self.delegate remoteServiceDidConnect:self];
    }
}
/**
 * Called when a socket disconnects with or without error.
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"remote disconnect>>>>>>>>>>>>>>>error = %@", err);
    if (socket == sock && [self.delegate respondsToSelector:@selector(remoteServiceDidDisconnect:error:)]) {
        [self.delegate remoteServiceDidDisconnect:self error:err];
    }
}
/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 **/
- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    NSLog(@"remote didSecure");
    if ([self.delegate respondsToSelector:@selector(remoteServiceDidConnect:)]) {
        [self.delegate remoteServiceDidConnect:self];
    }
}
/**
 * Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    NSLog(@"remote didRecieveTrust");
    // 证书验证,默认信任所有主机
    if (self.trustHandler) {
        completionHandler(self.trustHandler(trust));
    } else {
        completionHandler(YES);
    }
}

/**
 * 日志函数
 */
- (NSString *)format:(NSData *)data {
    static UInt8 table[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    if (!data.length) return nil;
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *res = [NSMutableString string];
    [res appendFormat:@"%c%c", table[(bytes[0] >> 4 & 0x0F)], table[(bytes[0] & 0x0F)]];
    for (int i = 1; i < data.length; ++ i) {
        [res appendFormat:@"  %c%c", table[(bytes[i] >> 4 & 0x0F)], table[(bytes[i] & 0x0F)]];
    }
    return res;
}

@end
