//
//  AppDelegate.m
//  YiMaoAgent
//
//  Created by Apple on 16/1/22.
//  Copyright © 2016年 oubuy·luo. All rights reserved.
//

#import "AppDelegate.h"


#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSString *string = @"你好";
//    NSString *acsiiString = [NSString stringWithFormat:@"%s", [string cStringUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"acsii %@", acsiiString);
//    UITextView *textView;
//    textView.translatesAutoresizingMaskIntoConstraints;
    
//    NSString *title;
//    [title drawInRect:CGRectZero withAttributes:nil];
//    UIImage *image;
//    [image drawInRect:CGRectZero];
//    
//    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(-20, 0) forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor orangeColor]];
//    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
//    [UIView appearance].backgroundColor = [UIColor grayColor];
    
    UIImage *image = [UIImage imageNamed:@"boneco_rectangle_blue"];
    image = [self filter:image];
    [self filter:image];
    return YES;
}

- (UIImage *)filter:(UIImage *)image {
    CIImage *iimage = [CIImage imageWithCGImage:image.CGImage];
    // 滤镜的名字为CIColorControls, 查看所有内置滤镜 [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:iimage forKey:kCIInputImageKey];
    
    NSLog(@"AppDelegate.launch.brightness = %@", [filter valueForKey:@"inputBrightness"]);
    NSLog(@"AppDelegate.launch.saturation = %@", [filter valueForKey:@"inputSaturation"]);
    NSLog(@"AppDelegate.launch.contrast = %@", [filter valueForKey:@"inputContrast"]);
    
    [filter setValue:@(0.2) forKey:@"inputBrightness"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *oiimage = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgimage = [context createCGImage:oiimage fromRect:[iimage extent]];
    return [UIImage imageWithCGImage:cgimage];
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
