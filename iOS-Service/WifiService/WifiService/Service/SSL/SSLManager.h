//
//  SSLManager.h
//  ProtocolTest
//
//  Created by Shaojun Han on 9/21/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.0

#import <Foundation/Foundation.h>

/**
 * SSL管理类
 * 说明 该类提供了SSL配置的生成方法, 并提供了一个默认证书的文件名和密码
 */
@interface SSLManager : NSObject 

/**
 * 生成证书配置
 * 参数 host 主机
 * 参数 other 证书配置中添加的额外参数, 可以为nil
 * 参数 file 证书文件名, 不可为nil
 * 参数 key 证书文件密码, 必须是file的正确密码
 */
+ (NSDictionary *)sslSettingsWithHost:(NSString *)host
                                 file:(NSString *)file key:(NSString *)key other:(NSDictionary *)other;

@end
