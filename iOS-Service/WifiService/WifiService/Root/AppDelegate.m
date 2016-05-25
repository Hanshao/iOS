//
//  AppDelegate.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 12/1/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ServiceDriver.h"

@interface AppDelegate ()
<
    NSXMLParserDelegate
>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 通信层注册网络测试通知, 默认情况下, 通信层并不进行此注册, 这会让通信层可以更加灵活.
    [ServiceDriverInstance registerReachableService];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *welcomeViewCtrl = [[ViewController alloc] init];
    self.window.rootViewController = welcomeViewCtrl;
    [self.window makeKeyAndVisible];
    
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
    /////////////////////////////// 这里需要根据登录状态进行判断是否需要重连 ///////////////////////////////
    BOOL hadLogin = YES;
    if (!ServiceDriverInstance.remoteOnline && hadLogin)
        [ServiceDriverInstance launch];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
