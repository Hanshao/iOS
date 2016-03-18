//
//  Service.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/11/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//  0.3.0 结构化

#ifndef Service_h
#define Service_h

static NSString *AddressOflevelingServer      = @"boneco-test.yunext.com";
static UInt16   PortOflevelingServer          = 17591;
static UInt16   PortOflocalService            = 17530;

static NSString *SSLCertificateFile           = @"pushsslcert.p12"; // 证书
static NSString *SSLCertificatePassword       = @"11235813"; // 证书访问密码

static UInt8 DefaultDeviceCompany         = 0xFA;
static UInt8 DefaultDeviceType            = 0xDA;
static UInt16 DefaultDeviceAuthor         = 0x0000;

static UInt8 CodeOfAppCompany             = 0xA1;
static UInt8 CodeOfAppType                = 0xBB;
static UInt16 CodeOfAppAuthor             = 0x0000;
static UInt8 CodeOfAppAccessKey[]         = {0x65, 0x6B, 0x69, 0x75, 0x72, 0x6F};

#endif /* Service_h */
