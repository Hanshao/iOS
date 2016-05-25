//
//  UIImage+Helper.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIImage+Helper.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (Album)
@end

@implementation ALAssetsLibrary (Album)
// 保存图片
- (void)writeImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler {
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            if (completionHandler) completionHandler(image, error);
        } else {
            [self addAssetURL:assetURL toAlbum:album completionHandler:^(NSError *error) {
                if (completionHandler) completionHandler(image, error);
            }];
        }
    }];
}
- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)album completionHandler:(ALAssetsLibraryAccessFailureBlock)completionHandler {
    void (^assetForURLBlock)(NSURL *, ALAssetsGroup *) = ^(NSURL *URL, ALAssetsGroup *group) {
        [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [group addAsset:asset];
            completionHandler(nil);
        } failureBlock:^(NSError *error) { completionHandler(error); }];
    };
    __block ALAssetsGroup *mygroup;
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([album isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]) {
            mygroup = group;
        }
        if (group) return ; // 循环结束
        
        if (mygroup) {
            assetForURLBlock(assetURL, mygroup);
        } else {
            [self addAssetsGroupAlbumWithName:album resultBlock:^(ALAssetsGroup *group) {
                assetForURLBlock(assetURL, group);
            } failureBlock:completionHandler];
        }
        
    } failureBlock:completionHandler];
}
@end

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

@implementation UIImage (Instance)

// 通过给定颜色和大小生成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
    //填充颜色为蓝色
    CGContextSetFillColorWithColor(context, color.CGColor);
    //在context上绘制
    CGContextFillPath(context);
    //把当前context的内容输出成一个UIImage图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //上下文栈pop出创建的context
    UIGraphicsEndImageContext();
    return image;
}
// 从View中生成图片
+ (UIImage *)shotImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //把当前的整个画面导入到context中，然后通过context输出UIImage，这样就可以把整个屏幕转化为图片
    [view.layer renderInContext:context];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
// 屏幕截图
+ (UIImage *)shotImage {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window respondsToSelector:@selector(screen)] && window.screen == [UIScreen mainScreen])
            continue;
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, - window.bounds.size.width * window.layer.anchorPoint.x, - window.bounds.size.height * window.layer.anchorPoint.y);
        [window.layer renderInContext:context];
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 文字转成图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size title:(NSString *)title titleColor:(UIColor *)titleColor {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, size.width, size.height);
    label.backgroundColor = color;
    label.text = title; label.textColor = titleColor;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 文字转换成图片
    [label.layer renderInContext:context];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIImage (Album)
// 保存图片到指定相册
- (void)saveToAlbum:(NSString *)album completion:(void (^)(UIImage *image, NSError *error))completion {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeImage:self toAlbum:album completionHandler:completion];
}
@end
