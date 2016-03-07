//
//  UIImage+Extension.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Compression)

- (UIImage *)imageCompressToWeight:(CGFloat)toWeight {
    CGFloat weight = self.size.width, height = self.size.height;
    long targetWeight = toWeight;
    long targetHeight = (toWeight / weight) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWeight, targetHeight));
    [self drawInRect:CGRectMake(0, 0, targetWeight, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)imageCompressToHeight:(CGFloat)toHeight {
    CGFloat weight = self.size.width, height = self.size.height;
    long targetHeight = toHeight;
    long targetWeight = (toHeight / height) * weight;
    UIGraphicsBeginImageContext(CGSizeMake(targetWeight, targetHeight));
    [self drawInRect:CGRectMake(0, 0, targetWeight, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
