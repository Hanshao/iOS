//
//  HomeScrollCell.h
//  Yofoto
//
//  Created by Shaojun Han on 8/17/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Slide show circularly with some images.
 */
@class SlideShowView;

@protocol SlideShowViewDelegate <NSObject>
@required
- (NSInteger)numberOfSlides;
- (UIImage *)slideShowView:(SlideShowView *)slideShowView imageOfSlide:(NSInteger)slide;

@optional
- (UIImageView *)slideShowView:(SlideShowView *)slideShowView
              imageViewOfSlide:(NSInteger)slide reuseImageView:(UIImageView *)imageView;
- (void)slideShowView:(SlideShowView *)slideShowView didSelectedSlide:(NSInteger)slide;

@end


@interface SlideShowView: UIView

@property (assign, nonatomic) CGFloat                   autoSlideTimeInterval;      // 定时器时间间隔
@property (assign, nonatomic) UIViewContentMode         cotentDisplayMode;          // 图片显示模式
@property (weak, nonatomic) id<SlideShowViewDelegate>   delegate;

- (void)fire;           // 启动定时
- (void)pause;          // 暂停计时器
- (void)stop;           // 停止计时器

- (void)reloadAllSlides;     // 重新加载数据

@end
