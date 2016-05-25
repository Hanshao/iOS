//
//  UIColor+Helper.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIColor+Helper.h"

UIColor* RGB(UInt8 red, UInt8 green, UInt8 blue) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

UIColor* RGBA(UInt8 red, UInt8 green, UInt8 blue, CGFloat alpha) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}
UIColor* HSB(UInt8 hue, UInt8 sat, UInt8 bri) {
    return [UIColor colorWithHue:hue/255.0 saturation:sat/255.0 brightness:bri/255.0 alpha:1.0];
}
UIColor* HSBA(UInt8 hue, UInt8 sat, UInt8 bri, CGFloat alpha) {
    return [UIColor colorWithHue:hue/255.0 saturation:sat/255.0 brightness:bri/255.0 alpha:alpha];
}

@implementation UIColor (Instance)

+ (instancetype)RGBA:(unsigned long)rgba {
    unsigned int red = (rgba >> 24) & 0xFF;
    unsigned int green = (rgba >> 16) & 0xFF;
    unsigned int blue = (rgba >> 8) & 0xFF;
    unsigned int alpha = (rgba >> 0) & 0xFF;
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}
+ (instancetype)RGB:(unsigned long)rgb {
    unsigned int red = (rgb >> 16) & 0xFF;
    unsigned int green = (rgb >> 8) & 0xFF;
    unsigned int blue = (rgb >> 0) & 0xFF;
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

@end
