//
//  NSDate+Zone.m
//  Controls
//
//  Created by Shaojun Han on 3/5/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

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

// date formatter(yyyy/MM/dd hh:mm:ss)
+ (NSDateFormatter *)defaultFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ssZ"];
    });
    return formatter;
}

@end
