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
static const UInt8 CodeClockSetting            = 0x03;     // 定时协议-设置定时
static const UInt8 CodeClockQuery              = 0x04;     // 定时协议-查询定时
static const UInt8 CodeClockClear              = 0x05;     // 定时协议-删除定时
static const UInt8 CodeSubmitOfModel           = 0xD1;     // 型号上传码(内部码)
static const UInt8 CodeSubmitOfRunning         = 0xD2;     // 开关机上传码(内部码)
static const UInt8 CodeSubmitOfMode            = 0xD3;     // 模式上传码(内部码)
static const UInt8 CodeSubmitOfClock           = 0xD5;     // 定时上传码(内部码)
static const UInt8 CodeSubmitOfCondition       = 0xD8;     // 环境指数上传码(内部码)
static const UInt8 CodeSubmitOfRuntime         = 0xD9;     // 运行时间上传码(内部码)
static const UInt8 CodeSubmitOfComplex         = 0xDB;     // 复合数据上传码(内部码)

/**
 * 长定时协议
 */
@interface Package (Clock)

// 0x03 设置定时协议
typedef void (^ClockControlParser)(NSString *mac, UInt8 result);
+ (Package *)clockSettingWithDevice:(WifiDevice *)device serial:(UInt16)serial clockNumber:(UInt8)number closeType:(BOOL)closeType recurWeekDay:(UInt8)recurWeekDay timeInterval:(unsigned long)timeInterval;
+ (void)clockSetting:(Package *)package completion:(ClockControlParser)completion;

// 0x05 删除定时协议
+ (Package *)clockClearWithDevice:(WifiDevice *)device serial:(UInt16)serial clockNumber:(UInt8)number;
+ (void)clockClear:(Package *)package completion:(ClockControlParser)completion;

// 0x04 定时查询协议
// list 中的单元为4元组, 包括 number, closeType, reucrWeekday, timeInterval
typedef void (^ClockQueryParser)(NSString *mac, NSArray *list);
+ (Package *)clockQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial;
+ (Package *)clockQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial numbers:(NSArray *)numbers;
+ (void)clockQuery:(Package *)package completion:(ClockQueryParser)completion;

@end

/**
 * 配置协议
 */
@interface Package (Configer)
// 订阅配置
typedef void (^ConfigParser)(NSString *imac, NSString *ssid, UInt8 company, UInt8 type, UInt16 author, id obj);
+ (Package *)configSubscribe:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)autho ssid:(NSString *)ssid enable:(BOOL)enable;
+ (void)config:(Package *)package completion:(ConfigParser)completion;

@end

/**
 * 串口协议
 */
@interface Package (UART)
// 开关机
+ (Package *)runWithDevice:(WifiDevice *)device serial:(UInt16)serial running:(BOOL)running;
// 风量
+ (Package *)windWithDevice:(WifiDevice *)device serial:(UInt16)serial wind:(UInt8)wind;
// mode 档位, 模式切换，档位会恢复为0x01
// number 档位最大值
+ (Package *)modeWithDevice:(WifiDevice *)device serial:(UInt16)serial mode:(UInt8)mode wind:(UInt8)wind;
// 定时
+ (Package *)clockWithDevice:(WifiDevice *)device serial:(UInt16)serial closeType:(BOOL)closeType hour:(UInt8)hour minute:(UInt8)minute;
// 查询设备状态
+ (Package *)infoQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial;

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

typedef void (^SubmitClockParser)(NSString *imac, NSInteger style, BOOL enable, BOOL closeType, UInt8 hour, UInt8 minute, UInt8 sec);
+ (void)clock:(Package *)package completion:(SubmitClockParser)completion;

typedef void (^SubmitModelParser)(NSString *imac, NSInteger style, NSString *model);
+ (void)model:(Package *)package completion:(SubmitModelParser)completion;

typedef void (^SubmitConditionParser)(NSString *imac, NSInteger style, UInt8 condition);
+ (void)condition:(Package *)package completion:(SubmitConditionParser)completion;

typedef void (^ComplexParser)(NSString *imac, NSInteger style, UInt8 condition);
+ (void)complex:(Package *)package completion:(ComplexParser)completion;

@end
