//
//  NSDate+Zone.m
//  Controls
//
//  Created by Shaojun Han on 3/5/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Instance)

+ (instancetype)dateWithGMTTimeInterval:(NSTimeInterval)timeInterval {
    //设置转换后的目标日期时区
    NSTimeZone *sourceTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *destTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];//或GMT
    
    NSDate *now = [NSDate date];
    NSTimeInterval sourceInterval = [sourceTimeZone secondsFromGMTForDate:now];
    NSTimeInterval destInterval = [destTimeZone secondsFromGMTForDate:now];
    timeInterval += sourceInterval - destInterval;
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}
// 当前天的时，分钟
+ (instancetype)dateWithHour:(NSInteger)hour minute:(NSInteger)minute {
    return [self dateWithHour:hour minute:minute second:0];
}
+ (instancetype)dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSDate *date = [NSDate date];
    long long timeInterval = [date timeIntervalSince1970];
    timeInterval = (hour * 3600 + minute * 60 + second) - timeInterval%(24 * 3600);
    return [NSDate dateWithTimeInterval:timeInterval sinceDate:date];
}

@end

@implementation NSDate (GMT)

// 将本时间转换成UTC(GMT)时间
- (NSDate *)GMT {
    //设置转换后的目标日期时区
    NSTimeZone *sourceTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *destTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];//或GMT
    
    NSTimeInterval sourceInterval = [sourceTimeZone secondsFromGMTForDate:self];
    NSTimeInterval destInterval = [destTimeZone secondsFromGMTForDate:self];
    NSTimeInterval timeInterval = - sourceInterval + destInterval;
    return [NSDate dateWithTimeInterval:timeInterval sinceDate:self];
}

// 将系统当前时间转换成UTC时间
+ (NSDate *)GMT {
    //设置转换后的目标日期时区
    NSTimeZone *sourceTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *destTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];//或GMT
    
    NSDate *now = [NSDate date];
    NSTimeInterval sourceInterval = [sourceTimeZone secondsFromGMTForDate:now];
    NSTimeInterval destInterval = [destTimeZone secondsFromGMTForDate:now];
    NSTimeInterval timeInterval = - sourceInterval + destInterval;
    return [NSDate dateWithTimeInterval:timeInterval sinceDate:now];
}

@end

@implementation NSDate (Interval)
// 当前几号
- (NSInteger)days {
    long long timeInterval = [self timeIntervalSince1970];
    return timeInterval/(24 * 3600);
}
// 当前时
- (NSInteger)hours {
    long long timeInterval = [self timeIntervalSince1970];
    return timeInterval/3600;
}
// 当前分
- (NSInteger)minutes {
    long long timeInterval = [self timeIntervalSince1970];
    return timeInterval/60;
}
// 当前秒
- (NSInteger)seconds {
    long long timeInterval = [self timeIntervalSince1970];
    return timeInterval;
}
@end

@implementation NSDate (Calendar)

+ (NSCalendar *)defaultCalendar {
    return [NSCalendar currentCalendar];
}

- (NSInteger)year {
    NSCalendarUnit unitFlag = NSCalendarUnitYear;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] year];
}
- (NSInteger)month {
    NSCalendarUnit unitFlag = NSCalendarUnitMonth;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] month];
}
- (NSInteger)week {
    NSCalendarUnit unitFlag = NSCalendarUnitWeekday;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] weekday];
}
- (NSInteger)day {
    NSCalendarUnit unitFlag = NSCalendarUnitDay;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] day];
}
- (NSInteger)hour {
    NSCalendarUnit unitFlag = NSCalendarUnitHour;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] hour];
}
- (NSInteger)minute {
    NSCalendarUnit unitFlag = NSCalendarUnitMinute;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] minute];
}
- (NSInteger)second {
    NSCalendarUnit unitFlag = NSCalendarUnitSecond;
    NSCalendar *calendar = [NSDate defaultCalendar];
    return [[calendar components:unitFlag fromDate:self] second];
}

@end


@implementation NSDate (Formatter)

// 可复用
static NSDateFormatter *formatter = nil;

// date formatter(yyyy/MM/dd hh:mm:ss)
+ (NSDateFormatter *)defaultFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ssZ"];
    return formatter;
}

@end
