//
//  UIImage+Helper.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 拓展(UIImage)
 * 1. 等比例压缩
 * 2. 实例化
 * 3. 图片保存到相册
 */
@interface UIImage (Compression)
- (UIImage *)imageCompressToWeight:(CGFloat)toWeight;
- (UIImage *)imageCompressToHeight:(CGFloat)toHeight;
@end

@interface UIImage (Instance)
// 通过给定颜色和大小生成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
// 文字转成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size title:(NSString *)title titleColor:(UIColor *)titleColor;
// 从View中生成图片
+ (UIImage *)shotImage:(UIView *)view;
// 屏幕截图
+ (UIImage *)shotImage;
@end

@interface UIImage (Album)
// 保存图片到指定相册
- (void)saveToAlbum:(NSString *)album completion:(void (^)(UIImage *image, NSError *error))completion;
@end