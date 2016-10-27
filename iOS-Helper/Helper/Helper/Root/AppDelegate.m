//
//  AppDelegate.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "AppDelegate.h"
#import "NSDate+Helper.h"
#import "NSString+Helper.h"
#import "UIImage+Helper.h"

#import "ChildObject.h"
#import "KeychainItemWrapper.h"


UInt8 CheckSum(UInt8 *bytes, NSUInteger size) {
    UInt8 sum = 0;
    for (int i = 0; i < size ; ++ i) {
        sum += bytes[i];
    }
    return sum;
}

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITableViewCell *cell;
    cell.accessoryView;
    UITableView *tableView;
    tableView.separatorStyle
    UILocalNotification *local;
    NSString *str = {
        @"Nihao"
    };
    NSLog(@"block.init = %@", str);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    [calendar setFirstWeekday:3];
    int weekday = [calendar component:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSLog(@"calendar.weekday = %d", weekday);
    [str sizeWithFont:nil];
    
    NSDate *now = [NSDate date];
    NSDate *gmt = [NSDate dateWithGMTTimeInterval:[now timeIntervalSince1970]];
    NSLog(@"gmt = %@", [[NSDate defaultFormatter] stringFromDate:gmt]);
    ////////////// Keychian 测试 //////////////////////
    NSString *bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
    
    id accessKey = [wrapper objectForKey:(id)kSecValueData];
    if ([accessKey isKindOfClass:NSString.class]) {
        NSLog(@"keychain.accesskey = %@", accessKey);
    } else {
        [wrapper setObject:@"Hello, world." forKey:(id)kSecValueData];
    }
    
    SEL sel = NSSelectorFromString(@"myChildObject:");
    id object = [self performSelector:sel withObject:self];
            
    /////////////////////////////////////////////
    ////////////////////// runtime ////////////////////////////////////////////////////////////////////////////
    // objc
    // objc_msgSend(self, @selector(nslog:), @"Hello, world!!");
    ////////////////////// 日历 ////////////////////////////////////////////////////////////////////////////////
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    components.month = 4; components.day = 19;
//    components.year = 2016;
//    NSTimeInterval interval = [[calendar dateFromComponents:components] timeIntervalSince1970];
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//    
//    NSLog(@"interval = %ld, interval / (24 * 3600) = %f", (unsigned long)interval, interval / (24 * 3600));
//    NSLog(@"timeInterval = %ld, timeInterval / (24 * 3600) = %f", (unsigned long)timeInterval, timeInterval / (24 * 3600));
    ////////////////////// 数据解析 ////////////////////////////////////////////////////////////////////////////////
    /**
    UInt8 bytes[] = {
        0xAA, 0xAA, 0x0C, 0xD2, 0x41, 0x43, 0x33, 0x39, 0xCE, 0x55, 0x55,
        0xAA, 0xAA, 0x0C, 0xD3, 0x53, 0xF9, 0x2B, 0x55, 0x55,
        0xAA, 0xAA, 0x0C, 0xD4, 0x31, 0x05, 0x04, 0x1A, 0x55, 0x55,
        0xAA, 0xAA, 0x0C, 0xD5, 0x00, 0xE1, 0x55, 0x55,
        0xAA, 0xAA, 0x0C, 0xD8, 0x5F, 0x00, 0x43, 0x55, 0x55,
        0xAA, 0xAA, 0x0C, 0xD9, 0x00, 0x00, 0x14, 0x80, 0xC0, 0x39, 0x55, 0x55
    };
    NSInteger size = sizeof(bytes);
    UInt8 *point = bytes, *last = bytes + size;
    UInt8 *start = point, *end = point;
    
    for (; point < last; ++ point) {
        while (point < (last - 1)) {
            if (*point == 0xAA) break;
            ++ point;
        }
        
        if (point >= last - 1)
            break;  // end
        
        start = point; ++ point;
        if (!(0xAA == *point))   // no continuous 0xAA
            break;
        
    u0x55:
        ++ point;
        while (point < (last - 1)) {
            if (*point == 0x55) break;
            ++ point;
        }
        
    n0x55:
        if (point >= last - 1)
            break;  // end
        
        end = point; ++ point;
        if (!(0x55 == *point)) // no continuous 0x55
            goto u0x55;
        
        end = point;
        UInt8 sum = *(end - 2);// the continuous 0x55, do chechsum
        UInt8 csum = CheckSum(start + 2, end - start - 4);
        if (!(sum == csum))
            goto n0x55;
        
        NSData *raw = [NSData dataWithBytes:start length:end - start + 1];
        NSLog(@"%@", raw);
    } **/
    /**
    UInt8 bytes[] = { 0xAA, 0xAA, 0x0C, 0xD2, 0x41, 0x43, 0x33, 0x39, 0xCE, 0x55, 0x55};
    NSInteger size = sizeof(bytes);
    
    NSString *model = nil;
    UInt8 *point = bytes + 4, *start = bytes + 4;
    UInt8 *last = bytes + size, *end = bytes + 4;
    for (; point < last; ++ point) {
        while (point < last - 1) {
            if (*point == 0x55) break;
            ++ point;
        }
        
    n0x55:
        if (point >= last - 1) break;
        ++ point;
        if (!(*point == 0x55))
            continue;
        
        end = point;
        UInt8 sum = *(end - 2);// the continuous 0x55, do chechsum
        UInt8 csum = CheckSum(start - 2, end - start);
        if (!(sum == csum))
            goto n0x55;
        
        NSData *raw = [NSData dataWithBytes:start length:end - start - 2];
        model = [[NSString alloc] initWithData:raw encoding:NSASCIIStringEncoding];
        break;
    }
    
    NSLog(@"%@", model); **/
    ////////////////////// 时间 ////////////////////////////////////////////////////////////////////////////////
//    // 非重复, 触发时间为原时间
//    // 重复, 且达到了定时时间
//    NSDate *today = [NSDate date];
//    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
//    // 下次触发时间
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    [calendar setTimeZone:timeZone];
//    
//    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
//    NSInteger weekDay = components.weekday;
//    
//    NSLog(@"date form component %@, weekDay = %d", [calendar dateFromComponents:components], (int)weekDay);
    /////////////////////////////////////////// 时间 /////////////////////////////////////////////////////////
//    NSDate *newToday = [NSDate date];
//    NSLog(@"now time interval since 1970 %f", [newToday timeIntervalSince1970]);
//    [self datelog];
    ////////////////////////////////////////////// 电话号码验证 ////////////////////////////////////////////////
//    if ([@"0268888888" isPhoneNumber]) {
//        NSLog(@"026正确的固话");
//    } else {
//        NSLog(@"026错误的固话");
//    }
//    if ([@"0258888888" isPhoneNumber]) {
//        NSLog(@"025正确的固话");
//    } else {
//        NSLog(@"025错误的固话");
//    }
//    if ([@"03688888888" isPhoneNumber]) {
//        NSLog(@"036正确的固话");
//    } else {
//        NSLog(@"036错误的固话");
//    }
    ////////////////////////////////////////////// 图片保存到路径 /////////////////////////////////////////////
//    UIImage *image = [UIImage imageWithColor:[UIColor orangeColor] size:CGSizeMake(320, 568)];
//    [image saveToAlbum:@"352Air" completion:^(UIImage *image, NSError *error) {
//        if(error) NSLog(@"保存失败");
//        else  NSLog(@"保存成功");
//    }];
    ///////////////////////////////////////// @dynamic和@synchronize //////////////////////////////////////////////////////////
//    ChildObject *object = [ChildObject new];
//    object.name = @"Han"; object.frame = CGRectMake(0, 0, 100, 100);
//    NSLog(@"object name = %@", object.name);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
//    @try {
//        [self throwNewException];
//    } @catch (NSException *exception) {
//        NSLog(@"Catch one exception = %@.", exception);
//    } @finally {
//        NSLog(@"Codes exceute finally.");
//    }
    /////////////////////////////////////////////Category ////////////////////////////////////////////////////////
    NSString *a = @"abc", *b = @"ABC";
    NSLog(@"%d", (int)[a compare:b]);
    NSLog(@"'abc'.size = %lu", a.ascii_size);
    
    NSLog(@"'你好Hello, pm2.5'.size = %lu", @"你好Hello, pm2.5".ascii_size);
    
    NSString *text = @"你好Hello, pm2.5先生";
    NSUInteger size = [self ascii_subsize:20 text:text];
    NSLog(@"'%@'.substring = %@", text, [text substringToIndex:size]);
    
    NSString *number = [NSString stringWithFormat:@"%@", @(90.6)];
    NSLog(@"number = %@", number);
    
    NSString *json = [NSString jsonWithArray:@[@(5), @"真的吗", @[@"这就很逗了"], @{@"total":@(99)}]];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"json  = %@\nthe reverse = %@\nnormal array = %@\nnormal dictionary = %@",
          json, array, @[@(5), @"真的吗"], @{@"Total":@(99)});
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    return YES;
}

- (ChildObject *)myChildObject:(id)object {
    return [ChildObject new];
}

- (NSUInteger)ascii_subsize:(NSUInteger)size text:(NSString *)text {
    
    NSUInteger nsize = text.length;
    NSUInteger tsize = 0;
    
    for (int i = 0; i < nsize; ++ i) {
        unichar c = [text characterAtIndex:i]; // 按顺序取出单个字符
        if ( isblank(c) || isascii(c)) {
            ++ tsize;
        } else {
            tsize += 2;
        }
        if (tsize > size) {
            return i;
        }
    }
    
    return nsize;
}


- (void)throwNewException {
    @throw [[NSException alloc] init];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)datelog {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:date];
    NSInteger minute = [calendar component:NSCalendarUnitMinute fromDate:date];
    NSLog(@"hour = %d, minute = %d, timeZone = %@", (int)hour, (int)minute, calendar.timeZone);
}
- (void)helloWorld {
    NSLog(@"Hello, world!");
}
- (void)nslog:(NSString *)log {
    NSLog(@"%@", log);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
































