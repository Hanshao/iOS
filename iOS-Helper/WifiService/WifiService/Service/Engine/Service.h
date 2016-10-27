//
//  Service.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/11/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//  0.3.1 结构化

#ifndef Service_CocoaAsyncSocket
#define Service_CocoaAsyncSocket

#import "CocoaAsyncSocket.h"

#endif /** Service_CocoaAsyncSocket **/

#ifndef Service_Protocol
#define Service_Protocol

//static NSString *const AddressOflevelingServer      = @"boneco-test.yunext.com";  // 负载均衡服务器地址
//static UInt16   const PortOflevelingServer          = 17591;  // 负载均衡服务器端口
//static UInt16   const PortOflocalService            = 17530;  // 局域网端口
static NSString *const AddressOflevelingServer      = @"smarthome.yofoto.cn";  // 负载均衡服务器地址
static UInt16   const PortOflevelingServer          = 35191;  // 负载均衡服务器端口
static UInt16   const PortOflocalService            = 35190;  // 局域网端口

static NSString *const SSLCertificateFile           = @"pushsslcert.p12"; // 证书
static NSString *const SSLCertificatePassword       = @"11235813"; // 证书访问密码

static UInt8 const DefaultDeviceCompany             = 0xFA;   // 设备默认公司码
static UInt8 const DefaultDeviceType                = 0xDA;   // 设备默认类型码
static UInt16 const DefaultDeviceAuthor             = 0x0000; // 设备默认授权码

static UInt8 const DefaultAppCompany                = 0xA1;   // APP默认公司码
static UInt8 const DefaultAppType                   = 0xBB;   // APP默认类型码
static UInt16 const DefaultAppAuthor                = 0x0000; // APP默认授权码
//static UInt8 const DefaultAppAccessKey[]            = {0x65, 0x6B, 0x69, 0x75, 0x72, 0x6F};
static UInt8 const DefaultAppAccessKey[]            = {0x73, 0x61, 0x6E, 0x73, 0x68, 0x65};

#endif /* Service_Protocol */


#ifndef Service_Main_Safe
#define Service_Main_Safe

#define dispatch_sync_main_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_async_main_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

#endif /* Service_Main_Safe */
