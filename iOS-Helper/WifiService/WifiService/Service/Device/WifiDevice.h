//
//  Device.h
//  JiaBo
//
//  Created by Shaojun Han on 12/29/15.
//  Copyright © 2015 Hadlinks. All rights reserved.
//  0.3.0 结构化
//  0.3.1 优化

#import <Foundation/Foundation.h>

// 心跳超时通知
#define  kWifiDeviceBeatTimeoutKey  @"kWifiDeviceBeatTimeoutKey"

@interface WifiDevice : NSObject
{
    @public
    UInt8   _type;
    UInt16  _author;
    UInt8   _company;
    
    NSString *_mac;
    NSString *_ip;
}

// 基本信息
@property (strong, nonatomic) NSString *mac;    // mac 地址
@property (strong, nonatomic) NSString *ip;     // ip 地址
// 设备代码（整型）
@property (assign, nonatomic) UInt8     company;    // 公司码
@property (assign, nonatomic) UInt8     type;       // 设备类型码
@property (assign, nonatomic) UInt16    author;     // 授权码
// 网络
@property (assign, nonatomic) BOOL localOnline;     // 本地在线
@property (assign, nonatomic) BOOL remoteOnline;    // 远程在线

/**
 * 心跳
 */
- (void)setBeatEnable:(BOOL)enable;
- (void)beatWithTimeInterval:(NSTimeInterval)timeInterval;

@end
