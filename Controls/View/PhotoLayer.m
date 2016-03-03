//
//  PhotoLayer.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/20/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "PhotoLayer.h"

//#define BoundWidth 200
//#define BoundHeight 200

/**
 * 225 * 225的框
 * 半透明背景
 * 扫描横线
 */

@interface PhotoLayer ()

@property (assign, nonatomic) CGRect clearRectangle;
@property (assign, nonatomic) CGRect lineRectangle;
@property (assign, nonatomic) CGRect boundRectangle;

@property (strong, nonatomic) UIImageView   *boundImageView;
@property (strong, nonatomic) UIImageView   *lineImageView;

@end

@implementation PhotoLayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (void)setBoundImage:(UIImage *)boundImage {
    if (_boundImage == boundImage) return;
    _boundImage = boundImage;
    self.boundImageView.image = boundImage;
    [self.boundImageView sizeToFit];
    CGSize size = self.bounds.size, ssize = self.boundImageView.bounds.size;
    self.clearRectangle = CGRectMake((size.width - ssize.width)/2, (size.height - ssize.height)/2, ssize.width, ssize.height);
}
- (void)setLineImage:(UIImage *)lineImage {
    if (_lineImage == lineImage) return;
    _lineImage = lineImage;
    self.lineImageView.image = lineImage;
    [self.lineImageView sizeToFit];
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size, ssize = self.boundImageView.bounds.size;
    self.boundImageView.center = CGPointMake(size.width/2, size.height/2);
    self.lineImageView.center = CGPointMake(ssize.width/2, 1.0);
    self.clearRectangle = CGRectMake((size.width - ssize.width)/2, (size.height - ssize.height)/2, ssize.width, ssize.height);
}

/**
 * 初始化
 */
- (void)commonInit {
    self.boundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.boundImageView.layer.masksToBounds = YES;
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.boundImageView addSubview:self.lineImageView];
    [self addSubview:self.boundImageView];
    self.backgroundColor = [UIColor clearColor];
}

/**
 * 获取透明区域
 */
- (CGRect)clearRectangle {
    return _clearRectangle;
}

#pragma mark
#pragma mark 动画控制
- (void)startAnimations {
    CGFloat height = self.boundImageView.bounds.size.height;
    // y坐标偏移量
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y" ];
    // y坐标偏移
    lineAnimation.toValue = [NSNumber numberWithFloat:height];
    lineAnimation.duration = 2.5; // 持续时间2.5
    // 无限重复动画过程
    lineAnimation.repeatCount = MAXFLOAT;
    [self.lineImageView.layer addAnimation:lineAnimation forKey:nil];
}
- (void)stopAnimations {
    [self.lineImageView.layer removeAllAnimations];
}

/**
 * 重写绘制方法
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //整个二维码扫描界面的颜色
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGRect screenRectangle = CGRectMake(0, 0, width, height);
    //中间清空的矩形框
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self addScreenFillRectangle:context rect:screenRectangle];
    [self addCenterClearRectangle:context rect:self.clearRectangle];
}

- (void)addScreenFillRectangle:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40 / 255.0, 40 / 255.0, 40 / 255.0, 0.6);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRectangle:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

@end
