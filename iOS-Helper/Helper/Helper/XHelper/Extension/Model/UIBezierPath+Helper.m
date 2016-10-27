//
//  UIBezierPath+Helper.m
//  Helper
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIBezierPath+Helper.h"

@implementation UIBezierPath (Helper)

+ (instancetype)bezierPathWithPoints:(NSArray *)points {
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
