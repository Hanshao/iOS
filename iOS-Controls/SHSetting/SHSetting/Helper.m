//
//  Helper.m
//  SHSetting
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "Helper.h"


UIColor *RGB(UInt8 red, UInt8 green, UInt8 blue) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

UIColor *RGBA(UInt8 red, UInt8 green, UInt8 blue, CGFloat alpha) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

UIImage *imageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}