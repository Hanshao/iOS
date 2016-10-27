//
//  HSCircleView.m
//  Controls
//
//  Created by Shaojun Han on 3/17/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSCircleView.h"

@interface HSCircleLayer : CAShapeLayer
@property (assign, nonatomic) CGFloat startAngle;
@property (assign, nonatomic) CGFloat endAngle;

- (void)applyAngleAnimationWithKey:(NSString *)key fromAngle:(id)fromAngle toAngle:(id)toAngle delegate:(id)delegate;
- (void)applyAnglePathWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle;
@end

@implementation HSCircleLayer
- (instancetype)initWithLayer:(id)layer {
    if (!(self = [super initWithLayer:layer]) || ![layer isKindOfClass:HSCircleLayer.class])
        return self;
    self.startAngle = [(HSCircleLayer *)layer startAngle];
    self.endAngle = [(HSCircleLayer *)layer endAngle];
    return self;
}
+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"])
        return YES;
    return [super needsDisplayForKey:key];
}
- (void)applyAngleAnimationWithKey:(NSString *)key fromAngle:(id)fromAngle toAngle:(id)toAngle delegate:(id)delegate {
    CABasicAnimation *angleAnimation = [CABasicAnimation animationWithKeyPath:key];
    NSNumber *curAngle = [[self presentationLayer] valueForKey:key];
    if (!curAngle) curAngle = fromAngle;
    [angleAnimation setFromValue:curAngle];
    [angleAnimation setToValue:toAngle];
    [angleAnimation setDelegate:delegate];
    [angleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self addAnimation:angleAnimation forKey:key];
    [self setValue:toAngle forKey:key];
}
- (void)applyAnglePathWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius
                                                          startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.path = bezierPath.CGPath;
}
@end

// angle extension
@interface HSCircleView ()
@property (assign, nonatomic) CGFloat startAngle;
@property (strong, nonatomic) CALayer *parentLayer;
@end

// slice extension
@interface HSCircleView ()
@property (strong, nonatomic) NSMutableArray *sliceLayers;
@property (assign, nonatomic) CGFloat sliceWeight;
@property (assign, nonatomic) NSInteger sliceNumber;
@end

// animation extension
@interface HSCircleView ()
@property (assign, nonatomic) dispatch_once_t animsToken;
@property (strong, nonatomic) NSMutableArray *animsArray;
@property (strong, nonatomic) NSTimer *animsTimer;
@end

// animation extension
@interface HSCircleView ()
//@property (assign, nonatomic) dispatch_once_t layoutAnimsToken;
//@property (strong, nonatomic) NSTimer *layoutAnimsTimer;
//@property (strong, nonatomic) NSTimer *layoutTimer;
@end

@implementation HSCircleView


#pragma mark
#pragma mark 初始化
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
    CALayer *parentLayer = [[CALayer alloc] init];
    [self.layer addSublayer:parentLayer];
    self.parentLayer = parentLayer;
    parentLayer.backgroundColor = [UIColor purpleColor].CGColor;
    
    self.sliceLayers = [NSMutableArray array];
    self.animsArray = [NSMutableArray array];
    self.startAngle = - M_PI_2;
    self.sliceWeight = 16.0;
    self.sliceNumber = 8;
}

#pragma mark
#pragma mark 布局
- (void)layoutSubviews {    
    // 父layer布局
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGSize size = self.bounds.size;
    CGFloat weight = size.width, height = size.height;
    if (weight > height) weight = height; if (height > weight) height = weight;
    CGFloat x = (size.width - weight)/2.0, y = (size.height - height)/2.0;
    self.parentLayer.frame = CGRectMake(x, y, weight, height);
    
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
    // 子layer布局
    if (self.animsToken) return;
    if (self.sliceLayers.count < 1) return;
    [self layoutWithAnimatable:NO];
}
- (void)layoutWithAnimatable:(BOOL)animatable {
    CGSize size = self.parentLayer.bounds.size;
    CGFloat weight = size.width, height = size.height;
    
    NSArray *layers = self.sliceLayers;
    NSInteger sliceNumber = layers.count;
    CGFloat blankAngle = (M_PI * 8.0)/180, sliceWeight = self.sliceWeight;
    CGFloat itAngle = self.startAngle + blankAngle/2.0;
    CGFloat cellAngle = (M_PI * 2.0)/sliceNumber - blankAngle;
    
    if (!animatable) {
        CGPoint center = CGPointMake(size.width/2.0, size.height/2.0);
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        for (int i = 0; i < sliceNumber; ++ i, itAngle += (cellAngle + blankAngle)) {
            HSCircleLayer *shapeLayer = [layers objectAtIndex:i];
            
            shapeLayer.frame = CGRectMake(0, 0, weight, height);
            shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
            shapeLayer.lineWidth = sliceWeight;
            
            shapeLayer.startAngle = itAngle, shapeLayer.endAngle = itAngle + cellAngle;
            [shapeLayer applyAnglePathWithCenter:center radius:height/2.0 - sliceWeight/2.0
                                      startAngle:itAngle endAngle:itAngle + cellAngle];
        }
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.8];
        for (int i = 0; i < sliceNumber; ++ i, itAngle += (cellAngle + blankAngle)) {
            HSCircleLayer *shapeLayer = [layers objectAtIndex:i];
            
            shapeLayer.frame = CGRectMake(0, 0, weight, height);
            shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
            shapeLayer.lineWidth = sliceWeight;
            
            NSNumber *startAngle = [shapeLayer valueForKey:@"startAngle"];
            NSNumber *endAngle = [shapeLayer valueForKey:@"endAngle"];
            [shapeLayer applyAngleAnimationWithKey:@"startAngle" fromAngle:startAngle
                                           toAngle:@(itAngle) delegate:self];
            [shapeLayer applyAngleAnimationWithKey:@"endAngle" fromAngle:endAngle
                                           toAngle:@(itAngle + cellAngle) delegate:self];
        }
        [CATransaction commit];
    }
}

#pragma mark
#pragma mark 圆环动画(属性sliceNumber的辅助动画)
- (void)animsHandle:(NSTimer *)timer {
    CGFloat sliceWeight = self.sliceWeight;
    CGSize size = self.parentLayer.bounds.size;
    CGFloat weight = size.width, height = size.height;
    CGPoint center = CGPointMake(weight/2.0, height/2.0);

    [self.sliceLayers enumerateObjectsUsingBlock:^(HSCircleLayer *obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *presentLayer = [obj presentationLayer];
        CGFloat startAngle = [[presentLayer valueForKey:@"startAngle"] doubleValue];
        CGFloat endAngle = [[presentLayer valueForKey:@"endAngle"] doubleValue];
        [obj applyAnglePathWithCenter:center radius:height/2.0 - sliceWeight/2.0 startAngle:startAngle endAngle:endAngle];
    }];
}
- (void)animationDidStart:(CAAnimation *)animation {
    if (!self.animsTimer) {
        static NSTimeInterval interval = 1.0/60.0;
        self.animsTimer = [NSTimer timerWithTimeInterval:interval target:self
                                                selector:@selector(animsHandle:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.animsTimer forMode:NSDefaultRunLoopMode];
    }
    [self.animsArray addObject:animation];
}
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    [self.animsArray removeObject:animation];
    if (self.animsArray.count) return;
    
    [self.animsTimer invalidate];
    self.animsTimer = nil;
    self.animsToken = NO;
}

#pragma mark
#pragma mark 属性配置
- (void)setSliceWeight:(CGFloat)sliceWeight {
    if (_sliceWeight == sliceWeight) return;
    _sliceWeight = sliceWeight;
    for (CAShapeLayer *shapeLayer in self.sliceLayers) {
        shapeLayer.lineWidth = sliceWeight;
    }
}
- (void)setSliceNumber:(NSInteger)sliceNumber {
    if (_sliceNumber == sliceNumber) return;
    
    CALayer *parentLayer = self.parentLayer;
    NSMutableArray *layers = self.sliceLayers;
    for (int i = (int)layers.count - 1; i >= sliceNumber; -- i) {
        CAShapeLayer *layer = [layers objectAtIndex:i];
        [layers removeObjectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    
    for (int i = (int)layers.count; i < sliceNumber; ++ i) {
        HSCircleLayer *layer = [[HSCircleLayer alloc] init];
        layer.fillColor = nil;
        [layers addObject:layer];
        [parentLayer addSublayer:layer];
    }
    [self layoutWithAnimatable:NO];
}

- (void)animatedToSliceColor:(UIColor *)sliceColor slice:(NSInteger)slice {
    if (slice < 0 || slice >= self.sliceLayers.count) return;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.8];
    CAShapeLayer *shapeLayer = [self.sliceLayers objectAtIndex:slice];
    shapeLayer.strokeColor = sliceColor.CGColor;
    [CATransaction commit];
}

#pragma mark
#pragma mark 自定义属性动画
- (void)animatedToSliceWeight:(CGFloat)weight {
    if (_sliceWeight == weight) return;
    _sliceWeight = weight;

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.8];
    for (CAShapeLayer *shapeLayer in self.sliceLayers) {
        shapeLayer.lineWidth = weight;
    }
    [CATransaction commit];
}
- (void)animatedToSliceNumber:(NSInteger)sliceNumber {
    if (_sliceNumber == sliceNumber) return;
    _sliceNumber = sliceNumber;
    
    CALayer *parentLayer = self.parentLayer;
    NSMutableArray *layers = self.sliceLayers;
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
        self.animsToken = YES;
        for (CAShapeLayer *layer in removelayers)
            [layer removeFromSuperlayer];
        
        for (int i = (int)layers.count; i < sliceNumber; ++ i) {
            HSCircleLayer *layer = [[HSCircleLayer alloc] init];
            [parentLayer addSublayer:layer];
            [layers addObject:layer];
            layer.fillColor = nil;
        }
        [self layoutWithAnimatable:YES];
    }];
    for (CAShapeLayer *layer in removelayers) {
        layer.strokeColor = [UIColor clearColor].CGColor;
    }
    [CATransaction commit];
}

#pragma mark
#pragma mark 自定义动画
- (void)animatedWithType:(CircleAnimationType)animationType {
    switch (animationType) {
        case CircleAnimationSplitType: {
            NSArray *layers = self.sliceLayers;
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
            for (CAShapeLayer *shapeLayer in self.sliceLayers) {
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
        case CircleAnimationUnfoldType: {
            for (CAShapeLayer *shapeLayer in self.sliceLayers) {
                CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                basicAnimation.duration = 1.2;
                basicAnimation.toValue = @(1.0);
                basicAnimation.fromValue = @(0.0);
                [shapeLayer addAnimation:basicAnimation forKey:nil];
            }
        } break;
        default: break;
    }
}

@end
