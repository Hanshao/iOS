//
//  UIView+Extension.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (ShotImage)

- (UIImage *)shotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO,   0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //把当前的整个画面导入到context中，然后通过context输出UIImage，这样就可以把整个屏幕转化为图片
    [self.layer renderInContext:context];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
