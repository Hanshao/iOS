//
//  XCellAttributes.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XCellAttributes : NSObject

// 列表样式 注意：只适用于使用分类UIViewController+XSettings.h方式）
@property (assign, nonatomic) UITableViewStyle tableViewStyle;

// 背景色
@property (nonatomic, strong) UIColor *cellBackgroundColor;
// 选中时背景色
@property (nonatomic, strong) UIColor *cellSelectedBackgroundColor;
// 背景视图
@property (nonatomic, strong) UIView *cellBackgroundView;
// 选中时背景色
@property (nonatomic, strong) UIView *cellSelectedBackgroundView;
// Cell分割线
@property (assign, nonatomic) BOOL cellFullLineEnable;
//  禁止显示最后一条线
@property (nonatomic, assign) BOOL disableBottomLine;
// Cell分割线颜色
@property (nonatomic, strong) UIColor *cellBottomLineColor;

// Content
//  标题颜色
@property (nonatomic, strong) UIColor *cellTitleTextColor;
//  子标题文字颜色
@property (nonatomic, strong) UIColor *cellDetailTextColor;
//  标题文字大小
@property (nonatomic, assign) CGFloat cellTextMaxSize;

/**
 *  便利构造器
 *  @param bgColor    背景颜色
 *  @param selBgColor 背景选择颜色
 */
+ (instancetype)cellAttributesWithBackgroundColor:(UIColor *)bgColor selBackgroundColor:(UIColor *)selBgColor;

/**
 *  便利构造器
 *  @param bgView    背景视图
 *  @param selBgView 背景选择视图
 */
+ (instancetype)cellAttributesWithBackgroundView:(UIView *)bgView selBackgroundView:(UIView *)selBgView;

@end
