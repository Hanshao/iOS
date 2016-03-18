//
//  PhotoLayer.h
//  AirCleaner
//
//  Created by Shaojun Han on 10/20/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//  0.1.0 稳定版

#import <UIKit/UIKit.h>

/**
 * 225 * 225的框
 * 半透明背景
 * 扫描横线
 * 提示文本
 */
/**
 * 二维码扫描遮盖层
 * 使用的时候注意设备此视图的背景alpha为0.0
 */
@interface PhotoLayer : UIView

@property (strong, nonatomic) UIImage *boundImage;
@property (strong, nonatomic) UIImage *lineImage;

- (CGRect)clearRectangle;
- (void)startAnimations;
- (void)stopAnimations;

@end
