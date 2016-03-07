//
//  HSPolyline.m
//  AirCleaner
//
//  Created by Shaojun Han on 2/15/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "HSPolyline.h"

@interface UIScrollView (UITouch)

@end

@implementation UIScrollView (UITouch)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

@end

@interface HSPolyline ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *columnlines;
@property (strong, nonatomic) UIView *polylines;
@property (strong, nonatomic) UIView *rowlines;
@property (strong, nonatomic) UIView *polylines2;

@property (assign, nonatomic) CGRect rectangle;
@property (strong, nonatomic) NSMutableArray *points;
@property (assign, nonatomic) NSInteger rowsNumber;
@property (assign, nonatomic) NSInteger columnsNumber;

@end

@implementation HSPolyline

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.ymin = 0.0;
    self.ymax = 1.0;
    self.itemSpacing = 100;
    self.sectionSpacing = 20;
    self.lineColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    self.titleColor = [UIColor colorWithRed:30/255.0 green:197/255.0 blue:175/255.0 alpha:1.0];
}

- (void)drawRect:(CGRect)rect {
    [self initialize];
}

- (void)initialize {
    if (self.scrollView) return;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    CGSize size = self.bounds.size;
    CGFloat spacing = self.sectionSpacing;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    self.columnlines = [[UIView alloc] initWithFrame:bounds];
    self.columnlines.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.columnlines];
    self.columnlines.layer.masksToBounds = YES;
    
    CGRect rectangle = CGRectMake(0, 0, size.width, size.height - spacing);
    self.polylines = [[UIView alloc] initWithFrame:rectangle];
    self.polylines.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.polylines];
    
    self.polylines2 = [[UIView alloc] initWithFrame:rectangle];
    self.polylines2.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.polylines2];
    
    self.rowlines = [[UIView alloc] initWithFrame:rectangle];
    self.rowlines.backgroundColor = [UIColor clearColor];
    [self insertSubview:self.rowlines atIndex:0];
    self.rowlines.layer.masksToBounds = YES;
    self.rectangle = rectangle;
    
    self.points = [NSMutableArray array];
}

// 刷新
- (void)reloadData {
    // 数据
    self.rowsNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfRowsInPolyline:)])
        self.rowsNumber = [self.dataSource numberOfRowsInPolyline:self];
    self.columnsNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInPolyline:)])
        self.columnsNumber = [self.dataSource numberOfColumnsInPolyline:self];
    // scrollview
    CGSize size = self.bounds.size;
    CGFloat spacing = self.sectionSpacing;
    CGFloat width = self.columnsNumber * self.itemSpacing;
    self.scrollView.contentSize = CGSizeMake(width, size.height);
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    [self.scrollView setContentOffset:CGPointMake(MAX(width - size.width, 0), 0) animated:NO];
    // subviews
    self.rowlines.frame = CGRectMake(0, 0, size.width, size.height - spacing);
    self.columnlines.frame = CGRectMake(0, 0, width, size.height);
    self.polylines.frame = CGRectMake(0, 0, width, size.height - spacing);
    self.polylines2.frame = CGRectMake(0, 0, width, size.height - spacing);
    self.rectangle = CGRectMake(0, 0, width, size.height - spacing);
    // points
    self.accessoryView.hidden = YES;
    [self.points removeAllObjects];
    // 刷新
    [self reloadRowlines];
    [self reloadColumnlines];
    [self reloadPolylines];
    [self reloadPolylines2];
}

- (void)reloadRowlines {
    // 清理
    NSInteger rowsNumber = self.rowsNumber;
    NSArray *layers = self.rowlines.layer.sublayers;
    for (NSInteger i = layers.count - 1; i >= rowsNumber; -- i) {
        CALayer *layer = [layers objectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    
    UIColor *lineColor = self.lineColor;
    layers = self.rowlines.layer.sublayers;
    for (NSInteger i = layers.count; i < rowsNumber; ++ i) {
        CALayer *layer = [[CAShapeLayer alloc] init];
        layer.backgroundColor = lineColor.CGColor;
        [self.rowlines.layer addSublayer:layer];
    }
    // 检查
    if (rowsNumber < 1) return;
    layers = self.rowlines.layer.sublayers;
    // 添加
    CGSize size = self.rowlines.bounds.size;
    CGFloat y = size.height, rowHeight = rowsNumber < 2 ? 0 : (size.height - 1.0)/(rowsNumber - 1);
    for (int i = (int)(rowsNumber - 1); i >= 0; -- i, y -= rowHeight) {
        CALayer *layer = [layers objectAtIndex:i];
        layer.frame = CGRectMake(0, y - 1.0, size.width, 1.0);
    }
}
- (void)reloadColumnlines {
    NSInteger columnsNumber = self.columnsNumber;
    NSArray *layers = self.columnlines.layer.sublayers;
    for (NSInteger i = layers.count - 1; i >= columnsNumber; -- i) {
        CALayer *layer = [layers objectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    
    UIColor *lineColor = self.lineColor;
    layers = self.columnlines.layer.sublayers;
    for (NSInteger i = layers.count; i < columnsNumber; ++ i) {
        CALayer *layer = [[CAShapeLayer alloc] init];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        
        CALayer *linelayer = [[CALayer alloc] init];
        linelayer.backgroundColor = lineColor.CGColor;
        [layer addSublayer:linelayer];
        
        CATextLayer *titlelayer = [[CATextLayer alloc] init];
        titlelayer.foregroundColor = self.titleColor.CGColor;
        titlelayer.anchorPoint = CGPointMake(0.5, 0.5);
        titlelayer.alignmentMode = @"center";
        titlelayer.fontSize = 12.0f;
        [layer addSublayer:titlelayer];
        
        [self.columnlines.layer addSublayer:layer];
    }
    // 检查
    if (columnsNumber < 1) return;
    layers = self.columnlines.layer.sublayers;
    // 添加
    CGSize size = self.rectangle.size;
    CGFloat height = self.columnlines.bounds.size.height;
    CGFloat itSpacing = 0, columnSpacing = self.itemSpacing;
    for (int i = 0; i < columnsNumber; ++ i, itSpacing += columnSpacing) {
        CALayer *layer = [layers objectAtIndex:i];
        layer.frame = CGRectMake(itSpacing, 0, columnSpacing, height);
        
        CALayer *linelayer = [layer.sublayers objectAtIndex:0];
        linelayer.frame = CGRectMake(columnSpacing/2 - 0.5, 0, 1.0, size.height);
        
        CATextLayer *titlelayer = (CATextLayer *)[layer.sublayers objectAtIndex:1];
        titlelayer.frame = CGRectMake(0, 4 + size.height, columnSpacing, - 4 + height - size.height);
        titlelayer.contentsScale = [UIScreen mainScreen].scale;
        
        NSString *title = nil;
        if ([self.dataSource respondsToSelector:@selector(polyline:titleOfColumn:)])
            title = [self.dataSource polyline:self titleOfColumn:i];
        titlelayer.string = title;
    }
}
- (void)reloadPolylines {
    // 清理
    NSInteger columnsNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(polyline:valueOfColumn:)])
        columnsNumber = self.columnsNumber;
    
    NSArray *shapeLayers = self.polylines.layer.sublayers;
    for (NSInteger i = shapeLayers.count - 1; i >= columnsNumber; -- i) {
        CALayer *layer = [shapeLayers objectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    
    shapeLayers = self.polylines.layer.sublayers;
    for (NSInteger i = shapeLayers.count; i < columnsNumber; ++ i) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.frame = self.rectangle;
        shapeLayer.lineWidth = 1.6;
        [self.polylines.layer addSublayer:shapeLayer];
    }
    // 检查
    if (columnsNumber < 1) return;
    // 添加
    CGSize size = self.rectangle.size;
    CGFloat itSpacing = 0, columnSpacing = self.itemSpacing;
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:columnsNumber];
    for (int i = 0; i < columnsNumber; ++ i, itSpacing += columnSpacing) {
        CGFloat value = [self.dataSource polyline:self valueOfColumn:i];
        CGFloat y = size.height - [self heightOfValue:value];
        CGFloat x = itSpacing + columnSpacing/2.0 - 0.5;
        [list addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    UIColor *color =  nil;
    shapeLayers = self.polylines.layer.sublayers;
    for (NSInteger i = 0; i < list.count - 1; ++ i, itSpacing += columnSpacing) {
        CGPoint start = [[list objectAtIndex:i] CGPointValue];
        CGPoint end = [[list objectAtIndex:i + 1] CGPointValue];
        
        if ([self.dataSource respondsToSelector:@selector(polyline:colorAtStart:end:)]) {
            color = [self.dataSource polyline:self colorAtStart:i end:i + 1];
        }
        
        CAShapeLayer *shapeLayer = [shapeLayers objectAtIndex:i];
        [self shapeLayer:shapeLayer start:start end:end color:color];
        [self.points addObject:[NSValue valueWithCGPoint:start]];
    }
    
    NSInteger last = list.count - 1;
    CGPoint start = [[list objectAtIndex:last] CGPointValue];
    CAShapeLayer *shapeLayer = [shapeLayers objectAtIndex:last];
    [self shapeLayer:shapeLayer start:start color:color];
    [self.points addObject:[NSValue valueWithCGPoint:start]];
}
- (void)reloadPolylines2 {
    // 清理
    NSInteger columnsNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(polyline:value2OfColumn:)])
        columnsNumber = self.columnsNumber;
    
    NSArray *shapeLayers = self.polylines2.layer.sublayers;
    for (NSInteger i = shapeLayers.count - 1; i >= columnsNumber; -- i) {
        CALayer *layer = [shapeLayers objectAtIndex:i];
        [layer removeFromSuperlayer];
    }
    
    shapeLayers = self.polylines2.layer.sublayers;
    for (NSInteger i = shapeLayers.count; i < columnsNumber; ++ i) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.frame = self.rectangle;
        shapeLayer.lineWidth = 1.6;
        [self.polylines2.layer addSublayer:shapeLayer];
    }
    // 检查
    if (columnsNumber < 1) return;
    // 添加
    CGSize size = self.rectangle.size;
    CGFloat itSpacing = 0, columnSpacing = self.itemSpacing;
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:columnsNumber];
    for (int i = 0; i < columnsNumber; ++ i, itSpacing += columnSpacing) {
        CGFloat value = [self.dataSource polyline:self value2OfColumn:i];
        CGFloat y = size.height - [self heightOfValue:value];
        CGFloat x = itSpacing + columnSpacing/2.0 - 0.5;
        [list addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    UIColor *color = nil;
    shapeLayers = self.polylines2.layer.sublayers;
    for (NSInteger i = 0; i < list.count - 1; ++ i, itSpacing += columnSpacing) {
        CGPoint start = [[list objectAtIndex:i] CGPointValue];
        CGPoint end = [[list objectAtIndex:i + 1] CGPointValue];
        
        if ([self.dataSource respondsToSelector:@selector(polyline:color2AtStart:end:)]) {
            color = [self.dataSource polyline:self color2AtStart:i end:i + 1];
        }
        
        CAShapeLayer *shapeLayer = [shapeLayers objectAtIndex:i];
        [self shapeLayer:shapeLayer start:start end:end color:color];
        [self.points addObject:[NSValue valueWithCGPoint:start]];
    }
    
    NSInteger last = list.count - 1;
    CGPoint start = [[list objectAtIndex:last] CGPointValue];
    CAShapeLayer *shapeLayer = [shapeLayers objectAtIndex:last];
    [self shapeLayer:shapeLayer start:start color:color];
    [self.points addObject:[NSValue valueWithCGPoint:start]];
}

- (void)shapeLayer:(CAShapeLayer *)shapeLayer start:(CGPoint)start color:(UIColor *)color {
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = color.CGColor;
    
    CGRect rectangle = CGRectMake(start.x - 3, start.y - 3, 6, 6);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddEllipseInRect(path, NULL, rectangle);
    CGPathCloseSubpath(path);
    shapeLayer.path = path;
    CFRelease(path);
}
- (void)shapeLayer:(CAShapeLayer *)shapeLayer start:(CGPoint)start end:(CGPoint)end color:(UIColor *)color {
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = color.CGColor;
    
    CGRect rectangle = CGRectMake(start.x - 3, start.y - 3, 6, 6);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddEllipseInRect(path, NULL, rectangle);
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x, end.y);
    
    CGPathCloseSubpath(path);
    shapeLayer.path = path;
    CFRelease(path);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.scrollView];
    for (NSValue *value in self.points) {
        CGPoint start = [value CGPointValue];
        CGRect rect = CGRectMake(start.x - 8, start.y - 8, 16, 16);
        if (!CGRectContainsPoint(rect, point)) continue;
        if ([self.delegate respondsToSelector:@selector(polyline:touchAtPoint:value:)]) {
            CGFloat value = [self valueOfHeight:self.rectangle.size.height - start.y];
            [self.delegate polyline:self touchAtPoint:start value:value];
        }
        if (self.accessoryView) {
            self.accessoryView.hidden = NO;
            [self.scrollView addSubview:self.accessoryView];
        } break;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

// 数值和坐标转换
- (CGFloat)heightOfValue:(CGFloat)value {
    CGFloat totalHeight = self.rectangle.size.height;
    CGFloat ymax = self.ymax, ymin = self.ymin;
    if (ymax <= ymin) return 0;
    return totalHeight * (value - ymin) / (ymax - ymin);
}
- (CGFloat)valueOfHeight:(CGFloat)height {
    CGFloat totalHeight = self.rectangle.size.height;
    CGFloat ymax = self.ymax, ymin = self.ymin;
    if (ymax <= ymin) return 0;
    return height * (ymax - ymin) / totalHeight + ymin;
}

@end
