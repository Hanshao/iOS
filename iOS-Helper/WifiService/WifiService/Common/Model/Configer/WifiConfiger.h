//
//  WifiConfiger.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/15/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WifiCofigerInstance [WifiConfiger sharedInstance]

/**
 * 完成与失败的回调
 */
typedef void (^ConfigCompletion)(NSInteger result, NSString *message);
typedef void (^ConfigBadHandler)(NSInteger result, NSString *message);

/**
 * WIFI配置类
 * 该类依赖于第三方wifi模块
 */
@interface WifiConfiger : NSObject

/**
 * 初始化
 * password wifi密码
 * completion 成功回调
 * failure 失败回调，失败包括超时
 * timeout 超时时间，在超时时间内如果失败则持续请求
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeoutInterval
                     completion:(ConfigCompletion)completion failure:(ConfigBadHandler)failure;

/**
 * 启动与停止配置
 * 启动，重新超时配置
 * 停止，强制停止配置，即便没到超时时间
 */
- (void)configWithWifiKey:(NSString *)wifiKey;
- (void)stopConfiging;

@end
