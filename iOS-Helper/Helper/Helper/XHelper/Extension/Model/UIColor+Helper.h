//
//  UIColor+Helper.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 拓展(UIColor)
 * 1. 构造函数
 * 2. 便利构造
 */

/**
 * 参数 red 红色, 0 - 255
 * 参数 green 绿, 0 - 255
 * 参数 blue 蓝, 0 - 255
 * 参数 alpha 透明度, 0.0 - 1.0
 */
UIColor* RGB(UInt8 red, UInt8 green, UInt8 blue);
UIColor* RGBA(UInt8 red, UInt8 green, UInt8 blue, CGFloat alpha);

/**
 * 参数 hue 色相, 0 - 255
 * 参数 sat 饱和度, 0 - 255
 * 参数 bir 亮度, 0 - 255
 * 参数 alpha 透明度, 0.0 - 1.0
 */
UIColor* HSB(UInt8 hue, UInt8 sat, UInt8 bri);
UIColor* HSBA(UInt8 hue, UInt8 sat, UInt8 bri, CGFloat alpha);

@interface UIColor (Instance)
+ (instancetype)RGBA:(unsigned long)rgba;
+ (instancetype)RGB:(unsigned long)rgb;
@end

