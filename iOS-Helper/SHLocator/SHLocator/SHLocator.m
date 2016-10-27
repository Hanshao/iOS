//
//  SHLocator.m
//  SHLocator
//
//  Created by Shaojun Han on 7/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "SHLocator.h"

@interface SHLocator ()
<
    CLLocationManagerDelegate
>
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocationManager *llmanager;

@end

@implementation SHLocator
/**
 * 初始化方法
 * @param delegate 定位服务代理
 */
- (instancetype)initWithDelegate:(id<SHLocatorDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

/**
 * 定位服务开启状态
 */
+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}
/**
 * APP定位服务状态
 */
+ (CLAuthorizationStatus)authorizationStatus {
    return [CLLocationManager authorizationStatus];
}

/**
 * 开始定位
 */
- (void)startUpdatingLocationWithAuthority:(void (^)(CLAuthorizationStatus status))authority {
    // 定位服务授权
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) { // 已经被用户明确禁止定位
        case kCLAuthorizationStatusRestricted: case kCLAuthorizationStatusDenied: {
            //提示用户打开定位
            if (authority) authority(authorizationStatus);
        } break;
            
        case kCLAuthorizationStatusNotDetermined: { // 没有确定授权
            if([self.llmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.llmanager requestAlwaysAuthorization];
                NSLog(@"%@", @"Request location when in use authority.");
            } else if([self.llmanager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.llmanager requestWhenInUseAuthorization];
                NSLog(@"%@", @"Request location always authority.");
            } else {  // 非iOS8, 直接启动
                [self.llmanager startUpdatingLocation];
            }
        } break;

        default: { // 已经授权
            [self.llmanager startUpdatingLocation];
        } break;
    }
}

/**
 * 停止定位
 */
- (void)stopUpdatingLocation {
    [self.llmanager stopUpdatingLocation];
}

/**
 * 逆地址转换
 */
- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    [self.geocoder reverseGeocodeLocation:location completionHandler:completionHandler];
}
- (void)reverseGeocodeLatitude:(double)latitude longitude:(double)longitude completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self reverseGeocodeLocation:location completionHandler:completionHandler];
}

// 后台更新
- (BOOL)allowsBackgroundLocationUpdate {
    return self.llmanager.allowsBackgroundLocationUpdates;
}
- (void)setAllowsBackgroundLocationUpdate:(BOOL)allowsBackgroundLocationUpdate {
    self.llmanager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdate;
}
// 精确度
- (CLLocationAccuracy)desiredAccuracy {
    return self.llmanager.desiredAccuracy;
}
- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    self.llmanager.desiredAccuracy = desiredAccuracy;
}
// 更新距离
- (CLLocationDistance)distanceFilter {
    return self.llmanager.distanceFilter;
}
- (void)setDistanceFilter:(CLLocationDistance)distanceFilter {
    self.llmanager.distanceFilter = distanceFilter;
}
// 懒加载
- (CLLocationManager *)llmanager {
    if (_llmanager) return _llmanager;
    _llmanager = [[CLLocationManager alloc] init];
    _llmanager.desiredAccuracy = kCLLocationAccuracyHundredMeters;  // 定位精度
    _llmanager.distanceFilter = 100.0f; // 更新距离
    _llmanager.delegate = self;
    return _llmanager;
}
// 逆编码
- (CLGeocoder *)geocoder {
    if (_geocoder) return _geocoder;
    _geocoder = [[CLGeocoder alloc] init];
    return _geocoder;
}
/**
 * 代理方法
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted: case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusNotDetermined: {
            return;
        }   break;
            
        default: {
            [manager startUpdatingLocation];
        }   break;
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([self.delegate respondsToSelector:@selector(locator:didUpdateLocations:)]) {
        [self.delegate locator:self didUpdateLocations:locations];
    }
}

@end
