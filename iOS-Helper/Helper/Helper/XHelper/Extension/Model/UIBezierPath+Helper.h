//
//  UIBezierPath+Helper.h
//  Helper
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Helper)

/**
 * 构造贝塞尔曲线路径
 * @param points 路径上的点, 至少2个点
 * @return 返回构造的贝塞尔曲线, 若points的数量少于2, 则返回nil.
 */
+ (instancetype)bezierPathWithPoints:(NSArray *)points;

@end
