//
//  XCellAttributes.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XCellAttributes.h"

@implementation XCellAttributes

/**
 *  便利构造器
 *  @param bgColor    背景颜色
 *  @param selBgColor 背景选择颜色
 */
+ (instancetype)cellAttributesWithBackgroundColor:(UIColor *)bgColor selBackgroundColor:(UIColor *)selBgColor {
    XCellAttributes *attributes = [[XCellAttributes alloc] init];
    attributes.cellBackgroundColor = bgColor;
    attributes.cellSelectedBackgroundColor = selBgColor;
    return attributes;
}

/**
 *  便利构造器
 *  @param bgView    背景视图
 *  @param selBgView 背景选择视图
 */
+ (instancetype)cellAttributesWithBackgroundView:(UIView *)bgView selBackgroundView:(UIView *)selBgView {
    XCellAttributes *attributes = [[XCellAttributes alloc] init];
    attributes.cellBackgroundView = bgView;
    attributes.cellSelectedBackgroundView = selBgView;
    return attributes;
}

@end
