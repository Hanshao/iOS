//
//  HSSegmentView.h
//  AirCleaner
//
//  Created by Shaojun Han on 9/8/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//  0.1.1 稳定版

#import <UIKit/UIKit.h>

/**
 * 分组代理
 */
@class HSSegmentView;
@protocol HSSegmentViewDelegate <NSObject>
@optional
- (void)segmentView:(HSSegmentView *)view itemSelectedAtIndex:(NSInteger)index;
@end

/**
 * 自定义分组控件
 */
@interface HSSegmentView : UIView

- (instancetype)initWithTitles:(NSArray *)titles;
- (void)setTitles:(NSArray *)titles;

@property (strong, nonatomic) UIColor       *selectedBackgroundColor;   // 选中时背景色
@property (strong, nonatomic) UIColor       *normalBackgroundColor;     // 正常背景色
@property (strong, nonatomic) UIColor       *selectedTextColor;         // 选中时文本颜色
@property (strong, nonatomic) UIColor       *normalTextColor;           // 正常文本颜色
@property (strong, nonatomic) UIColor       *normalLineColor;           // 正常下划线颜色
@property (strong, nonatomic) UIColor       *selectedLineColor;         // 选中时下划线颜色

@property (strong, nonatomic) UIFont        *font;                      // 文本文字
@property (assign, nonatomic) NSInteger     selectedIndex;              // 选中行的
@property (weak, nonatomic) id<HSSegmentViewDelegate>       delegate;   // 代理

- (NSString *)titleAtIndex:(NSInteger)index;
- (void)setTitle:(NSString *)title atIndex:(NSInteger)index;

@end
