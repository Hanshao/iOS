//
//  WifiConfiger.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/15/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "WifiConfiger.h"
#import "HiJoine.h"

typedef NS_ENUM(NSInteger, WifiConfigerStatus) {
    WifiConfigerStatusStoped = 0,  // 停止
    WifiConfigerStatusConfiging = 1, // 配置中
    WifiConfigerStatusTimeout = 2 // 已经超时
};

@interface WifiConfiger ()
<
    HiJoineDelegate
>

{
    HiJoine         *hiJoine;       // 利尔达wifi sdk
    NSTimer         *timeoutTimer;  // 计时器
    NSTimeInterval  timeInterval;   // 超时时间
    NSString        *wifiKey;       // 密码
    WifiConfigerStatus status;      // 配置状态
}

@property (copy, nonatomic) ConfigCompletion completion;
@property (copy, nonatomic) ConfigBadHandler failure;

@end

@implementation WifiConfiger

- (void)dealloc {
    status = WifiConfigerStatusStoped;
    [timeoutTimer invalidate];
    timeoutTimer = nil;
}

/**
 * 初始化
 * completion 成功回调
 * failure 失败回调，失败包括超时
 * timeout 超时时间，在超时时间内如果失败则持续请求
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeoutInterval
                     completion:(ConfigCompletion)completion failure:(ConfigBadHandler)failure {
    if (self = [self init]) {
        timeInterval = timeoutInterval;
        self.completion = completion;
        self.failure = failure;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        // sdk
        hiJoine = [HiJoine new];
        hiJoine.delegate = self;
        // 状态
        status = WifiConfigerStatusStoped;
    }
    return self;
}

/**
 * 启动与停止配置
 */
- (void)configWithWifiKey:(NSString *)aWifiKey {
    [self stopConfiging];
    
    wifiKey = aWifiKey;
    status = WifiConfigerStatusConfiging;
    [self configure];
}
- (void)stopConfiging {
    status = WifiConfigerStatusStoped;
    [timeoutTimer invalidate];
}

#pragma mark
#pragma mark 回调处理
- (void)hiJoinCompletion:(NSInteger)result message:(NSString *)message {
    // －1 超时  －2  ssid 空   1 成功，message 为mac地址
    if (1 == result && status == WifiConfigerStatusConfiging) {
        // 完成 UDP发现设备
        NSLog(@"%s >>>>>>> success", __FUNCTION__);
        [self stopConfiging];
        if(self.completion) self.completion(result, message);
        // 转入设备搜索
    } else if (status == WifiConfigerStatusConfiging) {
        NSLog(@"%s >>>>>>> configing", __FUNCTION__);
        [self configure];
    } else {
        NSLog(@"%s >>>>>>> failure", __FUNCTION__);
        if (self.failure) self.failure(result, message);
    }
}

/**
 * 启动广播
 * 不清空计时器
 */
- (void)configure {
    __weak typeof(self) weakSelf = self;
    [hiJoine setBoardDataWithPassword:wifiKey withBackBlock:^(NSInteger result, NSString *message) {
        [weakSelf hiJoinCompletion:result message:message];
    }];
    // 启动定时器
    [timeoutTimer invalidate]; timeoutTimer =
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(stopConfiging) userInfo:nil repeats:NO];
}

#pragma mark
#pragma mark HiJoine代理
/**
 *  HiJoine 成功的代理
 *  @param sucess 返回的mac
 */
- (void)HiJoineWiFiSucceed:(NSString *)succeed {
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  HiJoine 失败的代理
 *  @param error 返回失败参数
 */
- (void)HiJoineWiFiError:(NSString *)error {
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  超时回调
 */
- (void)HiJoineWiFiTimeOut {
    NSLog(@"%s", __FUNCTION__);
}

@end
