//
//  Device.m
//  JiaBo
//
//  Created by Shaojun Han on 12/29/15.
//  Copyright © 2015 Hadlinks. All rights reserved.
//

#import "WifiDevice.h"
#import "ServiceManager.h"

@interface WifiDevice ()

@property (assign, nonatomic) BOOL beatEnable;
@property (strong, nonatomic) dispatch_source_t beatTimer;

@end

@implementation WifiDevice

@synthesize mac = _mac, ip = _ip;
@synthesize type = _type, author = _author, company = _company;

/**
 * 心跳
 */
- (void)setBeatEnable:(BOOL)enable {
    _beatEnable = enable;
    _beatEnable = enable;
    if (!enable && self.beatTimer)
        dispatch_source_cancel(self.beatTimer);
}
- (void)beatWithTimeInterval:(NSTimeInterval)timeInterval {
    self.beatEnable = YES;
    
    @synchronized(self.beatTimer) {
        if (self.beatTimer) dispatch_source_cancel(self.beatTimer);
        __weak typeof(self) weakSelf = self;
        self.beatTimer = [self scheduledWithTimeinterval:timeInterval action:^{
            [weakSelf beatOnce:timeInterval];
        }];
    }
}
- (void)beatOnce:(NSTimeInterval)timeInterval {
    if(!self.beatEnable) return;
    
    @synchronized(self.beatTimer) {
        // 这里必须要先启动超时计时器
        if (self.beatTimer) dispatch_source_cancel(self.beatTimer);
        __weak typeof(self) weakSelf = self;
        self.beatTimer = [self scheduledWithTimeinterval:2 * timeInterval action:^{
            [weakSelf beatTimeout];
        }];
    }
    // 再发送心跳包
    [ServiceManagerInstance beatWithDevice:self handler:nil]; // 心跳
}
- (void)beatTimeout {
    @synchronized(self.beatTimer) {
        if (self.beatTimer) dispatch_source_cancel(self.beatTimer);
    }
    // 超时则转到主线程执行
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kWifiDeviceBeatTimeoutKey object:self];
    });
}
- (dispatch_source_t)scheduledWithTimeinterval:(NSTimeInterval)timeinterval action:(dispatch_block_t)action {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, timeinterval * NSEC_PER_SEC),
                              timeinterval * NSEC_PER_SEC, 0.2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{ action(); });
    dispatch_resume(timer);
    return timer;
}

@end
