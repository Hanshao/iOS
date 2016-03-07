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
 * 1. 标准时间(格林威治时间)
 * 2. 时间格式
 */
@interface NSDate (GMT)

// 将本时间转换成GMT(UTC)时间
- (NSDate *)GMT;

// 将系统当前时间转换成GMT(UTC)时间
+ (NSDate *)GMT;

@end


@interface NSDate (Formatter)

// date formatter(yyyy/MM/dd hh:mm:ssZ)
+ (NSDateFormatter *)defaultFormatter;

@end
