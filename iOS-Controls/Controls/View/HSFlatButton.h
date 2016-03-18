//
//  HSFlatButton.h
//  Controls
//
//  Created by Shaojun Han on 3/12/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//  0.0.1 开发中...

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FlatButtonType) {
    FlatButtonOneType = 1,
    FlatButtonHamburgerType = 2,
    FlatButtonMinusType = 3,
    FlatButtonAddType = 4,
    FlatButtonCloseType = 5,
    FlatButtonBackwardType = 6,
    FlatButtonForwardType = 7,
    FlatButtonDownwardType = 8,
    FlatButtonUpwardType = 9
};

@interface HSFlatButton : UIControl

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
// type change with animation.
- (void)animatedToType:(FlatButtonType)buttonType;
// attribute for button
- (void)setWeight:(CGFloat)weight;
- (void)setRadius:(CGFloat)radius;
- (void)setColor:(UIColor *)color;

@end
