//
//  HSFlatButton.m
//  Controls
//
//  Created by Shaojun Han on 3/12/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSFlatButton.h"

//////////////////////////////////////////////////
//////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, FlatLayerType) {
    FlatLayerHorizontalType = 1,
    FlatLayerVerticalType = 2,
    FlatLayerLeftSlashType = 3,
    FlatLayerRightSlashType = 4
};

@interface HSFlatLayer : CALayer
@property (assign, nonatomic) FlatLayerType layerType;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (assign, nonatomic, setter=setWeight:) CGFloat lineWeight;
@property (assign, nonatomic, setter=setRadius:) CGFloat lineRadius;
@property (strong, nonatomic, setter=setColor:) UIColor *lineColor;

- (void)animatedToType:(FlatLayerType)layerType;
@end

@implementation HSFlatLayer

- (instancetype)init {
    if (!(self = [super init])) return self;
    [self initialize];
    return self;
}
- (void)initialize {
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [self addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}
- (void)layoutSublayers {
    self.shapeLayer.frame = self.bounds;
    CGFloat weight = self.bounds.size.width;
    CGFloat height = self.lineWeight;
    CGFloat radius = self.lineRadius;
    CGRect frame = CGRectMake(0, 0, weight, height);
    
    self.shapeLayer.bounds = frame;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius];
    self.shapeLayer.path = bezierPath.CGPath;
    NSLog(@"%s", __FUNCTION__);
}
// animate to type
- (void)animatedToType:(FlatLayerType)layerType {
    if (_layerType == layerType) return;
    _layerType = layerType;
    
    CATransform3D transform = CATransform3DIdentity;
    switch (layerType) {
        case FlatLayerHorizontalType: {
            transform = CATransform3DIdentity;
        } break;
        case FlatLayerVerticalType: {
            transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
        } break;
        case FlatLayerLeftSlashType: {
            transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1.0);
        } break;
        case FlatLayerRightSlashType: {
            transform = CATransform3DMakeRotation(- M_PI_4, 0, 0, 1.0);
        } break;
    }
    self.shapeLayer.transform = transform;
}
- (void)setWeight:(CGFloat)lineWeight {
    if (_lineWeight == lineWeight) return;
    _lineWeight = lineWeight;
    
    CGFloat radius = self.lineRadius;
    CGFloat weight = self.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, weight, lineWeight);
    
    self.shapeLayer.bounds = frame;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius];
    self.shapeLayer.path = bezierPath.CGPath;
}
- (void)setRadius:(CGFloat)lineRadius {
    if (_lineRadius == lineRadius) return;
    _lineRadius = lineRadius;
    
    CGFloat lineWeight = self.lineWeight;
    CGFloat weight = self.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, weight, lineWeight);
    
    self.shapeLayer.bounds = frame;
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:lineRadius];
    self.shapeLayer.path = bezierPath.CGPath;
}
- (void)setColor:(UIColor *)lineColor {
    self.shapeLayer.fillColor = lineColor.CGColor;
}
@end

//////////////////////////////////////////////////
@interface HSFlatButton ()
@property (assign, nonatomic) FlatButtonType buttonType;
@property (strong, nonatomic) HSFlatLayer *firstLayer;
@property (strong, nonatomic) HSFlatLayer *secondLayer;
@property (strong, nonatomic) HSFlatLayer *lastLayer;
@end

@interface HSFlatButton ()
@property (assign, nonatomic) CGFloat lineWeight;
@property (assign, nonatomic) CGFloat lineRadius;
@property (strong, nonatomic) UIColor *lineColor;
@end

@implementation HSFlatButton

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return self;
    [self initialize];
    return self;
}

- (void)initialize {
    HSFlatLayer *firstLayer = [[HSFlatLayer alloc] init];
    [self.layer addSublayer:firstLayer];
    self.firstLayer = firstLayer;
    
    HSFlatLayer *secondLayer = [[HSFlatLayer alloc] init];
    [self.layer addSublayer:secondLayer];
    self.secondLayer = secondLayer;
    
    HSFlatLayer *lastLayer = [[HSFlatLayer alloc] init];
    [self.layer addSublayer:lastLayer];
    self.lastLayer = lastLayer;
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    CGFloat weight = size.width, height = size.height;
    if (weight < height) height = weight;
    if (height < weight) weight = height;
    
    CGFloat x = (size.width - weight)/2.0, y = (size.height - height)/2.0;
    CGRect frame = CGRectMake(x, y, weight, height);
    self.firstLayer.frame = frame;
    self.secondLayer.frame = frame;
    self.lastLayer.frame = frame;
    NSLog(@"%s", __FUNCTION__);
}

// type change with animation.
- (void)animatedToType:(FlatButtonType)buttonType {
    if (_buttonType == buttonType) return;
    _buttonType = buttonType;
    [self transitionToType:buttonType];
}

- (void)transitionToType:(FlatButtonType)buttonType {
    switch (buttonType) {
        case FlatButtonOneType: {
            [self.firstLayer animatedToType:FlatLayerVerticalType];
            [self.secondLayer animatedToType:FlatLayerVerticalType];
            [self.lastLayer animatedToType:FlatLayerVerticalType];
        } break;
        case FlatButtonHamburgerType: {
            [self.firstLayer animatedToType:FlatLayerHorizontalType];
            [self.secondLayer animatedToType:FlatLayerHorizontalType];
            [self.lastLayer animatedToType:FlatLayerHorizontalType];
        } break;
        case FlatButtonMinusType: {
            [self.firstLayer animatedToType:FlatLayerHorizontalType];
            [self.secondLayer animatedToType:FlatLayerHorizontalType];
            [self.lastLayer animatedToType:FlatLayerHorizontalType];
        } break;
        case FlatButtonAddType: {
            [self.firstLayer animatedToType:FlatLayerHorizontalType];
            [self.secondLayer animatedToType:FlatLayerVerticalType];
            [self.lastLayer animatedToType:FlatLayerHorizontalType];
        } break;
        case FlatButtonCloseType: {
            [self.firstLayer animatedToType:FlatLayerLeftSlashType];
            [self.secondLayer animatedToType:FlatLayerRightSlashType];
            [self.lastLayer animatedToType:FlatLayerLeftSlashType];
        } break;
        case FlatButtonBackwardType: {
            [self.firstLayer animatedToType:FlatLayerLeftSlashType];
            [self.secondLayer animatedToType:FlatLayerRightSlashType];
            [self.lastLayer animatedToType:FlatLayerLeftSlashType];
        } break;
        case FlatButtonForwardType: {
            [self.firstLayer animatedToType:FlatLayerRightSlashType];
            [self.secondLayer animatedToType:FlatLayerLeftSlashType];
            [self.lastLayer animatedToType:FlatLayerRightSlashType];
        } break;
        case FlatButtonDownwardType: {
            [self.firstLayer animatedToType:FlatLayerRightSlashType];
            [self.secondLayer animatedToType:FlatLayerLeftSlashType];
            [self.lastLayer animatedToType:FlatLayerRightSlashType];
        } break;
        case FlatButtonUpwardType: {
            [self.firstLayer animatedToType:FlatLayerLeftSlashType];
            [self.secondLayer animatedToType:FlatLayerRightSlashType];
            [self.lastLayer animatedToType:FlatLayerLeftSlashType];
        } break;
        default: break;
    }
}

// attribute for button
- (void)setWeight:(CGFloat)weight {
    if (_lineWeight == weight) return;
    _lineWeight = weight;
    
    self.firstLayer.lineWeight = weight;
    self.secondLayer.lineWeight = weight;
    self.lastLayer.lineWeight = weight;
}
- (void)setRadius:(CGFloat)radius {
    if (_lineRadius == radius) return;
    _lineRadius = radius;
    
    self.firstLayer.lineRadius = radius;
    self.secondLayer.lineRadius = radius;
    self.lastLayer.lineRadius = radius;
}
- (void)setColor:(UIColor *)color {
    if (_lineColor == color) return;
    _lineColor = color;
    
    self.firstLayer.lineColor = color;
    self.secondLayer.lineColor = color;
    self.lastLayer.lineColor = color;
}

@end
