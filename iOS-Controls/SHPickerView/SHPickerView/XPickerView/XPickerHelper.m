//
//  XPickerHelper.m
//  zencro
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import "XPickerHelper.h"

@implementation XPickerHelper

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubviews];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

- (void)initSubviews {
    XPickerView *pickerView = [[XPickerView alloc] init];
    [self addSubview:pickerView];
    // 默认颜色
    pickerView.backgroundColor = [UIColor colorWithRed:0x32/255.0 green:0x32/255.0 blue:0x32/255.0 alpha:1.0];
    // 约束 水平:左右居父视图为0 垂直:底部居父视图为0 高度:196
    pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pickerView]-0-|" options:0 metrics:nil views:@{@"pickerView":pickerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickerView(196)]-0-|" options:0 metrics:nil views:@{@"pickerView":pickerView}]];
    
    self.pickerView = pickerView;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self addGestureRecognizer:gesture];    
}

- (void)tapHandle:(id)sender {
    [self dismissWithAnimated:YES];
}
// 显示
- (void)showWithAnimated:(BOOL)animated {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (self.superview != keyWindow) {
        [self removeFromSuperview];
        [keyWindow addSubview:self];
        
        UIView *selfView = self;
        // 约束 水平:左右居父视图为0 垂直:上下距父视图为0
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[selfView]-0-|" options:0 metrics:nil views:@{@"selfView":selfView}]];
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[selfView]-0-|" options:0 metrics:nil views:@{@"selfView":selfView}]];
    }

    CGSize size = [UIScreen mainScreen].bounds.size;
    if (animated) {
        self.alpha = 0.0f;
        self.pickerView.center = CGPointMake(size.width/2.0, size.height + 196/2.0);
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0f;
            self.pickerView.center = CGPointMake(size.width/2.0, size.height - 196/2.0);
        }];
    } else {
        self.alpha = 1.0f;
    }
}

// 隐藏
- (void)dismissWithAnimated:(BOOL)animated {
    if (animated) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0f;
            self.pickerView.center = CGPointMake(size.width/2.0, size.height + 196/2.0);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        self.alpha = 0.0f;
        [self removeFromSuperview];
    }
}

- (void)dealloc {
    NSLog(@"helper.dealloc");
}

@end

