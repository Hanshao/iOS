//
//  HSPolyline.h
//  AirCleaner
//
//  Created by Shaojun Han on 2/15/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSPolyline;

/**
 * 数据源
 */
@protocol HSPolylineDataSource <NSObject>
@required
- (NSInteger)numberOfRowsInPolyline:(HSPolyline *)polyline;
- (NSInteger)numberOfColumnsInPolyline:(HSPolyline *)polyline;

@optional
- (NSString *)polyline:(HSPolyline *)polyline titleOfColumn:(NSInteger)column;
- (CGFloat)polyline:(HSPolyline *)polyline valueOfColumn:(NSInteger)column;
- (CGFloat)polyline:(HSPolyline *)polyline value2OfColumn:(NSInteger)column;
- (UIColor *)polyline:(HSPolyline *)polyline colorAtStart:(NSInteger)start end:(NSInteger)end;
- (UIColor *)polyline:(HSPolyline *)polyline color2AtStart:(NSInteger)start end:(NSInteger)end;

@end


/**
 * 代理
 */
@protocol HSPolylineDelegate <NSObject>
@optional
- (void)polyline:(HSPolyline *)polyline touchAtPoint:(CGPoint)point value:(CGFloat)value;

@end


/**
 * 折线图类
 */
@interface HSPolyline : UIView

@property (assign, nonatomic) CGFloat ymax;
@property (assign, nonatomic) CGFloat ymin;
@property (assign, nonatomic) CGFloat itemSpacing;
@property (assign, nonatomic) CGFloat sectionSpacing;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *lineColor;

@property (weak, nonatomic) UIView *accessoryView;

@property (weak, nonatomic) id<HSPolylineDataSource> dataSource;
@property (weak, nonatomic) id<HSPolylineDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
// 刷新
- (void)reloadData;

@end
