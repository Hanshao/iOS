//
//  Package.m
//  AirCleaner
//
//  Created by Shaojun Han on 9/14/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "Package.h"

@implementation Package

/**
 * 便利构造器
 */
+ (instancetype)packageWithPackage:(Package *)package {
    Package *newPackage = [Package new];
    newPackage.header = package.header;
    newPackage.code = package.code;
    newPackage.raw = [NSData dataWithData:package.raw];
    return newPackage;
}

/**
 * 初始化器
 * 参数：data 包括 header 和 raw 部分的网络字节序内容
 */
- (instancetype)initWithData:(NSData *)data {
    return [self initWithData:data style:-1 mark:nil];
}
- (instancetype)initWithData:(NSData *)data style:(NSInteger)style {
    return [self initWithData:data style:style mark:nil];
}
- (instancetype)initWithData:(NSData *)data style:(NSInteger)style mark:(NSString *)mark {
    if (!(self = [super init])) return self;
    if ((data.length) < sizeof(Header)) return self; // 数据部分起始偏移量
    
    _style = style; _mark = mark;
    
    int length = (int)data.length - sizeof(Header);
    // 数据长度满足要求，进行初始化
    UInt8 *bytes = (UInt8 *)[data bytes];
    // 处理
    memcpy(&_header, bytes, sizeof(Header));
    // 数据部分
    _code = length >= sizeof(UInt8) ? *(bytes + sizeof(Header)) : 0;
    _raw = length > sizeof(UInt8) ? [NSData dataWithBytes:bytes + sizeof(UInt8) + sizeof(Header)
                                                   length:length - sizeof(UInt8)] : nil;
    return self;
}
- (instancetype)initWithHeader:(Header)header code:(UInt8)code raw:(NSData *)raw {
    if (self = [super init]) {
        _header = header;
        _code = code;
        _raw = raw ? [raw copy] : nil;
    }
    return self;
}

/**
 * 转换成NSData类型
 * 返回：包括 header 和 raw 的网络字节序内容
 */
- (NSData *)data {
    NSMutableData *result = [NSMutableData
                             dataWithCapacity:(sizeof(_header) + sizeof(_code) + _raw.length)];
    [result appendBytes:&_header length:sizeof(_header)];
    [result appendBytes:&_code length:sizeof(_code)];
    if (_raw) [result appendData:_raw];
    return [NSData dataWithData:result];
}

/**
 * 工具方法
 */
- (UInt16)serial {
    UInt8 *byte = self.header.serial;
    UInt8 sh = byte[0], sl = byte[1];
    return ((UInt16)sh << 8) | sl;
}
+ (UInt16)serial:(Package *)package {
    return [package serial];
}

@end
