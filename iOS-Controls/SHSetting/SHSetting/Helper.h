//
//  Helper.h
//  SHSetting
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * UIColor生成函数
 * @param red 0-255, RGB中红色分量
 * @param green 0-255, RGB中绿色分量
 * @param blue 0-255, RGB中蓝色分量
 */
UIColor *RGB(UInt8 red, UInt8 green, UInt8 blue);

/**
 * UIColor生成函数
 * @param red 0-255, RGB中红色分量
 * @param green 0-255, RGB中绿色分量
 * @param blue 0-255, RGB中蓝色分量
 * @param alpha 0-1.0, alpha通道分量
 */
UIColor *RGBA(UInt8 red, UInt8 green, UInt8 blue, CGFloat alpha);

/**
 * UIImage生成函数
 * @param color 颜色
 * @return 生成的纯色图片
 */
UIImage *imageWithColor(UIColor *color);