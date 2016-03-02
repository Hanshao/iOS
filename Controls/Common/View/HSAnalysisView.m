//
//  HSAnalysisView.m
//  Controls
//
//  Created by Shaojun Han on 2/25/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSAnalysisView.h"
#import <objc/message.h>

#define HSSendMessage(...) ((void (*)(void *, SEL, id))objc_msgSend)(__VA_ARGS__)

// region for graphic
@interface HSAnalysisView ()

@property (assign, nonatomic) CGRect graphicRectangle;  // graphic region

@end

// layer for display
@interface HSAnalysisView ()

@property (assign, nonatomic) NSInteger yGraphicNumber; // vertical axis line number
@property (assign, nonatomic) CGFloat   yGraphicHeight; // vertical axis height
@property (strong, nonatomic) UIView    *yGraphiclines; // vertical axis lines
@property (strong, nonatomic) UIView    *yGraphicAxis;  // vertical axis

@property (strong, nonatomic) UIScrollView  *graphicScrollView; // graphic scroll view
@property (assign, nonatomic) NSInteger     xGraphicNumber;     // horizontal axis line number
@property (assign, nonatomic) CGFloat       xGraphicWeight;     // horizontal axis width
@property (strong, nonatomic) UIView        *xGraphiclines;     // horizontal axis lines
@property (strong, nonatomic) UIView        *xGraphicAxis;      // horizontal axis

@property (strong, nonatomic) UIView        *sGraphicline;      // soomth curve
@property (strong, nonatomic) UIView        *sGraphicBar;       // bar

@end

// refresh to load more data
@interface HSAnalysisView ()
<
    UIScrollViewDelegate
>
@property (assign, nonatomic) BOOL          refreshingEnable;
@property (strong, nonatomic) UIView        *refreshingView;
@property (strong, nonatomic) UIImageView   *refreshingImageView;

@property (weak, nonatomic) id              refreshingTarget;
@property (assign, nonatomic) SEL           refreshingAction;
@property (copy, nonatomic) HSAnalysisRefreshingBlock refreshingBlock;

@end

@interface HSAnalysisView ()

@property (assign, nonatomic) BOOL          scaleEnable;

@end

// long press
@interface HSAnalysisView ()

@property (assign, nonatomic) CGFloat dotXPoint;
@property (assign, nonatomic) CGFloat dotWeight;
@property (strong, nonatomic) UIColor *dotColor;
@property (strong, nonatomic) UIView  *dotline;

@end

@implementation HSAnalysisView


#pragma mark
#pragma mark Init
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return self;
    [self initialize];
    return self;
}
- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    self.yGraphiclines.frame = CGRectMake(0, 0, size.width, size.height);
    self.yGraphicAxis.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.graphicScrollView.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.refreshingView.frame = CGRectMake(-60, 0, 60, size.height);
    self.refreshingImageView.frame = CGRectMake((60-20)/2, (size.height-60)/2, 20, 20);
    
    self.dotline.frame = CGRectMake(0, 0, size.width, size.height);
    [self layoutDotline];
    
    [self reloadData];
}
- (void)initialize {
    
    self.yGraphiclines = [UIView new];
    [self addSubview:self.yGraphiclines];
    self.yGraphiclines.backgroundColor = [UIColor clearColor];
    
    self.yGraphicAxis = [UIView new];
    [self addSubview:self.yGraphicAxis];
    self.yGraphicAxis.backgroundColor = [UIColor clearColor];
    
    self.graphicScrollView = [UIScrollView new];
    [self addSubview:self.graphicScrollView];
    self.graphicScrollView.delegate = self;
    self.graphicScrollView.alwaysBounceHorizontal = YES;
    self.graphicScrollView.backgroundColor = [UIColor clearColor];
    self.graphicScrollView.showsVerticalScrollIndicator = NO;
    self.graphicScrollView.showsHorizontalScrollIndicator = NO;
    
    self.refreshingView = [UIView new];
    [self.graphicScrollView addSubview:self.refreshingView];
    self.refreshingView.backgroundColor = [UIColor clearColor];
    
    self.refreshingImageView = [UIImageView new];
    [self.refreshingView addSubview:self.refreshingImageView];
    self.refreshingImageView.image = [UIImage imageNamed:@"circle_small"];
    
    self.xGraphiclines = [UIView new];
    [self.graphicScrollView addSubview:self.xGraphiclines];
    self.xGraphiclines.backgroundColor = [UIColor clearColor];
    
    self.xGraphicAxis = [UIView new];
    [self.graphicScrollView addSubview:self.xGraphicAxis];
    self.xGraphicAxis.backgroundColor = [UIColor clearColor];
    
    self.sGraphicBar = [UIView new];
    [self.graphicScrollView addSubview:self.sGraphicBar];
    self.sGraphicBar.backgroundColor = [UIColor clearColor];
    
    self.sGraphicline = [UIView new];
    [self.graphicScrollView addSubview:self.sGraphicline];
    self.sGraphicline.backgroundColor = [UIColor clearColor];
    
    [self dotInitialize];
    [self scaleInitialize];
}
- (void)dotInitialize {
    
    self.dotWeight = 1.2;
    self.dotColor = [UIColor clearColor];
    
    self.dotline = [[UIView alloc] init];
    self.dotline.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dotline];
    self.dotline.hidden = YES;

    CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@(2), @(2)];
    [self.dotline.layer addSublayer:shapeLayer];
    
    UILongPressGestureRecognizer *longGestureRecognizer = nil;
    longGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                             initWithTarget:self action:@selector(longGestureHandle:)];
    longGestureRecognizer.minimumPressDuration = 0.8;
    [self addGestureRecognizer:longGestureRecognizer];
}
- (void)scaleInitialize {
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = nil;
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                             initWithTarget:self action:@selector(pinchGestureHandle:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    [self setScaleEnable:YES];
}

#pragma mark
#pragma mark Refresh
- (void)setAutoRefreshing:(BOOL)enable {
    if (enable == _refreshingEnable) return;
    _refreshingEnable = enable;
}
- (void)addRefreshingBlock:(HSAnalysisRefreshingBlock)refreshingBlock {
    self.refreshingBlock = refreshingBlock;
}
- (void)addRefreshingTarget:(id)target refreshingAction:(SEL)action {
    self.refreshingTarget = target;
    self.refreshingAction = action;
}
- (void)beginRefreshing {
    self.graphicScrollView.scrollEnabled = NO;
    [self.gestureRecognizers lastObject].enabled = NO;

    [UIView animateWithDuration:0.2 animations:^{
        self.graphicScrollView.contentInset = UIEdgeInsetsMake(0, 60, 0, 0);
    } completion:^(BOOL finished) {
        [self startRefreshingAnimation];
        if (self.refreshingBlock) {
            self.refreshingBlock();
        }
        if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
            HSSendMessage((__bridge void *)(self.refreshingTarget), self.refreshingAction, self);
        }
    }];
}
- (void)endRefreshing {
    [UIView animateWithDuration:0.4 animations:^{
        self.graphicScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        [self stopRefreshingAnimation];
        self.graphicScrollView.scrollEnabled = YES;
        [self.gestureRecognizers lastObject].enabled = self.scaleEnable;
    }];
}
- (void)startRefreshingAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.cumulative = YES;
    animation.duration = 0.2;
    animation.repeatCount = MAXFLOAT;
    CATransform3D transform = CATransform3DMakeRotation(45.0 * M_PI / 180.f, 0, 0, 1.0);
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    [self.refreshingImageView.layer addAnimation:animation forKey:@""];
}
- (void)stopRefreshingAnimation {
    [self.refreshingImageView.layer removeAllAnimations];
}
#pragma mark UIScollViewDelegate
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (!self.refreshingEnable) return;
    // begin refreshing
    if (scrollView.contentOffset.x <= -60) {
        [self beginRefreshing];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.refreshingEnable) {
        self.refreshingView.alpha = 1.0;
    } else {
        self.refreshingView.alpha = 0.0;
    }
}


#pragma mark
#pragma mark Long press and dot line
// color for dot line(when long pressing)
- (void)setColorOfDotline:(UIColor *)color {
    if(color == _dotColor) return;
    _dotColor = color;
    [self layoutDotline];
}
// width for dot line
- (void)setDotlineWeight:(CGFloat)weight {
    if (weight == _dotWeight) return;
    _dotWeight = weight;
    [self layoutDotline];
}
// enable/disable long press
- (void)setDotlineEnable:(BOOL)enable {
    UIGestureRecognizer *gestureRecognizer = nil;
    gestureRecognizer = [self.gestureRecognizers firstObject];
    if (enable) {
        gestureRecognizer.enabled = YES;
    } else {
        gestureRecognizer.enabled = NO;
    }
}
- (void)longGestureHandle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan
        || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [sender locationInView:self];
        self.dotXPoint = point.x;
        [self layoutDotline];
        self.dotline.hidden = NO;
        if ([self.delegate respondsToSelector:@selector(anaysisView:touchAtXaxis:)]) {
            [self.delegate anaysisView:self touchAtXaxis:point.x];
        }
    } else {
        self.dotline.hidden = YES;
    }
}


#pragma mark
#pragma mark Scale or zoom
// scale(zoom)
- (void)setScaleEnable:(BOOL)enable {
    _scaleEnable = enable;
    [self.gestureRecognizers lastObject].enabled = enable;
}
- (void)pinchGestureHandle:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGFloat xWeight = self.graphicRectangle.size.width;
        CGFloat height = self.graphicRectangle.size.height;
        CGFloat xOffset = self.graphicScrollView.contentOffset.x;
        CGFloat weight = self.graphicScrollView.bounds.size.width;
        CGPoint anchorPoint = CGPointMake((xOffset + weight/2)/xWeight, 0.5);
        
        self.xGraphiclines.layer.anchorPoint = anchorPoint;
        self.xGraphicAxis.layer.anchorPoint = anchorPoint;
        self.sGraphicBar.layer.anchorPoint = anchorPoint;
        self.sGraphicline.layer.anchorPoint = anchorPoint;
        
        self.xGraphiclines.layer.position = CGPointMake((xOffset + weight/2), height/2.0);
        self.xGraphicAxis.layer.position = CGPointMake((xOffset + weight/2), height/2.0);
        self.sGraphicline.layer.position = CGPointMake((xOffset + weight/2), height/2.0);
        self.sGraphicBar.layer.position = CGPointMake((xOffset + weight/2), height/2.0);
    } else if(sender.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = sender.scale;
        self.xGraphiclines.transform = CGAffineTransformMakeScale(scale, 1.0);
        self.xGraphicAxis.transform = CGAffineTransformMakeScale(scale, 1.0);
        self.sGraphicBar.transform = CGAffineTransformMakeScale(scale, 1.0);
        self.sGraphicline.transform = CGAffineTransformMakeScale(scale, 1.0);
        
    } else {
        
        CGFloat weight = self.graphicRectangle.size.width;
        CGFloat height = self.graphicRectangle.size.height;
        
        self.xGraphiclines.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.xGraphicAxis.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.sGraphicBar.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.sGraphicline.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        self.xGraphiclines.layer.position = CGPointMake(weight/2.0, height/2.0);
        self.xGraphicAxis.layer.position = CGPointMake(weight/2.0, height/2.0);
        self.sGraphicline.layer.position = CGPointMake(weight/2.0, height/2.0);
        self.sGraphicBar.layer.position = CGPointMake(weight/2.0, height/2.0);
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        self.xGraphiclines.transform = CGAffineTransformIdentity;
        self.xGraphicAxis.transform = CGAffineTransformIdentity;
        self.sGraphicBar.transform = CGAffineTransformIdentity;
        self.sGraphicline.transform = CGAffineTransformIdentity;
        
        [CATransaction commit];
        
        CGFloat scale = sender.scale;
        if ([self.delegate respondsToSelector:@selector(anaysisView:didScale:)])
            [self.delegate anaysisView:self didScale:scale];
    }
}


#pragma mark
#pragma mark Reload data
// refresh
- (void)reloadData {
    // data for drawing
    self.yGraphicNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfYGraphiclinesInAnalysisView:)])
        self.yGraphicNumber = [self.dataSource numberOfYGraphiclinesInAnalysisView:self];
    
    self.xGraphicNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfXGraphiclinesInAnalysisView:)])
        self.xGraphicNumber = [self.dataSource numberOfXGraphiclinesInAnalysisView:self];
    
    self.yGraphicHeight = 0;
    if ([self.dataSource respondsToSelector:@selector(yGraphicHeightInAnalysisView:)])
        self.yGraphicHeight = [self.dataSource yGraphicHeightInAnalysisView:self];
    
    self.xGraphicWeight = 0;
    if ([self.dataSource respondsToSelector:@selector(xGraphicWeightInAnalysisView:)])
        self.xGraphicWeight = [self.dataSource xGraphicWeightInAnalysisView:self];
    
    // adjust frame of subviews
    CGFloat xWeight = self.xGraphicWeight * (self.xGraphicNumber - 1);
    if (xWeight < 0) xWeight = 0;
    CGFloat xOffset = xWeight + self.graphicScrollView.contentOffset.x;
    xOffset -= self.graphicScrollView.contentSize.width;
    if (xOffset < 0) xOffset = 0;
    
    CGSize size = self.bounds.size;
    self.graphicScrollView.contentSize = CGSizeMake(xWeight, size.height);
    self.graphicScrollView.contentOffset = CGPointMake(xOffset, 0);
    
    self.graphicRectangle = CGRectMake(0, 0, xWeight, size.height);
    self.xGraphiclines.frame = CGRectMake(0, 0, xWeight, size.height);
    self.xGraphicAxis.frame = CGRectMake(0, 0, xWeight, size.height);
    self.sGraphicline.frame = CGRectMake(0, 0, xWeight, size.height);
    self.sGraphicBar.frame = CGRectMake(0, 0, xWeight, size.height);
    
    // refresh user interface
    [self reloadYGraphiclines];
    [self reloadYGraphicAxis];
    
    [self reloadXGraphiclines];
    [self reloadXGraphicAxis];
    
    [self reloadSGraphicline];
    [self reloadSGraphicBar];
}
- (void)layoutDotline {
    
    CGSize size = self.bounds.size;
    CGFloat dotWeight = self.dotWeight;
    CGFloat dotXPoint = self.dotXPoint;

    UIColor *dotColor = self.dotColor;
    NSArray *layers = [self.dotline.layer sublayers];
    CAShapeLayer *shapeLayer = [layers firstObject];
    
    shapeLayer.frame = CGRectMake(0, 0, dotWeight, size.height);
    shapeLayer.strokeColor = dotColor.CGColor;
    shapeLayer.lineWidth = dotWeight;
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, dotXPoint, 0);
    CGPathAddLineToPoint(path, NULL, dotXPoint, size.height);
    [shapeLayer setPath:path];
    CGPathRelease(path);
}
- (void)reloadXGraphiclines {
    CGFloat xGraphicWeight = self.xGraphicWeight;
    NSInteger xGraphicNumber = self.xGraphicNumber;
    
    NSArray *layers = [self.xGraphiclines.layer sublayers];
    for (int i = (int)layers.count - 1; i >= xGraphicNumber; -- i)
        [[layers objectAtIndex:i] removeFromSuperlayer];
    
    for (int i = (int)layers.count; i < xGraphicNumber; ++ i) {
        CALayer *layer = [[CALayer alloc] init];
        [self.xGraphiclines.layer addSublayer:layer];
    }
    
    layers = [self.xGraphiclines.layer sublayers];
    if (layers.count < 1) return;
    
    UIColor *xlineColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(colorOfXGraphiclineInAnalysisView:)])
        xlineColor = [self.dataSource colorOfXGraphiclineInAnalysisView:self];
    
    CGFloat height = (self.yGraphicNumber - 1) * self.yGraphicHeight;
    CGFloat iWeight = 0.0, unitWeight = xGraphicWeight;
    for (int i = 0; i < xGraphicNumber; ++ i, iWeight += unitWeight) {
        CALayer *layer = [layers objectAtIndex:i];
        layer.frame = CGRectMake(iWeight, 0, 1.0, height);
        layer.backgroundColor = xlineColor.CGColor;
    }
}
- (void)reloadYGraphiclines {
    CGFloat yGraphicHeight = self.yGraphicHeight;
    NSInteger yGraphicNumber = self.yGraphicNumber;
    
    NSArray *layers = [self.yGraphiclines.layer sublayers];
    for (int i = (int)layers.count - 1; i >= yGraphicNumber; -- i)
        [[layers objectAtIndex:i] removeFromSuperlayer];
    
    for (int i = (int)layers.count; i < yGraphicNumber; ++ i) {
        CALayer *layer = [[CALayer alloc] init];
        [self.yGraphiclines.layer addSublayer:layer];
    }
    
    layers = [self.yGraphiclines.layer sublayers];
    if (layers.count < 1) return;
    
    UIColor *ylineColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(colorOfYGraphiclineInAnalysisView:)])
        ylineColor = [self.dataSource colorOfYGraphiclineInAnalysisView:self];
    
    CGFloat weight = self.yGraphiclines.bounds.size.width;
    CGFloat iHeight = 0.0, unitHeight = yGraphicHeight;
    for (int i = 0; i < yGraphicNumber; ++ i, iHeight += unitHeight) {
        CALayer *layer = [layers objectAtIndex:i];
        layer.frame = CGRectMake(0, iHeight, weight, 1.0);
        layer.backgroundColor = ylineColor.CGColor;
    }
}
- (void)reloadXGraphicAxis {
    CGFloat xGraphicWeight = self.xGraphicWeight;
    NSInteger xAxisNumber = self.xGraphicNumber - 1;
    
    NSArray *layers = [self.xGraphicAxis.layer sublayers];
    for (int i = (int)layers.count - 1; i >= xAxisNumber; -- i)
        [[layers objectAtIndex:i] removeFromSuperlayer];
    
    layers = [self.xGraphicAxis.layer sublayers];
    for (int i = (int)layers.count; i < xAxisNumber; ++ i) {
        CATextLayer *titlelayer = [[CATextLayer alloc] init];
        titlelayer.contentsScale = [UIScreen mainScreen].scale;
        titlelayer.alignmentMode = @"center";
        titlelayer.font = (__bridge CFTypeRef)(@"Futura-Medium");
        titlelayer.fontSize = 10.0;
        [self.xGraphicAxis.layer addSublayer:titlelayer];
    }
    
    layers = [self.xGraphicAxis.layer sublayers];
    if (layers.count < 1) return;
    
    UIColor *xGraphicAxisColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(colorOfXGraphicAxisInAnalysisView:)])
        xGraphicAxisColor = [self.dataSource colorOfXGraphicAxisInAnalysisView:self];
    
    CGFloat height = (self.yGraphicNumber - 1) * self.yGraphicHeight;
    CGFloat iWeight = 0.0, unitWeight = xGraphicWeight;
    for (int i = 0; i < xAxisNumber; ++ i, iWeight += unitWeight) {
        CATextLayer *titlelayer = [layers objectAtIndex:i];
        titlelayer.frame = CGRectMake(iWeight, height + 4.0, unitWeight, 16);
        titlelayer.foregroundColor = xGraphicAxisColor.CGColor;
        
        titlelayer.string = nil;
        if ([self.dataSource respondsToSelector:@selector(analysisView:xGraphicAxis:)])
            titlelayer.string = [self.dataSource analysisView:self xGraphicAxis:i];
    }
}
- (void)reloadYGraphicAxis {
    CGFloat yGraphicHeight = self.yGraphicHeight;
    NSInteger yAxisNumber = self.yGraphicNumber - 1;
    
    NSArray *layers = [self.yGraphicAxis.layer sublayers];
    for (int i = (int)layers.count - 1; i >= yAxisNumber; -- i)
        [[layers objectAtIndex:i] removeFromSuperview];
    
    layers = [self.yGraphicAxis.layer sublayers];
    for (int i = (int)layers.count; i < yAxisNumber; ++ i) {
        CATextLayer *titlelayer = [[CATextLayer alloc] init];
        titlelayer.contentsScale = [UIScreen mainScreen].scale;
        titlelayer.alignmentMode = @"left";
        titlelayer.font = (__bridge CFTypeRef)(@"Futura-Medium");
        titlelayer.fontSize = 11.0;
        [self.yGraphicAxis.layer addSublayer:titlelayer];
    }
    
    layers = [self.yGraphicAxis.layer sublayers];
    if (layers.count < 1) return;
    
    UIColor *yGraphicAxisColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(colorOfYGraphicAxisInAnalysisView:)])
        yGraphicAxisColor = [self.dataSource colorOfYGraphicAxisInAnalysisView:self];
    
    CGFloat iHeight = 0.0, unitHeight = yGraphicHeight;
    for (int i = 0; i < yAxisNumber; ++ i, iHeight += unitHeight) {
        CATextLayer *titlelayer = [layers objectAtIndex:i];
        titlelayer.frame = CGRectMake(15, iHeight + (unitHeight - 12)/2.0, 200, 12);
        titlelayer.foregroundColor = yGraphicAxisColor.CGColor;
        
        titlelayer.string = nil;
        if ([self.dataSource respondsToSelector:@selector(analysisView:yGraphicAxis:)])
            titlelayer.string = [self.dataSource analysisView:self yGraphicAxis:i];
    }
}
- (void)reloadSGraphicBar {
    CGFloat xGraphicWeight = self.xGraphicWeight;
    NSInteger xAxisNumber = self.xGraphicNumber - 1;
    
    NSArray *layers = [self.sGraphicBar.layer sublayers];
    for (int i = (int)layers.count - 1; i >= xAxisNumber; -- i) {
        [[layers objectAtIndex:i] removeFromSuperlayer];
    }
    
    layers = [self.sGraphicBar.layer sublayers];
    for (int i = (int)layers.count; i < xAxisNumber; ++ i) {
        CALayer *layer = [[CALayer alloc] init];
        [self.sGraphicBar.layer insertSublayer:layer atIndex:0];
    }
    
    layers = [self.sGraphicBar.layer sublayers];
    if (layers.count < 1) return;
    
    CGFloat weight = xGraphicWeight;
    if ([self.dataSource respondsToSelector:@selector(barGraphicWeightInAnalysisView:)])
        weight = [self.dataSource barGraphicWeightInAnalysisView:self];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    CGFloat iWeight = 0.0, unitWeight = xGraphicWeight;
    for (int i = 0; i < xAxisNumber; ++ i, iWeight += unitWeight) {
        CALayer *layer = [layers objectAtIndex:i];
        
        UIColor *sGraphicBarColor = [UIColor clearColor];
        if ([self.dataSource respondsToSelector:@selector(analysisView:barGraphicColor:)])
            sGraphicBarColor = [self.dataSource analysisView:self barGraphicColor:i];
        
        CGFloat height = 0.0;
        if ([self.dataSource respondsToSelector:@selector(analysisView:barGraphicHeight:)])
            height = [self.dataSource analysisView:self barGraphicHeight:i];
        
        layer.backgroundColor = sGraphicBarColor.CGColor;
        layer.frame = CGRectMake(iWeight + (unitWeight - weight)/2, 0, weight, height);
    }
    [CATransaction commit];
}
- (void)reloadSGraphicline {
    CGFloat xGraphicWeight = self.xGraphicWeight;
    NSInteger xAxisNumber = self.xGraphicNumber - 1;
    if (![self.dataSource respondsToSelector:@selector(analysisView:slineGraphicHeight:)])
        xAxisNumber = 0;    // no data for curve
    
    NSArray *layers = [self.sGraphicline.layer sublayers];
    for (int i = (int)layers.count - 1; i >= xAxisNumber; -- i) {
        [[layers objectAtIndex:i] removeFromSuperlayer];
    }
    
    layers = [self.sGraphicline.layer sublayers];
    for (int i = (int)layers.count; i < 1 && i < xAxisNumber; ++ i) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        [self.sGraphicline.layer insertSublayer:shapeLayer atIndex:0];
    }

    layers = [self.sGraphicline.layer sublayers];
    if (layers.count < 1) return;
    
    CAShapeLayer *shapelayer = [layers objectAtIndex:0];
    UIColor *sGraphiclineColor = [UIColor clearColor];
    if ([self.dataSource respondsToSelector:@selector(slineGraphicColorInAnalysisView:)])
        sGraphiclineColor = [self.dataSource slineGraphicColorInAnalysisView:self];
    
    shapelayer.frame = self.sGraphicline.layer.bounds;
    shapelayer.fillColor = [UIColor clearColor].CGColor;
    shapelayer.strokeColor = sGraphiclineColor.CGColor;
    shapelayer.lineWidth = 4.0;
    
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:xAxisNumber];
    CGFloat iWeight = 0.0, unitWeight = xGraphicWeight;
    for (int i = 0; i < xAxisNumber; ++ i, iWeight += unitWeight) {
        CGFloat height = [self.dataSource analysisView:self slineGraphicHeight:i];
        CGPoint point = CGPointMake(iWeight + unitWeight/2.0, height);
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    CGPathRef slineCGPath = [[self bezierPathWithPoints:points] CGPath];
    shapelayer.path = slineCGPath;
}

- (UIBezierPath *)bezierPathWithPoints:(NSArray *)points {
    if (points.count < 2) return nil;
    // there is 2 * (points.count - 1) control points
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:((points.count - 1) * 2)];
    NSMutableArray *calPoints = [NSMutableArray arrayWithCapacity:points.count];
    [calPoints addObject:[points firstObject]];
    [calPoints addObjectsFromArray:points];
    [calPoints addObject:[points lastObject]];
    //
    for (int i = 1; i < calPoints.count - 2; ++ i) {
        // the control point
        CGPoint start = [[calPoints objectAtIndex:i - 1] CGPointValue];
        CGPoint apoint = [[calPoints objectAtIndex:i] CGPointValue];
        CGPoint bpoint = [[calPoints objectAtIndex:i + 1] CGPointValue];
        CGPoint end = [[calPoints objectAtIndex:i + 2] CGPointValue];
        
        CGPoint acontrol = CGPointMake(apoint.x + (bpoint.x - start.x)/8, apoint.y + (bpoint.y - start.y)/8);
        CGPoint bcontrol = CGPointMake(bpoint.x - (end.x - apoint.x)/8, bpoint.y - (end.y - apoint.y)/8);

        [controls addObject:[NSValue valueWithCGPoint:acontrol]];
        [controls addObject:[NSValue valueWithCGPoint:bcontrol]];
    }
    // Create the path data
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.usesEvenOddFillRule = YES;
    bezierPath.lineCapStyle = kCGLineCapRound;  // corner
    bezierPath.lineJoinStyle = kCGLineCapRound;  // terminal
    
    CGPoint start = [[points objectAtIndex:0] CGPointValue];
    [bezierPath moveToPoint:start];
    // there are more than two points in array points.
    for (int i = 1, j = 0; i < points.count; ++ i, j += 2) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint acontrol = [[controls objectAtIndex:j] CGPointValue];
        CGPoint bcontrol = [[controls objectAtIndex:j + 1] CGPointValue];
        [bezierPath addCurveToPoint:point controlPoint1:acontrol controlPoint2:bcontrol];
    }
    // Draws curves
    return bezierPath;
}

@end
