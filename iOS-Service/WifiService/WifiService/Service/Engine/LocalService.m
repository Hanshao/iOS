//
//  LocalService.m
//  AirCleaner
//
//  Created by Shaojun Han on 9/14/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "LocalService.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#include <sys/socket.h>

@interface LocalService ()
<
    GCDAsyncUdpSocketDelegate
>
{
    GCDAsyncUdpSocket   *socket; // 套接字
}
@property (strong, nonatomic) dispatch_queue_t queue;
@end

@implementation LocalService

- (void)dealloc {
    self.delegate = nil;
    [self close];
}

#pragma mark
#pragma mark 初始化
/**
 * 初始化
 * 参数 delegate udp代理
 */
- (instancetype)initWithDelegate:(id<LocalServiceDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
#pragma mark
#pragma mark 绑定处理
/**
 * UDP关闭
 */
- (void)close {
    [socket close];
    socket.delegate = nil;
}
/**
 * UDP绑定
 */
- (void)bindToPort:(UInt16)port {
    [self bindToPort:port queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
- (void)bindToPort:(UInt16)port queue:(dispatch_queue_t)delegatequeue {
    [self close];
    self.queue = delegatequeue;
    
    NSError *error = nil;
    socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:delegatequeue];
    if (![socket bindToPort:port error:&error]) {
        NSLog(@"bind>>>>>>>>>>>>>>>绑定端口失败");
    } else if (![socket enableBroadcast:YES error:&error]) {
        NSLog(@"bind>>>>>>>>>>>>>>>开启广播失败");
    } else if (![socket beginReceiving:&error]) {
        NSLog(@"bind>>>>>>>>>>>>>>>开启接受数据失败");
    }
    if (!error) {
        // 过滤本机数据包
        NSString *ipAddress = [self ipAddress];
        [socket setReceiveFilter:^BOOL(NSData *data, NSData *address, __autoreleasing id *context) {
            NSString *tmpAddress = [GCDAsyncUdpSocket hostFromAddress:address];
            return  ![tmpAddress hasSuffix:ipAddress];
        } withQueue:self.queue];
        // 通知代理
        NSLog(@"bind>>>>>>>>>>>>>>>绑定成功");
        if ([self.delegate respondsToSelector:@selector(localServiceDidBind:)]) {
            [self.delegate localServiceDidBind:self];
        }
    } else if ([self.delegate respondsToSelector:@selector(localServiceDidNotBind:error:)]) {
        [self.delegate localServiceDidNotBind:self error:error];
    }
}

#pragma mark
#pragma mark 数据
/**
 * 发送数据
 */
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port {
    [self sendPacket:data toHost:host port:port tag:-1 timeoutInterval:60.0];
}
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self sendPacket:data toHost:host port:port tag:-1 timeoutInterval:timeoutInterval];
}
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port tag:(long)tag {
    [self sendPacket:data toHost:host port:port tag:tag timeoutInterval:60.0];
}
- (void)sendPacket:(NSData *)data toHost:(NSString *)host port:(UInt16)port tag:(long)tag timeoutInterval:(NSTimeInterval)timeoutInterval {
    // 发送数据, 索引号持续增加
    NSLog(@"udp send>>>>>>>>>>>>>>>host = %@, port = %d, tag = %ld\n%@", host, port, tag, [self format:data]);
    [socket sendData:data toHost:host port:port withTimeout:timeoutInterval tag:tag];
}
/**
 * 获取本机地址
 */
- (NSString *)ipAddress {
    NSString *address = @"255.255.255.255";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    if (getifaddrs(&interfaces) == 0 && (temp_addr = interfaces) != NULL) {
        //Loop through linked list of interfaces
        do {
            if(temp_addr->ifa_addr->sa_family == AF_INET &&
               [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                // address
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                break;
            }
        } while ((temp_addr = temp_addr->ifa_next) != NULL);
    }
    //Free memory
    freeifaddrs(interfaces);
    return address;
}


#pragma mark
#pragma mark GCDAsyncUdpSocketDelegate
/**
 * 发送数据成功
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"udp did send>>>>>>>>>>>>>>>tag = %ld", tag);
}
/**
 * 发送数据失败
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"udp send failed>>>>>>>>>>>>>>>error = %@", error);
    if ([self.delegate respondsToSelector:@selector(localService:didNotSendWithTag:error:)]) {
        [self.delegate localService:self didNotSendWithTag:tag error:error];
    }
}
/**
 * UDP接受
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *ipAddress = [GCDAsyncSocket hostFromAddress:address];
    NSLog(@"udp recieve>>>>>>>>>>>>>>>address = %@, port = %u\n%@", [GCDAsyncSocket hostFromAddress:address],
          [GCDAsyncSocket portFromAddress:address], [self format:data]);
    if ([self.delegate respondsToSelector:@selector(localService:didRecieve:address:)]) {
        [self.delegate localService:self didRecieve:data address:ipAddress];
    }
}
/**
 * UDP关闭
 */
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"udp close>>>>>>>>>>>>>>>error = %@", error);
    if (socket == sock && [self.delegate respondsToSelector:@selector(localServiceDidClose:error:)]) {
        [self.delegate localServiceDidClose:self error:error];
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
