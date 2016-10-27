//
//  Device.m
//  JiaBo
//
//  Created by Shaojun Han on 12/29/15.
//  Copyright © 2015 Hadlinks. All rights reserved.
//

#import "WifiDevice.h"
#import "ServiceDriver.h"
#import "GCDTimer.h"

@interface WifiDevice ()

@property (assign, nonatomic) BOOL beatEnable;
@property (strong, nonatomic) dispatch_source_t beatTimer;

@end

@implementation WifiDevice

@synthesize mac = _mac, ip = _ip;
@synthesize type = _type, author = _author, company = _company;

- (instancetype)init {
    if (self = [super init]) {
        self.type = DefaultDeviceType;
        self.author = DefaultDeviceAuthor;
        self.company = DefaultDeviceCompany;
    }
    return self;
}

/**
 * 心跳
 */
- (void)setBeatEnable:(BOOL)enable {
    _beatEnable = enable;
    if (!enable) { CancelTimer(self.beatTimer); }
}
- (void)beatWithTimeInterval:(NSTimeInterval)timeInterval {
    _beatEnable = YES;
    CancelTimer(self.beatTimer);
    __weak typeof(self) wSelf = self;
    self.beatTimer = ScheduledRecurringTimer(nil, timeInterval, ^{
        [wSelf beatOnce:timeInterval];
    });
}
- (void)beatOnce:(NSTimeInterval)timeInterval {
    CancelTimer(self.beatTimer);
    if(!self.beatEnable) return;
    // 这里必须要先启动超时计时器
    __weak typeof(self) wSelf = self;
    [ServiceDriverInstance beatWithDevice:self handler:^(NSInteger style, NSTimeInterval timeInterval) {
        [wSelf beatWithTimeInterval:timeInterval];
    } badHandler:^(NSInteger error) {
        [wSelf beatTimeout];
    } timeoutInterval:0.5 * timeInterval];
}
- (void)beatTimeout {
    CancelTimer(self.beatTimer);
    // 超时则转到主线程执行
    dispatch_async_main_safe(^() {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kWifiDeviceBeatTimeoutKey object:self];
    });
}

@end
