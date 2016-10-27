//
//  HttpServer.m
//  HttpServer
//
//  Created by Shaojun Han on 7/13/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "EchoServer.h"

#define READ_TIMEOUT 15.0

@interface EchoServer ()
<
    GCDAsyncSocketDelegate
>
@end

@interface EchoServer ()
{
    GCDAsyncSocket *socket; // 监听Socket
    NSMutableDictionary *linkSocks; // 连接的Socket
    dispatch_queue_t linked_queue;  // 并发队列
}
@end

@implementation EchoServer

- (instancetype)init {
    if (self = [super init]) {
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:global_queue];
        linked_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
        linkSocks = @{}.mutableCopy;
    }
    return self;
}

- (BOOL)listen {
    NSError *error = nil;
    if(![socket acceptOnPort:8000 error:&error]) {
        NSLog(@"listen fialed and error log = %@", error);
        return NO;
    }
    return YES;
}
- (void)stop {
    for (GCDAsyncSocket *sock in linkSocks.allValues) {
        [sock disconnect];
    }
    [socket disconnect];
}

#pragma mark
#pragma mark GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    // 添加到列表中
    NSInteger number = linkSocks.count;
    [linkSocks setObject:newSocket forKey:@(number).stringValue];
    NSLog(@"accept new socket = %@", newSocket);
    // 进入新的处理队列
    newSocket.delegate = self;
    newSocket.delegateQueue = linked_queue;
    // 读取数据
    [newSocket readDataWithTimeout:-1 tag:0];//very important
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataStr);
    [sock writeData:[self getHTMLHeader] withTimeout:READ_TIMEOUT tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}

#pragma mark
#pragma mark Data Handle
- (NSData *)getHTMLHeader {
    NSMutableString *header = @"".mutableCopy;
    [header appendString:@"HTTP/1.1 200\r\n"];
    [header appendString:@"Connection: close\r\n"];
    [header appendString:@"Server: Apache/1.3.0(Mac OS X)\r\n"];
    [header appendString:@"Content-Type: text/html\r\n"];
    // 内容部分
    NSString *hello = @"Hello, world!";
    NSData *data = [hello dataUsingEncoding:NSUTF8StringEncoding];
    [header appendString:[NSString stringWithFormat:@"Content-Length: %d\r\n", (int)data.length]];
    [header appendString:@"\r\n"];
    [header appendString:hello];
    return [header dataUsingEncoding:NSUTF8StringEncoding];
}

@end
