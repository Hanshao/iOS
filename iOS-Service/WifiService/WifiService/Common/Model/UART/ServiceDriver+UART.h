//
//  ServiceDriver+UART.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ServiceDriver.h"
#import "WifiDevice.h"
#import "Package+UART.h"

@interface ServiceDriver (Configer)
typedef void (^ConfigHandler)(NSString *imac, NSString *ssid, UInt8 company, UInt8 type, UInt8 author, id obj);
- (void)removeConfigObserver:(id)observer mac:(NSString *)mac;
- (void)addConfigObserver:(id)observer mac:(NSString *)mac handler:(ConfigHandler)handler;
// 请求配置命令的订阅
- (void)configSubscribe:(NSString *)ssid enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
@end

// 定时
@interface ServiceDriver (Clock)
typedef void (^ClockControlHandler)(NSString *mac, BOOL result);
// 添加定时(订阅)
- (void)removeClockSettingObserver:(id)observer mac:(NSString *)mac;
- (void)addClockSettingObserver:(id)observer mac:(NSString *)mac handler:(ClockControlHandler)handler;

// 移除定时(订阅)
- (void)removeClockClearObserver:(id)observer mac:(NSString *)mac;
- (void)addClockClearObserver:(id)observer mac:(NSString *)mac handler:(ClockControlHandler)handler;

// 查询定时(订阅)
// list 中的单元为4元组, 包括 number, closeType, recurring, timeInterval
typedef void (^ClockQueryHandler)(NSString *mac, NSArray *list);
- (void)removeClockQueryObserver:(id)observer mac:(NSString *)mac;
- (void)addClockQueryObserver:(id)observer mac:(NSString *)mac handler:(ClockQueryHandler)handler;

// 发送命令
- (void)clockQueryWithDevice:(WifiDevice *)device handler:(ClockQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)clockQueryWithDevice:(WifiDevice *)device numbers:(NSArray *)numbers handler:(ClockQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)clockClearWithDevice:(WifiDevice *)device clockNumber:(UInt8)number handler:(ClockControlHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)clockSettingWithDevice:(WifiDevice *)device clockNumber:(UInt8)number closeType:(BOOL)closeType recurWeekDay:(UInt8)recurWeekDay timeInterval:(unsigned long)timeInterval handler:(ClockControlHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;

@end

@interface ServiceDriver (UART)

// 控制回调
typedef void (^ControlHandler)(BOOL success);
// 开关机，透传请使用发布/订阅模式
typedef void (^OpenHandler)();
- (void)openWithDevice:(WifiDevice *)device open:(BOOL)open timeoutInterval:(NSTimeInterval)timeoutInterval;
// 模式，透传请使用发布/订阅模式
typedef void (^ModeHandler)();
- (void)modeWithDevice:(WifiDevice *)device mode:(UInt8)mode wind:(UInt8)wind timeoutInterval:(NSTimeInterval)timeoutInterval;
// 风量，透传请使用发布/订阅模式
typedef void (^WindHandler)();
- (void)windWithDevice:(WifiDevice *)device wind:(UInt8)wind timeoutInterval:(NSTimeInterval)timeoutInterval;
// 定时, 透传请使用发布/订阅模式
typedef void (^ClockHandler)();
- (void)clockWithDevice:(WifiDevice *)device closeType:(BOOL)closeType hour:(UInt8)hour minute:(UInt8)minute timeoutInterval:(NSTimeInterval)timeoutInterval;
// 查询信息
- (void)infoQueryWithDevice:(WifiDevice *)device timeoutInterval:(NSTimeInterval)timeoutInterval;

// 主动上报(订阅)
- (void)submitSubscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
// 主动上报(开关机处理)，handler(基于序列号，可为nil)
typedef void (^SubmitOpenHandler)(NSInteger style, BOOL opening);
- (void)removeSubmitOpenObserver:(id)oberver mac:(NSString *)mac;
- (void)addSubmitOpenObserver:(id)observer mac:(NSString *)mac handler:(SubmitOpenHandler)handler;
// 主动上报(模式处理)，handler(基于序列号，可为nil)
typedef void (^SubmitModeHandler)(NSInteger style, UInt8 mode, UInt8 max, UInt8 level);
- (void)removeSubmitModeObserver:(id)observer mac:(NSString *)mac;
- (void)addSubmitModeObserver:(id)observer mac:(NSString *)mac handler:(SubmitModeHandler)handler;
// 主动上报(定时处理)，handler(基于序列号，可为nil)
typedef void (^SubmitClockHandler)(NSInteger style, BOOL enable, BOOL closeType, UInt8 hour, UInt8 minute, UInt8 sec);
- (void)removeSubmitClockObserver:(id)observer mac:(NSString *)mac;
- (void)addSubmitClockObserver:(id)observer mac:(NSString *)mac handler:(SubmitClockHandler)handler;
// 主动上报(型号处理)，handler(基于序列号，可为nil)
typedef void (^SubmitModelHandler)(NSInteger style, NSString *model);
- (void)removeSubmitModelObserver:(id)observer mac:(NSString *)mac;
- (void)addSubmitModelObserver:(id)observer mac:(NSString *)mac handler:(SubmitModelHandler)handler;
// 主动上报(环境数据处理)，handler(基于序列号，可为nil)
typedef void (^SubmitConditionHandler)(NSInteger style, UInt8 quality);
- (void)removeSubmitConditionObserver:(id)observer mac:(NSString *)mac;
- (void)addSubmitConditionObserver:(id)observer mac:(NSString *)mac handler:(SubmitConditionHandler)handler;

@end
