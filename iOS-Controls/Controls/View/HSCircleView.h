//
//  HSCircleView.h
//  Controls
//
//  Created by Shaojun Han on 3/17/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CircleAnimationType) {
    CircleAnimationSplitType = 1,
    CircleAnimationRotateType = 2,
    CircleAnimationUnfoldType = 3
};

@interface HSCircleView : UIView

- (void)animatedToSliceWeight:(CGFloat)weight;
- (void)animatedToSliceNumber:(NSInteger)sliceNumber;
- (void)animatedToSliceColor:(UIColor *)color slice:(NSInteger)slice;
- (void)animatedWithType:(CircleAnimationType)animationType;

@end
