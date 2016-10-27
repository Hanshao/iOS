//
//  AppDelegate.m
//  XSetting
//
//  Created by Xaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/**
 * 睡眠时间段(start - end之间的睡眠时间段)
 * @param array 数据源，item为NSDictionary, 必须是按时间字段有序的
 * @param start 开始时间
 * @param end 结束时间, 满足start < end
 * @param interval 时间间隔, 不为0
 * @return outArray 结果数据，item为NSDictionary
 */
NSArray* sleepTimes(NSArray *array, unsigned long start, unsigned long end, unsigned long interval) {
    unsigned long icursor = 0; // icursor 为连续计数标志
    NSInteger token = 0, offtoken = 0;
    NSInteger gcount = 0, scount = 0, offcount = 0, tickcount = 0;
    NSMutableArray *outArray = @[].mutableCopy, *groupArray = nil;
    for (NSDictionary *item in array) {
        // 类型
        NSInteger type = [[item objectForKey:@"type"] integerValue];
        if (type != 2) continue;
        // 获取时间
        NSString *time = [item objectForKey:@"time"];
        long cur = [dateFormatTime(time) timeIntervalSince1970];
        // 获取step数据
        NSInteger step = [[item objectForKey:@"step"] integerValue];
        if (cur >= start && icursor == 0) { // 第一次进入睡眠点
            icursor = cur + interval;  // 开始计数
            token = 0, offtoken = 0;
            gcount = 0, scount = 0, offcount = 0, tickcount = 0;
            groupArray = @[].mutableCopy;
        } else if (cur > start && cur < end) {  // 睡眠时间区间内
            if (cur == icursor) {    // 连续计数
                // 睡眠时间点 - 起床时间点的整 interval 分钟
                // 摘下计数
                offcount = 0 == step ? offcount + 1 : 0;
                // 进入睡眠计数
                scount = step < 40 ? scount + 1 : 0;
                // 起床计数
                gcount = step >= 40 ? gcount + 1 : 0;
                // 设置token
                token = scount >= 3 ? 1 : gcount < 3 ? token : 0;
                offtoken = offcount >= 16 ? 1 : gcount < 3 ? offtoken : 0;
                // 清理之前的数据
                if (gcount == 3) {  // 第一次出现连续3次 > 40
                    NSInteger count = groupArray.count;
                    NSInteger num = MIN(count, tickcount);
                    if (num) {
                        NSRange range = NSMakeRange(count - num, num);
                        [groupArray removeObjectsInRange:range];
                    }
                }
                icursor += interval;
            } else if (cur > icursor) { // 出现非连续计数
                // 计数清0
                offcount = 0, scount = 0, gcount = 0, tickcount = 0;
                // token清0
                token =  0, offtoken = 0;
                // 之前的数据为无效数据
                if (groupArray.count > 0) {
                    [outArray addObject:[NSArray arrayWithArray:groupArray]];
                    groupArray = @[].mutableCopy;
                }
                while (cur > icursor) {
                    icursor += interval;
                }
            }
            // 统计
            tickcount += gcount > 0 && (token == 1 && offtoken == 0) ? 1 : 0;
            if (token == 1 && offtoken == 0) {
                // 进入睡眠，且没有摘下
                [groupArray addObject:item];
            } else {
                if (groupArray.count > 0) {
                    [outArray addObject:[NSArray arrayWithArray:groupArray]];
                    groupArray = @[].mutableCopy;
                }
            }
        } else if (cur >= end) {
            // 到达结束时间
            if (cur == end) {
                if (groupArray.count > 0) {
                    [outArray addObject:[NSArray arrayWithArray:groupArray]];
                    groupArray = @[].mutableCopy;
                }
                break;
            }
        }
    }
    return [NSArray arrayWithArray:outArray];
}

// 以下算法基于准确的数据时间点


/**
 * 时间
 * @param time 格式为2016-08-17 08:53的时间
 * @return NSDate类型
 */
NSDate *dateFormatTime(NSString *time) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    });
    return [formatter dateFromString:time];
}


- (BOOL)application:(UIApplication *)application didFiniXLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 测试
    NSArray *array = @[@{@"type":@(2), @"step":@(6), @"time":@"2016-08-17 08:53"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 08:54"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 08:55"},
                       @{@"type":@(2), @"step":@(10), @"time":@"2016-08-17 08:56"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 08:57"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 08:58"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 08:59"},
                       @{@"type":@(2), @"step":@(8), @"time":@"2016-08-17 09:00"},
                       @{@"type":@(1), @"step":@(26), @"time":@"2016-08-17 09:01"},
                       @{@"type":@(1), @"step":@(180), @"time":@"2016-08-17 09:02"},
                       @{@"type":@(1), @"step":@(46), @"time":@"2016-08-17 09:03"},
                       @{@"type":@(1), @"step":@(52), @"time":@"2016-08-17 09:04"},
                       @{@"type":@(1), @"step":@(233), @"time":@"2016-08-17 09:05"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 09:06"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 09:07"},
                       @{@"type":@(2), @"step":@(0), @"time":@"2016-08-17 09:08"},
                       @{@"type":@(2), @"step":@(8), @"time":@"2016-08-17 09:09"},
                       @{@"type":@(1), @"step":@(26), @"time":@"2016-08-17 09:10"},
                       @{@"type":@(1), @"step":@(180), @"time":@"2016-08-17 09:12"}];
//    NSArray *outArray = sleepTimes(array, [dateFormatTime(@"2016-08-17 08:53") timeIntervalSince1970], [dateFormatTime(@"2016-08-17 09:12") timeIntervalSince1970], 1 * 60);
//    NSLog(@"out.array = %@", outArray);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games Xould use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release Xared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refreX the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
