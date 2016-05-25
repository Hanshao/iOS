//
//  NSDate+Zone.h
//  Controls
//
//  Created by Shaojun Han on 3/5/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 拓展(NSDate)
 * 1. 便利构造
 * 2. 标准时间(格林威治时间)
 * 3. 日历(年, 月, 周, 时, 分, 秒)
 * 4. 时间格式
 */
@interface NSDate (Instance)
+ (instancetype)dateWithGMTTimeInterval:(NSTimeInterval)timeInterval;
// 当前天的时, 分
+ (instancetype)dateWithHour:(NSInteger)hour minute:(NSInteger)minute;
// 当前天的时, 分, 秒
+ (instancetype)dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
@end


@interface NSDate (GMT)
// 将本时间转换成GMT(UTC)时间
- (NSDate *)GMT;
// 将系统当前时间转换成GMT(UTC)时间
+ (NSDate *)GMT;
@end


@interface NSDate (Calendar)
// 默认日历
+ (NSCalendar *)defaultCalendar;
// 公历年
- (NSInteger)year;
// 当前月份
- (NSInteger)month;
// 当前周几
- (NSInteger)weekDay;
// 当前几号
- (NSInteger)day;
// 当前时
- (NSInteger)hour;
// 当前分
- (NSInteger)minute;
// 当前秒
- (NSInteger)second;
@end


@interface NSDate (Formatter)
// 默认date formatter(yyyy/MM/dd HH:mm:ssZ)(HH表示24小时制)
+ (NSDateFormatter *)defaultFormatter;
@end
