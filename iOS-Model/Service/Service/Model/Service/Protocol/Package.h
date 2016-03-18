//
//  Package.h
//  AirCleaner
//
//  Created by Shaojun Han on 9/14/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.0

#import <Foundation/Foundation.h>

/**
 * 协议头, 应以网络字节序存储
 * 定义结构体时，注意字节对齐
 */
typedef struct {
    UInt8   version;        // 版本
    UInt8   flag;           // 标志
    UInt8   mac[6];         // MAC 地址
    UInt8   length;         // 长度, 长度是自长度字段后面的所有字节长度
    UInt8   reserved;       // 保留字段
    UInt8   serial[2];      // 协议序号
    UInt8   company;        // 厂家代码
    UInt8   type;           // 设备类型码
    UInt8   author[2];      // 授权码
} Header;


/**
 * 协议类
 * 协议栈中的应用层协议
 * 协议数据
 * 协议解析
 */
@interface Package : NSObject
// 数据信息
@property (assign, nonatomic) Header header;    // 协议头
@property (assign, nonatomic) UInt8  code;      // 命令字段
@property (strong, nonatomic) NSData *raw;      // 协议数据部分
// 标识信息
@property (assign, nonatomic) NSInteger style;  // 数据包类型
@property (strong, nonatomic) NSString  *mark;  // 附加标志，更多信息

/**
 * 便利构造器
 */
+ (instancetype)packageWithPackage:(Package *)package;

/**
 * 初始化器
 * 参数 data, 网络返回的数据包, 包括 header 和 raw 部分的网络字节序内容
 * 参数 style, 数据包类型(标识)
 * 参数 mark, 数据包附加标志(标识)
 */
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data style:(NSInteger)style;
- (instancetype)initWithData:(NSData *)data style:(NSInteger)style mark:(NSString *)mark;

/**
 * 初始化器
 * 参数 header, 协议头
 * 参数 code, 协议命令码
 * 参数 raw, 协议数据
 */
- (instancetype)initWithHeader:(Header)header code:(UInt8)code raw:(NSData *)raw;

/**
 * 转换成NSData类型
 * 返回 包括 header 和 raw 的网络字节序内容
 */
- (NSData *)data;

/**
 * 工具方法
 */
- (UInt16)serial;
+ (UInt16)serial:(Package *)package;

@end

