//
//  SHLocator.h
//  SHLocator
//
//  Created by Shaojun Han on 7/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class SHLocator;

@protocol SHLocatorDelegate <NSObject>
// 定位成功
- (void)locator:(SHLocator *)locator didUpdateLocations:(NSArray<CLLocation *> *)locations;

@end

@interface SHLocator : NSObject

/**
 * 定位服务是否可用
 * @return 定位服务是否可用
 */
+ (BOOL)locationServicesEnabled;

/**
 * APP定位服务授权信息
 * @return 返回APP定位服务的授权信息
 */
+ (CLAuthorizationStatus)authorizationStatus;

// 代理
@property(weak, nonatomic) id<SHLocatorDelegate> delegate;
// 更新距离
@property(assign, nonatomic) CLLocationDistance distanceFilter;
// 定位精度
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
// 后台定位
@property(assign, nonatomic) BOOL allowsBackgroundLocationUpdate;

/**
 * 初始化方法
 * @param delegate 定位服务代理
 */
- (instancetype)initWithDelegate:(id<SHLocatorDelegate>)delegate;

/**
 * 开始定位
 * @param authority 在用户禁止定位服务或APP定位服务时, 回调
 */
- (void)startUpdatingLocationWithAuthority:(void (^)(CLAuthorizationStatus status))authority;

/**
 * 停止定位
 */
- (void)stopUpdatingLocation;

/**
 * 逆地址转换
 * @param location 位置
 * @param completionHandler 完成时回调
 */
- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler;

/**
 * 逆地址转换
 * @param latitude 纬度
 * @param longitude 经度
 * @param completionHandler 完成时回调
 */
- (void)reverseGeocodeLatitude:(double)latitude longitude:(double)longitude completionHandler:(CLGeocodeCompletionHandler)completionHandler;

@end
