//
//  XCellAttributes.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XSettingAttrs.h"

@implementation XSettingAttrs

@synthesize backgroundColor = _backgroundColor;
@synthesize selectedBackgroundColor = _selectedBackgroundColor;
@synthesize backgroundView = _backgroundView;
@synthesize selectedBackgroundView = _selectedBackgroundView;
@synthesize separatorColor = _separatorColor;
@synthesize separatorStyle = _separatorStyle;
@synthesize titleTextColor = _titleTextColor;
@synthesize detailTextColor = _detailTextColor;
@synthesize textMaxSize = _textMaxSize;

/**
 *  便利构造器
 *  @param bgColor    背景颜色
 *  @param selBgColor 背景选择颜色
 */
+ (instancetype)xAttrsWithBackgroundColor:(UIColor *)bgColor selBackgroundColor:(UIColor *)selBgColor {
    XTableViewAttrs *attrs = [[XTableViewAttrs alloc] init];
    attrs.backgroundColor = bgColor;
    attrs.selectedBackgroundColor = selBgColor;
    return attrs;
}

/**
 *  便利构造器
 *  @param bgView    背景视图
 *  @param selBgView 背景选择视图
 */
+ (instancetype)xAttrsWithBackgroundView:(UIView *)bgView selBackgroundView:(UIView *)selBgView {
    XTableViewAttrs *attrs = [[XTableViewAttrs alloc] init];
    attrs.backgroundView = bgView;
    attrs.selectedBackgroundView = selBgView;
    return attrs;
}

@end
