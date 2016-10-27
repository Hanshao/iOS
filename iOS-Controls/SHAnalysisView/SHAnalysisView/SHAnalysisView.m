//
//  SHAnalysisView.m
//  SHAnalysisView
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "SHAnalysisView.h"

@interface SHAnalysisView ()
// 容器视图
@property (strong, nonatomic) UIView *yAxiasView;   // y坐标值区域
@property (strong, nonatomic) UIView  *graphicView;  // 绘图区域, 贝塞尔曲线
@property (strong, nonatomic) UIScrollView *scrollView;    // 滚动绘图区域
// 坐标线
@property (strong, nonatomic) NSArray *yTitleViews;
@property (strong, nonatomic) NSArray *yLineViews;
// 绘图区域
@property (strong, nonatomic) NSArray *xTitleViews; // 标题
@property (strong, nonatomic) CAShapeLayer  *shapeLayer;     // 贝塞尔曲线
@property (strong, nonatomic) CAGradientLayer *gradientLayer;   // 渐变层
// 辅助视图
@property (strong, nonatomic) CAShapeLayer *dotShapeLayer;   // 虚线
@property (strong, nonatomic) NSArray *pointValues;      // 坐标点
@property (strong, nonatomic) NSArray *accessoryViews;  // 辅助视图

@end

@implementation SHAnalysisView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

// 初始化
- (void)initialize {
    // y纵坐标
    UIView *yAxiasView = [[UIView alloc] init];
    [self addSubview:yAxiasView];
    yAxiasView.backgroundColor = [UIColor clearColor];
    self.yAxiasView = yAxiasView;
    // 绘图滚动区域
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    // 绘图区域
    UIView *graphicView = [[UIView alloc] init];
    graphicView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:graphicView];
    self.graphicView = graphicView;
    // 渐变层
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    [self.graphicView.layer insertSublayer:gradientLayer atIndex:0];
    self.gradientLayer = gradientLayer;
    // 数据
    self.yLineViews = @[];
    self.yTitleViews = @[];
    self.xTitleViews = @[];
    
    self.pointValues = @[];
    self.accessoryViews = @[];
    // 配置
    self.curcolor = [UIColor whiteColor]; // 曲线颜色
    self.shacolor = [UIColor blackColor]; // 曲线阴影颜色
    self.begincolor = [UIColor greenColor]; // 渐变颜色
    self.endcolor = [UIColor clearColor]; // 渐变颜色
    self.textcolor = [UIColor whiteColor];   // 文本色
    self.font = [UIFont systemFontOfSize:12.0];    // 文本大小
    self.axiscolor = [UIColor whiteColor]; // 坐标线颜色
    self.dotcolor = [UIColor whiteColor];   // 虚线颜色
}

#pragma mark
#pragma mark 布局/绘制
- (void)layoutSubviews {
    // 布局子视图
    CGSize size = self.bounds.size;
    CGFloat xsize = size.width, ysize = size.height;
    // y 横线
    self.yAxiasView.frame = CGRectMake(0, 0, xsize, ysize);
    self.scrollView.frame = CGRectMake(36, 0, xsize - 36 - 32, ysize);
    // 刷新
    [self reloadGraphics];
}
// 刷新绘图
- (void)reloadGraphics {
    NSInteger lineNumbers = 0;
    if ([self.delegate respondsToSelector:@selector(numbersOfRowlineInAnalysisView:)])
        lineNumbers = [self.delegate numbersOfRowlineInAnalysisView:self];
    if (lineNumbers < 0) lineNumbers = 0;
    
    CGFloat rowHeight = 32;
    if ([self.delegate respondsToSelector:@selector(rowHeightInAnalysisView:)])
        rowHeight = [self.delegate rowHeightInAnalysisView:self];
    if (rowHeight < 0) rowHeight = 32;

    CGFloat colWidth = 64;
    if ([self.delegate respondsToSelector:@selector(columnWidthInAnalysisView:)])
        colWidth = [self.delegate columnWidthInAnalysisView:self];
    if (colWidth < 0) colWidth = 64;
    
    NSInteger colNumbers = 0;
    if ([self.delegate respondsToSelector:@selector(numbersOfColumnlineInAnalysisView:)])
        colNumbers = [self.delegate numbersOfColumnlineInAnalysisView:self];
    if (colNumbers < 0) colNumbers = 0;
    
    CGSize size = self.scrollView.bounds.size;
    CGFloat ysize = size.height, xsize = colWidth * colNumbers;
    self.graphicView.frame = CGRectMake(0, 0, xsize, ysize);
    self.scrollView.contentSize = CGSizeMake(xsize, ysize);
    
    [self reloadYAxiasViewWithLineNumbers:lineNumbers rowHeight:rowHeight];
    [self reloadGraphicViewWithColNumbers:colNumbers colWidth:colWidth];
    [self reloadAccessorysWithColNumbers:colNumbers colWidth:colWidth];
}

// 显示虚线
- (void)showDotline:(BOOL)visible atColumnline:(NSInteger)column {
    CAShapeLayer *dotShapeLayer = self.dotShapeLayer;
    if (!dotShapeLayer) {
        dotShapeLayer = [CAShapeLayer layer];
        self.dotShapeLayer = dotShapeLayer;
        [self.graphicView.layer insertSublayer:dotShapeLayer above:self.gradientLayer];
    }
    if (column < 0 || column >= self.pointValues.count) {
        visible = NO;
    }
    if (!visible) {
        dotShapeLayer.hidden = YES;
        return;
    }
    
    dotShapeLayer.bounds = self.graphicView.bounds;
    dotShapeLayer.position = self.graphicView.center;
     // 设置虚线颜色为blackColor
    dotShapeLayer.strokeColor = self.dotcolor.CGColor;
     // 3.0f设置虚线的宽度
    dotShapeLayer.lineWidth = AxisWidth;
    dotShapeLayer.lineJoin = kCALineJoinRound;
     // 3=线的宽度 1=每条线的间距
    dotShapeLayer.lineDashPattern = @[@(3), @(2)];
    // Setup the path
    CGSize size = self.graphicView.bounds.size;
    CGPoint start = [self.pointValues[column] CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, start.x, size.height - 32);
    dotShapeLayer.path = path;
}
// 刷新辅助视图
- (UIView *)dequeueAccessoryViewForColumnline:(NSInteger)column {
    if (column < 0 || column >= self.accessoryViews.count)
        return nil;
    return self.accessoryViews[column];
}
- (void)reloadAccessorys {
    CGFloat colWidth = 64;
    if ([self.delegate respondsToSelector:@selector(columnWidthInAnalysisView:)])
        colWidth = [self.delegate columnWidthInAnalysisView:self];
    if (colWidth < 0) colWidth = 64;
    
    NSInteger colNumbers = 0;
    if ([self.delegate respondsToSelector:@selector(numbersOfColumnlineInAnalysisView:)])
        colNumbers = [self.delegate numbersOfColumnlineInAnalysisView:self];
    if (colNumbers < 0) colNumbers = 0;

    [self reloadAccessorysWithColNumbers:colNumbers colWidth:colWidth];
}
- (void)reloadAccessorysWithColNumbers:(NSInteger)colNumbers colWidth:(CGFloat)colWidth {
    if (![self.delegate respondsToSelector:@selector(accessoryViewInAnalysisView:forColumnline:)]
        || ![self.delegate respondsToSelector:@selector(valueHeightInAnalysisView:forColumnline:)]) {
        colNumbers = 0;
    }

    NSMutableArray *accessoryViews = self.accessoryViews.mutableCopy;
    NSMutableArray *points = self.pointValues.mutableCopy;
    for (int i = (int)accessoryViews.count - 1; i >= colNumbers; -- i) {
        UIView *accessoryView = accessoryViews[i];
        [accessoryView removeFromSuperview];
        [accessoryViews removeObjectAtIndex:i];

        [points removeObjectAtIndex:i];
    }
    for (int i = 0; i < accessoryViews.count; ++ i) {
        UIView *accessoryView = [self.delegate accessoryViewInAnalysisView:self forColumnline:i];
        if (accessoryView != accessoryViews[i]) {
            // 移除之前的
            UIView *taccessoryView = accessoryViews[i];
            [taccessoryView removeFromSuperview];
            // 替换为新的视图
            [accessoryViews replaceObjectAtIndex:i withObject:accessoryView];
            [self.graphicView addSubview:accessoryView];
        }
    }
    CGSize size = self.graphicView.bounds.size;
    for (int i = (int)accessoryViews.count; i < colNumbers; ++ i) {
        UIView *accessoryView = [self.delegate accessoryViewInAnalysisView:self forColumnline:i];
        [self.graphicView addSubview:accessoryView];
        [accessoryViews addObject:accessoryView];
        
        CGFloat height = [self.delegate valueHeightInAnalysisView:self forColumnline:i];
        CGPoint point = CGPointMake(i * colWidth + colWidth/2, size.height - 32 - height);
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    for (int i = 0; i < colNumbers; ++ i) {
        UIView *accessoryView = accessoryViews[i];
        
        CGPoint point = [points[i] CGPointValue];
        accessoryView.center = point;
    }
    // 拷贝
    self.accessoryViews = [NSArray arrayWithArray:accessoryViews];
    self.pointValues = [NSArray arrayWithArray:points];
}
// y 横向
- (void)reloadYAxiasViewWithLineNumbers:(NSInteger)lineNumbers rowHeight:(CGFloat)rowHeight {
    // 坐标线
    NSMutableArray *yLineViews = self.yLineViews.mutableCopy;
    for (int i = (int)yLineViews.count - 1; i >= lineNumbers; -- i) {
        UIImageView *imageView = yLineViews[i];
        [imageView removeFromSuperview];
        [yLineViews removeObjectAtIndex:i];
    }
    for (int i = (int)yLineViews.count; i < lineNumbers; ++ i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = self.axiscolor;
        
        [yLineViews addObject:imageView];
        [self.yAxiasView addSubview:imageView];
    }
    CGSize size = self.yAxiasView.bounds.size;
    for (int i = 0; i < lineNumbers; ++ i) {
        UIImageView *imageView = yLineViews[i];
        CGFloat y = size.height - 32 - i * rowHeight, xsize = size.width - 36 - 32;
        imageView.frame = CGRectMake(36, y, xsize, AxisWidth);
    }
    // 文本
    NSMutableArray *yTitleViews = self.yTitleViews.mutableCopy;
    for (int i = (int)yTitleViews.count - 1; i >= lineNumbers; -- i) {
        CATextLayer *textLayer = yTitleViews[i];
        [textLayer removeFromSuperlayer];
        [yTitleViews removeObjectAtIndex:i];
    }
    for (int i = (int)yTitleViews.count; i < lineNumbers; ++ i) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = self.textcolor;
        textLabel.font = self.font;
        
        [yTitleViews addObject:textLabel];
        [self.yAxiasView addSubview:textLabel];
    }
    for (int i = 0; i < lineNumbers; ++ i) {
        UILabel *textLabel = yTitleViews[i];
        CGFloat y = size.height - 32 - rowHeight * i;
        textLabel.frame = CGRectMake(0, y - 10, 36 - AxisWidth, 20);
        NSString *title = @"";
        if ([self.delegate respondsToSelector:@selector(titleInAnalysisView:forRowline:)]) {
            title = [self.delegate titleInAnalysisView:self forRowline:i];
        }
        textLabel.text = title;
    }
    // 纵线
    NSInteger VImageViewTag = 1100;
    UIImageView *vimageView = [self.yAxiasView viewWithTag:VImageViewTag];
    if (!vimageView) {
        vimageView = [[UIImageView alloc] init];
        vimageView.backgroundColor = self.axiscolor;
        [self.yAxiasView addSubview:vimageView];
        vimageView.tag = VImageViewTag;
    }
    CGFloat y = size.height - 32 - (rowHeight * (lineNumbers > 0 ? lineNumbers - 1 : 0));
    CGFloat ysize = rowHeight * (lineNumbers > 0 ? lineNumbers - 1 : 0);
    vimageView.frame = CGRectMake(36.0 - AxisWidth, y, AxisWidth, ysize + AxisWidth);
    // 拷贝数据
    self.yLineViews = [NSArray arrayWithArray:yLineViews];
    self.yTitleViews = [NSArray arrayWithArray:yTitleViews];
}
// 绘图区域
- (void)reloadGraphicViewWithColNumbers:(NSInteger)colNumers colWidth:(CGFloat)colWidth {
    // 文本
    NSMutableArray *xTitleViews = self.xTitleViews.mutableCopy;
    for (int i = (int)xTitleViews.count - 1; i >= colNumers; -- i) {
        UILabel *textLabel = xTitleViews[i];
        [textLabel removeFromSuperview];
    }
    for (int i = (int)xTitleViews.count; i < colNumers; ++ i) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = self.textcolor;
        textLabel.font = self.font;
        
        [xTitleViews addObject:textLabel];
        [self.graphicView addSubview:textLabel];
    }
    CGSize size = self.graphicView.bounds.size;
    for (int i = 0; i < colNumers; ++ i) {
        UILabel *textLabel = xTitleViews[i];
        CGFloat y = size.height - 32 + 2, x = i * colWidth;
        textLabel.frame = CGRectMake(x, y, colWidth, 20);
        
        NSString *title = @"";
        if ([self.delegate respondsToSelector:@selector(titleInAnalysisView:forColumnline:)]) {
            title = [self.delegate titleInAnalysisView:self forColumnline:i];
        }
        textLabel.text = title;
    }
    self.xTitleViews = [NSArray arrayWithArray:xTitleViews];
    // 贝塞尔曲线
    if ([self.delegate respondsToSelector:@selector(valueHeightInAnalysisView:forColumnline:)]) {
        NSMutableArray *points = @[].mutableCopy;
        for (int i = 0; i < colNumers; ++ i) {
            CGFloat x = i * colWidth + colWidth/2;
            CGFloat height = [self.delegate valueHeightInAnalysisView:self forColumnline:i];
            
            CGPoint point = CGPointMake(x, size.height - 32 - height);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        // 保存
        self.pointValues = [NSArray arrayWithArray:points];
        // 贝塞尔曲线
        CGFloat xsize = colNumers * colWidth;
        CAShapeLayer *shapeLayer = self.shapeLayer;
        if (!shapeLayer) {
            shapeLayer = [[CAShapeLayer alloc] init];
            shapeLayer.lineWidth = CurveWidth;
            shapeLayer.fillColor = nil;
            shapeLayer.shadowOffset = CGSizeMake(0, 2);
            shapeLayer.shadowOpacity = 1.0;
            shapeLayer.strokeColor = self.curcolor.CGColor;
            [self.graphicView.layer addSublayer:shapeLayer];
            self.shapeLayer = shapeLayer;
        }
        UIBezierPath *bezierPath = [self kBezierPathWithPoints:points];
        shapeLayer.frame = CGRectMake(0, 0, xsize, size.height);
        shapeLayer.shadowColor = self.shacolor.CGColor;
        shapeLayer.path = bezierPath.CGPath;
        // 渐变层的掩码层
        CGPoint start = [[points firstObject] CGPointValue];
        CGPoint end = [[points lastObject] CGPointValue];
        
        CGMutablePathRef pathRef = CGPathCreateMutableCopy(bezierPath.CGPath);
        CGPathAddLineToPoint(pathRef, NULL, end.x, end.y);
        CGPathAddLineToPoint(pathRef, NULL, end.x, size.height - 32);
        CGPathAddLineToPoint(pathRef, NULL, start.x, size.height - 32);
        CGPathMoveToPoint(pathRef, NULL, start.x, start.y);
        CGPathCloseSubpath(pathRef);
        CAShapeLayer *maskShapeLayer = [[CAShapeLayer alloc] init];
        maskShapeLayer.fillColor = [UIColor blackColor].CGColor;
        maskShapeLayer.path = pathRef;
        // 渐变层
        CAGradientLayer *gradientLayer = self.gradientLayer;
        gradientLayer.colors = @[(id)self.begincolor.CGColor, (id)self.endcolor.CGColor];
        gradientLayer.frame = CGRectMake(0, 0, xsize, size.height - 32);
        gradientLayer.mask = maskShapeLayer;
    }
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
        CGPoint start = [calPoints[i - 1] CGPointValue];
        CGPoint apoint = [calPoints[i] CGPointValue];
        CGPoint bpoint = [calPoints[i + 1] CGPointValue];
        CGPoint end = [calPoints[i + 2] CGPointValue];
        
        double K = 5;
        CGPoint acontrol = CGPointMake(apoint.x + (bpoint.x - start.x)/K, apoint.y + (bpoint.y - start.y)/K);
        CGPoint bcontrol = CGPointMake(bpoint.x - (end.x - apoint.x)/K, bpoint.y - (end.y - apoint.y)/K);
        
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

- (UIBezierPath *)kBezierPathWithPoints:(NSArray *)points {
    if (points.count < 2) return nil;
    // there is 2 * (points.count - 1) control points
    NSInteger count = points.count;
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:((count - 1) * 2)];
    [controls addObject:[points firstObject]];
    for (int i = 1; i < count - 1; ++ i) {
        // the control point
        CGPoint start = [points[i - 1] CGPointValue];
        CGPoint cur = [points[i] CGPointValue];
        CGPoint end = [points[i + 1] CGPointValue];
        // l1:|AB| and l2:|BC|
        double l1 = sqrt((cur.x - start.x) * (cur.x - start.x) + (cur.y - start.y) * (cur.y - start.y));
        double l2 = sqrt((end.x - cur.x) * (end.x - cur.x) + (end.y - cur.y) * (end.y - cur.y));
        // 中点
        CGPoint p1 = CGPointMake((cur.x + start.x)/2.0, (cur.y + start.y)/2.0);
        CGPoint p2 = CGPointMake((end.x + cur.x)/2.0, (end.y + cur.y)/2.0);
        // B点
        double l = l1 + l2;
        double d = l == 0 ? 0 : l1 / l;
        CGPoint p = CGPointMake(p2.x - p1.x, p2.y - p1.y);
        CGPoint pb = CGPointMake(p1.x + d * p.x, p1.y + d * p.y);
        // 适当收缩
        double K = 0.84; // 收缩比例K [0, 1], K越小，收缩的越多
        p1 = CGPointMake(pb.x + K * (p1.x - pb.x), pb.y + K * (p1.y - pb.y));
        p2 = CGPointMake(pb.x + K * (p2.x - pb.x), pb.y + K * (p2.y - pb.y));
        // 平移, 控制点
        CGPoint px = CGPointMake(cur.x - pb.x, cur.y - pb.y);
        CGPoint cp1 = CGPointMake(px.x + p1.x, px.y + p1.y);
        CGPoint cp2 = CGPointMake(px.x + p2.x, px.y + p2.y);
        [controls addObject:[NSValue valueWithCGPoint:cp1]];
        [controls addObject:[NSValue valueWithCGPoint:cp2]];
    }
    [controls addObject:[points lastObject]];
    // Create the path data
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.usesEvenOddFillRule = YES;
    bezierPath.lineCapStyle = kCGLineCapRound;  // corner
    bezierPath.lineJoinStyle = kCGLineCapRound;  // terminal
    
    CGPoint start = [[points firstObject] CGPointValue];
    [bezierPath moveToPoint:start];
    // there are more than two points in array points.
    for (int i = 1, j = 0; i < count; ++ i, j += 2) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint cp1 = [[controls objectAtIndex:j] CGPointValue];
        CGPoint cp2 = [[controls objectAtIndex:j + 1] CGPointValue];
        
        [bezierPath addCurveToPoint:point controlPoint1:cp1 controlPoint2:cp2];
    }
    // Draws curves
    return bezierPath;
}

@end
