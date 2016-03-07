//
//  UIColor+Extension.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 拓展(UIColor)
 * 1. 便利构造
 */
@interface UIColor (Instance)

+ (instancetype)RGBA:(unsigned long)rgba;
+ (instancetype)RGB:(unsigned long)rgb;

@end

