//
//  Package+UART.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "WifiDevice.h"
#import "Package+Factory.h"

static const UInt8 CodeControlToDevice         = 0x01;     // 控制协议1
static const UInt8 CodeControlByDevice         = 0x02;     // 控制协议2
static const UInt8 CodeSubmitOfModel           = 0xD1;     // 型号上传码(内部码)
static const UInt8 CodeSubmitOfRunning         = 0xD2;     // 开关机上传码(内部码)
static const UInt8 CodeSubmitOfMode            = 0xD3;     // 模式上传码(内部码)
static const UInt8 CodeSubmitOfClock           = 0xD5;     // 定时上传码(内部码)
static const UInt8 CodeSubmitOfCondition       = 0xD8;     // 定时上传码(内部码)

/**
 * 串口协议
 */
@interface Package (UART)

// 开关机
+ (Package *)runWithDevice:(WifiDevice *)device serial:(UInt16)serial running:(BOOL)running;

// 风量
+ (Package *)windWithDevice:(WifiDevice *)device serial:(UInt16)serial wind:(UInt8)wind;

// 模式
// 模式切换，档位会恢复为0x01
// mode 档位
// number 档位最大值
+ (Package *)modeWithDevice:(WifiDevice *)device serial:(UInt16)serial mode:(UInt8)mode wind:(UInt8)wind;

// 定时
+ (Package *)clockWithDevice:(WifiDevice *)device serial:(UInt16)serial clockType:(UInt8)clockType time:(NSTimeInterval)time;

/**
 * 开关机、风量、定时、模式的响应
 */
typedef void (^ControlParser)(NSString *imac, UInt8 result);
+ (void)control:(Package *)package completion:(ControlParser)completion;

/**
 * 上报(下位机到上位机)
 */
typedef void (^SubmitParser)(Package *package, UInt8 submitTyle);
+ (Package *)submitSubscribeWithDevice:(WifiDevice *)device serial:(UInt16)serial enable:(BOOL)enable;
+ (void)submit:(Package *)package completion:(SubmitParser)completion;

typedef void (^SubmitRunParser)(NSString *imac, NSInteger style, UInt8 running);
+ (void)run:(Package *)package completion:(SubmitRunParser)completion;

typedef void (^SubmitModeParser)(NSString *imac, NSInteger style, UInt8 mode, UInt8 max, UInt8 level);
+ (void)mode:(Package *)package completion:(SubmitModeParser)completion;

typedef void (^SubmitClockParser)(NSString *imac, NSInteger style, UInt8 clockType, NSTimeInterval time, NSTimeInterval restTime);
+ (void)clock:(Package *)package completion:(SubmitClockParser)completion;

typedef void (^SubmitModelParser)(NSString *imac, NSInteger style, NSString *model);
+ (void)model:(Package *)package completion:(SubmitModelParser)completion;

typedef void (^SubmitConditionParser)(NSString *imac, NSInteger style, UInt8 condition);
+ (void)condition:(Package *)package completion:(SubmitConditionParser)completion;

@end
