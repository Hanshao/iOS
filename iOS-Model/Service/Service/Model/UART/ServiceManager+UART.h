//
//  ServiceManager+UART.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ServiceManager.h"
#import "WifiDevice.h"
#import "Package+UART.h"

@interface ServiceManager (UART)

// 项目专属
typedef void (^ControlHandler)(BOOL success);
// 开关机，handler(基于序列号，可为nil)
typedef void (^OpenHandler)();
- (void)openWithDevice:(WifiDevice *)device open:(BOOL)open handler:(ControlHandler)handler;

// 模式，handler(基于序列号，可为nil)
typedef void (^ModeHandler)();
- (void)modeWithDevice:(WifiDevice *)device mode:(UInt8)mode wind:(UInt8)wind handler:(ControlHandler)handler;

// 风量，handler(基于序列号，可为nil)
typedef void (^WindHandler)();
- (void)windWithDevice:(WifiDevice *)device wind:(UInt8)wind handler:(ControlHandler)handler;

// 定时，handler(基于序列号，可为nil)
typedef void (^ClockHandler)();
- (void)clockWithDevice:(WifiDevice *)device clockType:(UInt8)clockType time:(NSTimeInterval)time handler:(ControlHandler)handler;

// 主动上报(订阅)
- (void)submitSubscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler;
// 主动上报(开关机处理)，handler(基于序列号，可为nil)
typedef void (^SubmitOpenHandler)(NSInteger style, BOOL opening);
- (void)removeSubmitOpenObserver:(id)oberver mac:(NSString *)mac;
- (void)addSubmitOpenObserver:(id)observer mac:(NSString *)mac handler:(SubmitOpenHandler)handler;
// 主动上报(模式处理)，handler(基于序列号，可为nil)
typedef void (^SubmitModeHandler)(NSInteger style, UInt8 mode, UInt8 max, UInt8 level);
- (void)removeSubmitModeObserver:(id)observer mac:(NSString *)mac;
- (void)addSubmitModeObserver:(id)observer mac:(NSString *)mac handler:(SubmitModeHandler)handler;
// 主动上报(定时处理)，handler(基于序列号，可为nil)
typedef void (^SubmitClockHandler)(NSInteger style, UInt8 clockType, NSTimeInterval time, NSTimeInterval restTime);
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
