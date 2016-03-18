//
//  ServiceManager+UART.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ServiceManager+UART.h"

@implementation ServiceManager (UART)

// 开关机，handler(基于序列号，可为nil)
- (void)openWithDevice:(WifiDevice *)device open:(BOOL)open handler:(ControlHandler)handler {
    if (!(self.remoteOnline || device.localOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        OpenHandler newHandler = [handler copy];
        [self addSelector:@selector(control:completion:) parser:^(NSString *imac, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package runWithDevice:device serial:serial running:open];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 模式，handler(基于序列号，可为nil)
- (void)modeWithDevice:(WifiDevice *)device mode:(UInt8)mode wind:(UInt8)wind handler:(ControlHandler)handler {
    if (!(self.remoteOnline || device.localOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        ModeHandler newHandler = [handler copy];
        [self addSelector:@selector(control:completion:) parser:^(NSString *imac, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package modeWithDevice:device serial:serial mode:mode wind:wind];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 风量，handler(基于序列号，可为nil)
- (void)windWithDevice:(WifiDevice *)device wind:(UInt8)wind handler:(ControlHandler)handler {
    if (!(self.remoteOnline || device.localOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        ModeHandler newHandler = [handler copy];
        [self addSelector:@selector(control:completion:) parser:^(NSString *imac, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package windWithDevice:device serial:serial wind:wind];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 定时，handler(基于序列号，可为nil)
- (void)clockWithDevice:(WifiDevice *)device clockType:(UInt8)clockType time:(NSTimeInterval)time handler:(ControlHandler)handler {
    if (!(self.remoteOnline || device.localOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        ModeHandler newHandler = [handler copy];
        [self addSelector:@selector(control:completion:) parser:^(NSString *imac, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package clockWithDevice:device serial:serial clockType:clockType time:time];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 主动上报(订阅)
- (void)submitSubscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler {
    if (!self.remoteOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        SubscribeHandler newHandler = [handler copy];
        [self addSelector:@selector(subscribe:completion:) parser:^(NSString *imac, UInt8 result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    // 发送数据包
    Package *package = [Package submitSubscribeWithDevice:device serial:serial enable:YES];
    [self remoteSendPackage:package];
}
// 主动上报(开关机处理)，handler(基于序列号，可为nil)
- (void)removeSubmitOpenObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeSubmitOfRunning];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addSubmitOpenObserver:(id)observer mac:(NSString *)mac handler:(SubmitOpenHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyWithCode:CodeSubmitOfRunning];
    [self addObserver:observer mac:mac key:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(模式处理)，handler(基于序列号，可为nil)
- (void)removeSubmitModeObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeSubmitOfMode];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addSubmitModeObserver:(id)observer mac:(NSString *)mac handler:(SubmitModeHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyWithCode:CodeSubmitOfMode];
    [self addObserver:observer mac:mac key:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(定时处理)，handler(基于序列号，可为nil)
- (void)removeSubmitClockObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeSubmitOfClock];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addSubmitClockObserver:(id)observer mac:(NSString *)mac handler:(SubmitClockHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyWithCode:CodeSubmitOfClock];
    [self addObserver:observer mac:mac key:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
// 主动上报(模型处理)，handler(基于序列号，可为nil)
- (void)removeSubmitModelObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeSubmitOfModel];
    [self removeObserver:observer mac:mac key:key];

}
- (void)addSubmitModelObserver:(id)observer mac:(NSString *)mac handler:(SubmitModelHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyWithCode:CodeSubmitOfModel];
    [self addObserver:observer mac:mac key:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}// 主动上报(环境数据处理)，handler(基于序列号，可为nil)
- (void)removeSubmitConditionObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeSubmitOfCondition];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addSubmitConditionObserver:(id)observer mac:(NSString *)mac handler:(SubmitConditionHandler)handler {
    if (!handler) return;
    
    NSString *key = [self keyWithCode:CodeSubmitOfCondition];
    [self addObserver:observer mac:mac key:key handler:handler];
    // 除了订阅命令，还要处理观察者
    [self addSubmitParser];
}
- (void)addSubmitParser {
    if ([self parserWithCode:CodeControlByDevice]) return ;
    
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(submit:completion:) parser:^(Package *package, UInt8 submitType) {
        switch (submitType) {
            case CodeSubmitOfRunning:  // 开关机
            {
                [Package run:package completion:^(NSString *imac, NSInteger style, UInt8 running) {
                    NSString *key = [weakSelf keyWithCode:CodeSubmitOfRunning];
                    NSArray *array = [weakSelf handlerWithKey:key mac:imac];
                    for (SubmitOpenHandler handler in array) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(style, 0x01 == running);
                        });
                    }
                }];
            }
                break;
            case CodeSubmitOfMode:  // 模式
            {
                [Package mode:package completion:^(NSString *imac, NSInteger style, UInt8 mode, UInt8 max, UInt8 level) {
                    NSString *key = [weakSelf keyWithCode:CodeSubmitOfMode];
                    NSArray *array = [weakSelf handlerWithKey:key mac:imac];
                    for (SubmitModeHandler handler in array) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(style, mode, max, level);
                        });
                    }
                }];
            }
                break;
            case CodeSubmitOfClock:  // 定时
            {
                [Package clock:package completion:^(NSString *imac, NSInteger style, UInt8 clockType, NSTimeInterval time, NSTimeInterval restTime) {
                    NSString *key = [weakSelf keyWithCode:CodeSubmitOfClock];
                    NSArray *array = [weakSelf handlerWithKey:key mac:imac];
                    for (SubmitClockHandler handler in array) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(style, clockType, time, restTime);
                        });
                    }
                }];
            }
                break;
            case CodeSubmitOfModel:  // 定时
            {
                [Package model:package completion:^(NSString *imac, NSInteger style, NSString *model) {
                    NSString *key = [weakSelf keyWithCode:CodeSubmitOfModel];
                    NSArray *array = [weakSelf handlerWithKey:key mac:imac];
                    for (SubmitModelHandler handler in array) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(style, model);
                        });
                    }
                }];
            }
                break;
            case CodeSubmitOfCondition:  // 定时
            {
                [Package condition:package completion:^(NSString *imac, NSInteger style, UInt8 condition) {
                    NSString *key = [weakSelf keyWithCode:CodeSubmitOfCondition];
                    NSArray *array = [weakSelf handlerWithKey:key mac:imac];
                    for (SubmitConditionHandler handler in array) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handler(style, condition);
                        });
                    }
                }];
            }
                break;

        }
    } code:CodeControlByDevice];
}

@end
