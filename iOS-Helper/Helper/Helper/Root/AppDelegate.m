//
//  AppDelegate.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "AppDelegate.h"
#import "NSDate+Extension.h"

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
    
    NSDate *now = [NSDate date];
    NSDate *gmt = [NSDate dateWithGMTTimeInterval:[now timeIntervalSince1970]];
    NSLog(@"gmt = %@", [[NSDate defaultFormatter] stringFromDate:gmt]);
    
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
    
    return YES;
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
