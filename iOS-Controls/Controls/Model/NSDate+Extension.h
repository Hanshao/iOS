//
//  NSDate+Zone.h
//  Controls
//
//  Created by Shaojun Han on 3/5/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

// 将本时间转换成GMT(UTC)时间
- (NSDate *)GMT;

// 将系统当前时间转换成GMT(UTC)时间
+ (NSDate *)GMT;

// date formatter(yyyy/MM/dd hh:mm:ssZ)
+ (NSDateFormatter *)defaultFormatter;

@end
