//
//  ServiceDriver+UART.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ServiceDriver+UART.h"

@implementation ServiceDriver (Configer)
// 配置
- (void)removeConfigObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubscribeOfConfig];
    [self removeObserver:observer mac:nil forKey:key];
}
- (void)addConfigObserver:(id)observer mac:(NSString *)mac handler:(ConfigHandler)handler {
    NSString *key = [self keyByCode:CodeSubscribeOfConfig];
    [self addObserver:observer mac:nil forKey:key handler:handler];
    if ([self parserWithKey:key]) return;
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(config:completion:) parser:^(NSString *mac, NSString *ssid, UInt8 company, UInt8 type, UInt8 author, id obj){
        NSArray *handlers = [wSelf handlersWithKey:key mac:nil];
        for (ConfigHandler handler in handlers) {
            handler(mac, ssid, company, type, author, obj);
        }
    } forKey:key];
}
// 请求配置命令的订阅
- (void)configSubscribe:(NSString *)ssid enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.remoteOnline) {
        Package *package = [Package configSubscribe:[Package grow] mac:@"FFFFFFFFFFFF" company:DefaultAppCompany type:DefaultAppType author:self.author ssid:ssid enable:enable];
        [self remoteSendPackage:package selector:@selector(subscribe:completion:) parser:handler ? ^(NSString *imac, UInt8 result){
            dispatch_async_main_safe(^{
                handler(result == 0x00);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{badHandler(ServiceOfflineError); });
        }
    }
}
@end

@implementation ServiceDriver (Clock)

// 添加定时(订阅)
- (void)removeClockSettingObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeClockSetting];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addClockSettingObserver:(id)observer mac:(NSString *)mac handler:(ClockControlHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeClockSetting];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    
    if ([self parserWithKey:key]) return;
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(clockSetting:completion:) parser:^(NSString *mac, UInt8 result){
        NSArray *handlers = [wSelf handlersWithKey:key mac:mac];
        for (ClockControlHandler handler in handlers) {
            dispatch_async_main_safe(^{
                handler(mac, result == 0x00);
            });
        }
    } forKey:key];
}

// 移除定时(订阅)
- (void)removeClockClearObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeClockClear];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addClockClearObserver:(id)observer mac:(NSString *)mac handler:(ClockControlHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeClockClear];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    
    if ([self parserWithKey:key]) return;
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(clockClear:completion:) parser:^(NSString *mac, UInt8 result){
        NSArray *handlers = [wSelf handlersWithKey:key mac:mac];
        for (ClockControlHandler handler in handlers) {
            dispatch_async_main_safe(^{
                handler(mac, result == 0x00);
            });
        }
    } forKey:key];
}

// 查询定时(订阅)
// list 中的单元为3元组, 包括 number, clockType, timeInterval
- (void)removeClockQueryObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeClockQuery];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addClockQueryObserver:(id)observer mac:(NSString *)mac handler:(ClockQueryHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeClockQuery];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    
    if ([self parserWithKey:key]) return;
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(clockQuery:completion:) parser:^(NSString *mac, NSArray *list){
        NSArray *handlers = [wSelf handlersWithKey:key mac:mac];
        for (ClockQueryHandler handler in handlers) {
            dispatch_async_main_safe(^{
                handler(mac, list);
            });
        }
    } forKey:key];
}

- (void)clockQueryWithDevice:(WifiDevice *)device handler:(ClockQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package clockQueryWithDevice:device serial:[Package grow]];
        [self localSendPackage:package host:device.ip selector:@selector(clockQuery:completion:) parser:handler ? ^(NSString *mac, NSArray *list) {
            dispatch_async_main_safe(^ {
                handler(mac, list);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package clockQueryWithDevice:device serial:[Package grow]];
        [self remoteSendPackage:package selector:@selector(clockQuery:completion:) parser:handler ? ^(NSString *mac, NSArray *list) {
            dispatch_async_main_safe(^ {
                handler(mac, list);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}
- (void)clockQueryWithDevice:(WifiDevice *)device numbers:(NSArray *)numbers handler:(ClockQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval{
    if (device.localOnline) {
        Package *package = [Package clockQueryWithDevice:device serial:[Package grow] numbers:numbers];
        [self localSendPackage:package host:device.ip selector:@selector(clockQuery:completion:) parser:handler ? ^(NSString *mac, NSArray *list) {
            dispatch_async_main_safe(^ {
                handler(mac, list);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package clockQueryWithDevice:device serial:[Package grow] numbers:numbers];
        [self remoteSendPackage:package selector:@selector(clockQuery:completion:) parser:handler ? ^(NSString *mac, NSArray *list) {
            dispatch_async_main_safe(^ {
                handler(mac, list);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}
- (void)clockClearWithDevice:(WifiDevice *)device clockNumber:(UInt8)number handler:(ClockControlHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval{
    if (device.localOnline) {
        Package *package = [Package clockClearWithDevice:device serial:[Package grow] clockNumber:number];
        [self localSendPackage:package host:device.ip selector:@selector(clockClear:completion:) parser:handler ? ^(NSString *imac, BOOL result) {
            dispatch_async_main_safe(^{
                handler(imac, result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package clockClearWithDevice:device serial:[Package grow] clockNumber:number];
        [self remoteSendPackage:package selector:@selector(clockClear:completion:) parser:handler ? ^(NSString *imac, BOOL result) {
            dispatch_async_main_safe(^{
                handler(imac, result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}
- (void)clockSettingWithDevice:(WifiDevice *)device clockNumber:(UInt8)number closeType:(BOOL)closeType recurWeekDay:(UInt8)recurWeekDay timeInterval:(unsigned long)timeInterval handler:(ClockControlHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval{
    if (device.localOnline) {
        Package *package = [Package clockSettingWithDevice:device serial:[Package grow] clockNumber:number closeType:closeType recurWeekDay:recurWeekDay timeInterval:timeInterval];
        [self localSendPackage:package host:device.ip selector:@selector(clockSetting:completion:) parser:handler ? ^(NSString *mac, BOOL result) {
            dispatch_async_main_safe(^ {
                handler(mac, result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package clockSettingWithDevice:device serial:[Package grow] clockNumber:number closeType:closeType recurWeekDay:recurWeekDay timeInterval:timeInterval];
        [self remoteSendPackage:package selector:@selector(clockSetting:completion:) parser:handler ? ^(NSString *mac, BOOL result) {
            dispatch_async_main_safe(^ {
                handler(mac, result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

@end

@implementation ServiceDriver (UART)
// 开关机，透传请使用发布/订阅模式
- (void)openWithDevice:(WifiDevice *)device open:(BOOL)open timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package runWithDevice:device serial:[Package grow] running:open];
        [self localSendPackage:package host:device.ip timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package runWithDevice:device serial:[Package grow] running:open];
        [self remoteSendPackage:package timeoutInterval:timeoutInterval];
    }
}
// 模式，透传请使用发布/订阅模式
- (void)modeWithDevice:(WifiDevice *)device mode:(UInt8)mode wind:(UInt8)wind timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package modeWithDevice:device serial:[Package grow] mode:mode wind:wind];
        [self localSendPackage:package host:device.ip timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package modeWithDevice:device serial:[Package grow] mode:mode wind:wind];
        [self remoteSendPackage:package timeoutInterval:timeoutInterval];
    }
}
// 风量，透传请使用发布/订阅模式
- (void)windWithDevice:(WifiDevice *)device wind:(UInt8)wind timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package windWithDevice:device serial:[Package grow] wind:wind];
        [self localSendPackage:package host:device.ip timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package windWithDevice:device serial:[Package grow] wind:wind];
        [self remoteSendPackage:package timeoutInterval:timeoutInterval];
    }
}
// 定时，透传请使用发布/订阅模式
- (void)clockWithDevice:(WifiDevice *)device closeType:(BOOL)closeType hour:(UInt8)hour minute:(UInt8)minute timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package clockWithDevice:device serial:[Package grow] closeType:closeType hour:hour minute:minute];
        [self localSendPackage:package host:device.ip selector:nil parser:nil badHandler:nil timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package clockWithDevice:device serial:[Package grow] closeType:closeType hour:hour minute:minute];
        [self remoteSendPackage:package selector:nil parser:nil badHandler:nil timeoutInterval:timeoutInterval];
    }
}
// 查询信息
- (void)infoQueryWithDevice:(WifiDevice *)device timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package infoQueryWithDevice:device serial:[Package grow]];
        [self localSendPackage:package host:device.ip timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package infoQueryWithDevice:device serial:[Package grow]];
        [self remoteSendPackage:package timeoutInterval:timeoutInterval];
    }
}
// 主动上报(订阅)
- (void)submitSubscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.remoteOnline) {
        // 发送数据包
        Package *package = [Package submitSubscribeWithDevice:device serial:[Package grow] enable:YES];
        [self remoteSendPackage:package selector:@selector(subscribe:completion:) parser:^(NSString *imac, UInt8 result) {
            if (!handler) return ;
            dispatch_async_main_safe(^{
                handler(0x00 == result);
            });
        } badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}
// 主动上报(开关机处理)，handler(基于序列号，可为nil)
- (void)removeSubmitOpenObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubmitOfRunning];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubmitOpenObserver:(id)observer mac:(NSString *)mac handler:(SubmitOpenHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeSubmitOfRunning];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(模式处理)，handler(基于序列号，可为nil)
- (void)removeSubmitModeObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubmitOfMode];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubmitModeObserver:(id)observer mac:(NSString *)mac handler:(SubmitModeHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeSubmitOfMode];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(定时处理)，handler(基于序列号，可为nil)
- (void)removeSubmitClockObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubmitOfClock];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubmitClockObserver:(id)observer mac:(NSString *)mac handler:(SubmitClockHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeSubmitOfClock];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(模型处理)，handler(基于序列号，可为nil)
- (void)removeSubmitModelObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubmitOfModel];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubmitModelObserver:(id)observer mac:(NSString *)mac handler:(SubmitModelHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeSubmitOfModel];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}// 主动上报(环境数据处理)，handler(基于序列号，可为nil)
- (void)removeSubmitConditionObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeSubmitOfCondition];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubmitConditionObserver:(id)observer mac:(NSString *)mac handler:(SubmitConditionHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyByCode:CodeSubmitOfCondition];
    [self addObserver:observer mac:mac forKey:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
- (void)addSubmitParser {
    NSString *key = [self keyByCode:CodeControlByDevice];
    if ([self parserWithKey:key]) return ;
    
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(submit:completion:) parser:^(Package *package, UInt8 submitType) {
        switch (submitType) {
            case CodeSubmitOfRunning: { // 开关机
                [Package run:package completion:^(NSString *imac, NSInteger style, UInt8 running) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfRunning];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitOpenHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, 0x01 == running);
                        });
                    }
                }];
            } break;
            case CodeSubmitOfMode: { // 模式
                [Package mode:package completion:^(NSString *imac, NSInteger style, UInt8 mode, UInt8 max, UInt8 level) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfMode];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitModeHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, mode, max, level);
                        });
                    }
                }];
            } break;
            case CodeSubmitOfClock: { // 定时
                [Package clock:package completion:^(NSString *imac, NSInteger style, BOOL enable, BOOL closeType, UInt8 hour, UInt8 minute, UInt8 sec) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfClock];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitClockHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, enable, closeType, hour, minute, sec);
                        });
                    }
                }];
            } break;
            case CodeSubmitOfModel: {  // 型号
                [Package model:package completion:^(NSString *imac, NSInteger style, NSString *model) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfModel];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitModelHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, model);
                        });
                    }
                }];
            } break;
            case CodeSubmitOfCondition: { // 环境数据
                [Package condition:package completion:^(NSString *imac, NSInteger style, UInt8 condition) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfCondition];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitConditionHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, condition);
                        });
                    }
                }];
            } break;
            case CodeSubmitOfComplex : {
                [Package complex:package completion:^(NSString *imac, NSInteger style, UInt8 condition) {
                    NSString *key = [wSelf keyByCode:CodeSubmitOfCondition];
                    NSArray *array = [wSelf handlersWithKey:key mac:imac];
                    for (SubmitConditionHandler handler in array) {
                        dispatch_async_main_safe(^{
                            handler(style, condition);
                        });
                    }
                }];
            }
        }
    } forKey:key];
}

@end
