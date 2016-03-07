//
//  UIImage+Extension.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 拓展(UIImage)
 * 1. 等比例压缩
 */
@interface UIImage (Compression)

- (UIImage *)imageCompressToWeight:(CGFloat)toWeight;
- (UIImage *)imageCompressToHeight:(CGFloat)toHeight;

@end
