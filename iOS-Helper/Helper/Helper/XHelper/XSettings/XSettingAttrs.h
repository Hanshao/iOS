//
//  XCellAttributes.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XCellAttrsSeparatorStyle) {
    XCellAttrsSeparatorStyleNone,   // 无分割线
    XCellAttrsSeparatorStyleSingleLine,
    XCellAttrsSeparatorStyleInnerSingleLine // 除尾部cell的分割线
};

@protocol XCellAttrs <NSObject>

// 背景色
@property (strong, nonatomic) UIColor *backgroundColor;
// 选中时背景色
@property (strong, nonatomic) UIColor *selectedBackgroundColor;

// 背景视图
@property (strong, nonatomic) UIView *backgroundView;
// 选中时背景色
@property (strong, nonatomic) UIView *selectedBackgroundView;

// Cell分割线颜色
@property (strong, nonatomic) UIColor *separatorColor;
@property (assign, nonatomic) XCellAttrsSeparatorStyle separatorStyle;

// Content
//  标题颜色
@property (strong, nonatomic) UIColor *titleTextColor;
//  子标题文字颜色
@property (strong, nonatomic) UIColor *detailTextColor;
//  标题文字大小
@property (assign, nonatomic) CGFloat textMaxSize;

@end

@interface XSettingAttrs : NSObject <XCellAttrs>

// 列表样式 注意：只适用于使用分类UIViewController+XSettings.h方式）
@property (assign, nonatomic) UITableViewStyle tableViewStyle;

/**
 *  便利构造器
 *  @param bgColor    背景颜色
 *  @param selBgColor 背景选择颜色
 */
+ (instancetype)xAttrsWithBackgroundColor:(UIColor *)bgColor selBackgroundColor:(UIColor *)selBgColor;

/**
 *  便利构造器
 *  @param bgView    背景视图
 *  @param selBgView 背景选择视图
 */
+ (instancetype)xAttrsWithBackgroundView:(UIView *)bgView selBackgroundView:(UIView *)selBgView;

@end
