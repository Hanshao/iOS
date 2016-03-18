//
//  HSCircleView.m
//  Controls
//
//  Created by Shaojun Han on 3/17/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSCircleView.h"

@interface HSCircleView ()
@property (strong, nonatomic) NSMutableArray *layers;
@property (assign, nonatomic) CGFloat sliceWeight;
@property (assign, nonatomic) NSInteger sliceNumber;
@end

@implementation HSCircleView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    self.layers = [NSMutableArray array];
    self.sliceWeight = 16.0;
    self.sliceNumber = 8;
}
- (void)layoutSubviews {
    if (self.layers.count < 1) return;
    [self layoutWithAnimatable:NO];
}
- (void)layoutWithAnimatable:(BOOL)animatable {
    CGSize size = self.bounds.size;
    CGFloat weight = size.width, height = size.height;
    if (weight > height) weight = height;
    if (height > weight) height = weight;
    
    NSArray *layers = self.layers;
    NSInteger sliceNumber = layers.count;
    CGFloat blankAngle = (M_PI * 8.0)/180, itAngle = - M_PI_2 + blankAngle/2.0;
    CGFloat cellAngle = (M_PI * 2.0)/sliceNumber - blankAngle;
    CGPoint center = CGPointMake(size.width/2.0, size.height/2.0);
    CGRect frame = CGRectMake((size.width - weight)/2.0, (size.height - height)/2.0, weight, height);
    for (int i = 0; i < sliceNumber; ++ i, itAngle += (cellAngle + blankAngle)) {
        CAShapeLayer *shapeLayer = [layers objectAtIndex:i];
        shapeLayer.frame = frame; shapeLayer.lineWidth = 24.0;
        shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:height/2.0 - 24.0 startAngle:itAngle endAngle:itAngle + cellAngle clockwise:YES];
        shapeLayer.path = bezierPath.CGPath;
        
        if (animatable && shapeLayer.path) {
        } else {
        }
    }
}
- (void)setSliceWeight:(CGFloat)sliceWeight {
    if (_sliceWeight == sliceWeight) return;
    _sliceWeight = sliceWeight;
    for (CAShapeLayer *shapeLayer in self.layers) {
        shapeLayer.lineWidth = sliceWeight;
    }
}
- (void)setSliceNumber:(NSInteger)sliceNumber {
    if (_sliceNumber == sliceNumber) return;
    
    NSMutableArray *layers = self.layers;
    for (int i = (int)layers.count - 1; i >= sliceNumber; -- i) {
        CAShapeLayer *layer = [layers objectAtIndex:i];
        [layers removeObjectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    for (int i = (int)layers.count; i < sliceNumber; ++ i) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = nil;
        [layers addObject:layer];
        [self.layer addSublayer:layer];
    }
    [self layoutWithAnimatable:NO];
}

- (void)animatedToSliceColor:(UIColor *)sliceColor slice:(NSInteger)slice {
    if (slice < 0 || slice >= self.layers.count) return;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.8];
    CAShapeLayer *shapeLayer = [self.layers objectAtIndex:slice];
    shapeLayer.strokeColor = sliceColor.CGColor;
    [CATransaction commit];
}
- (void)animatedToSliceWeight:(CGFloat)weight {
    if (_sliceWeight == weight) return;
    _sliceWeight = weight;

    for (CAShapeLayer *shapeLayer in self.layers) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.8];
        shapeLayer.lineWidth = weight;
        [CATransaction commit];
    }
}
- (void)animatedToSliceNumber:(NSInteger)sliceNumber {
    if (_sliceNumber == sliceNumber) return;
    _sliceNumber = sliceNumber;
    
    NSMutableArray *layers = self.layers;
    NSMutableArray *removelayers = [NSMutableArray array];
    for (int i = (int)layers.count - 1; i >= sliceNumber; -- i) {
        CAShapeLayer *layer = [layers objectAtIndex:i];
        [layers removeObjectAtIndex:i];
        [removelayers addObject:layer];
    }
    // 移除动画, 使用隐式动画和隐式动画的完成块
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.8];
    [CATransaction setCompletionBlock:^{
        for (CAShapeLayer *layer in removelayers) {
            [layer removeFromSuperlayer];
        }
        for (int i = (int)layers.count; i < sliceNumber; ++ i) {
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            layer.fillColor = nil;
            [layers addObject:layer];
            [self.layer addSublayer:layer];
        }
        [self layoutWithAnimatable:YES];
    }];
    for (CAShapeLayer *layer in removelayers) {
        layer.strokeColor = [UIColor clearColor].CGColor;
    }
    [CATransaction commit];
}
- (void)animatedWithType:(CircleAnimationType)animationType {
    switch (animationType) {
        case CircleAnimationSplitType: {
            NSArray *layers = self.layers;
            NSTimeInterval itInterval = 0.0;
            NSInteger sliceNumber = layers.count;
            for (int i = 0; i < sliceNumber; ++ i) {
                CAShapeLayer *shapeLayer = [layers objectAtIndex:i];
                CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                keyAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 0.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)]];
                NSTimeInterval timeInterval = 0.04 * (sliceNumber - i) + 0.4;
                keyAnimation.duration = timeInterval;
                keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                keyAnimation.beginTime = CACurrentMediaTime() + itInterval;
                [shapeLayer addAnimation:keyAnimation forKey:nil];
                itInterval += 0.20;
            }
        } break;
        case CircleAnimationRotateType: {
            for (CAShapeLayer *shapeLayer in self.layers) {
                CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                keyAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI + M_PI_2, 0, 0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI + M_PI, 0, 0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/6.0, 0, 0.0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(- M_PI/12.0, 0, 0, 1.0)],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1.0)]];
                keyAnimation.duration = 0.8;
                [shapeLayer addAnimation:keyAnimation forKey:nil];
            }
        } break;
        default: break;
    }
}

@end
