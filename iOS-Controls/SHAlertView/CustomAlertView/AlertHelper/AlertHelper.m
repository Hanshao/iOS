//
//  AlertHelper.m
//  zencro
//
//  Created by Shaojun Han on 8/25/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import "AlertHelper.h"
#import <UIKit/UIKit.h>

@protocol AlertViewDelegate <NSObject>
- (void)alertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface AlertView : UIView

@property (strong, nonatomic) id<AlertViewDelegate> helper;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *okayBtn;
// 约束(动态变化)
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSLayoutConstraint *messageTopConstraint;

// 初始化
- (instancetype)initWithHelper:(id)helper title:(NSString *)title message:(id)message cancelTitle:(NSString *)cancelTitle okayTitle:(NSString *)okayTitle;
@end

@implementation AlertView

// 初始化
- (instancetype)initWithHelper:(id)helper title:(NSString *)title message:(id)message cancelTitle:(NSString *)cancelTitle okayTitle:(NSString *)okayTitle {
    if (self = [super initWithFrame:CGRectZero]) {
        [self initSubviews];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.helper = helper;
        self.titleLabel.text = title;
        if ([message isKindOfClass:NSString.class]) {
            self.messageLabel.text = message;
        } else if ([message isKindOfClass:NSAttributedString.class]) {
            self.messageLabel.attributedText = message;
        } else { // 更新约束
            message = nil;
            self.messageLabel.text = nil;
        }
        // 更新约束， 适配只有文字信息或标题的情况
        if (!title || !message) {
            CGFloat offset = (title || message) ? 0 : -40;
            [self.contentView removeConstraint:self.messageTopConstraint];
            NSLayoutConstraint *messageTopConstraint = [NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:offset];
            [self.contentView addConstraint:messageTopConstraint];
            self.messageTopConstraint = messageTopConstraint;
        }
        [self.cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
        [self.okayBtn setTitle:okayTitle forState:UIControlStateNormal];
    }
    return self;
}
- (void)initSubviews {
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 4.0;
    contentView.layer.masksToBounds = YES;
    // 约束 水平:左右距离父视图20间距(优先级750) 垂直:center与父视图对齐 宽度:<= 300
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20@750-[contentView]-20@750-|" options:0 metrics:nil views:@{@"contentView":contentView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:0 constant:300]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [contentView addSubview:titleLabel];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16]; // 粗体
    // 约束 水平:左右居父视图各20 垂直:顶部距父视图40
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[titleLabel]-20-|" options:0 metrics:nil views:@{@"titleLabel":titleLabel}]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[titleLabel]" options:0 metrics:nil views:@{@"titleLabel":titleLabel}]];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    [contentView addSubview:messageLabel];
    messageLabel.numberOfLines = 0;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    // 约束 水平:左右距离20 垂直:距离titleLabel底部10的距离
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[messageLabel]-20-|" options:0 metrics:nil views:@{@"messageLabel":messageLabel}]];
    NSLayoutConstraint *messageTopConstraint = [NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10];
    [contentView addConstraint:messageTopConstraint];
    self.messageTopConstraint = messageTopConstraint;
    
    UIButton *okayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contentView addSubview:okayBtn];
    okayBtn.layer.cornerRadius = 4.0; okayBtn.layer.masksToBounds = YES;
    okayBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [okayBtn setBackgroundImage:[self imageWithColor:[self redColor]] forState:UIControlStateNormal];
    [okayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okayBtn addTarget:self action:@selector(okayHandle:) forControlEvents:UIControlEventTouchUpInside];
    // 约束 水平:右端居父视图10 垂直:上30下10 高度:40
    okayBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:okayBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:okayBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:messageLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:30]];
    [okayBtn addConstraint:[NSLayoutConstraint constraintWithItem:okayBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:40]];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contentView addSubview:cancelBtn];
    cancelBtn.layer.cornerRadius = 4.0; cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.borderColor = [self redColor].CGColor;
    cancelBtn.layer.borderWidth = 1;
    [cancelBtn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn setTitleColor:[self redColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelHandle:) forControlEvents:UIControlEventTouchUpInside];
    // 约束 水平:左端居父视图10 垂直:上30下10 高度:40 宽度:与okayBtn等宽
    cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cancelBtn]-10-[okayBtn]-10-|" options:0 metrics:nil views:@{@"okayBtn":okayBtn, @"cancelBtn":cancelBtn}]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:okayBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:okayBtn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [cancelBtn addConstraint:[NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:40]];
    // 引用
    self.contentView = contentView;
    self.titleLabel = titleLabel;
    self.messageLabel = messageLabel;
    self.cancelBtn = cancelBtn;
    self.okayBtn = okayBtn;
}

- (void)okayHandle:(id)sender {
    if ([self.helper respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.helper alertView:self clickedButtonAtIndex:1];
    }
}
- (void)cancelHandle:(id)sender {
    if ([self.helper respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.helper alertView:self clickedButtonAtIndex:0];
    }
}
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIColor *)r:(UInt8)r g:(UInt8)g b:(UInt8)b {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}
- (UIColor *)redColor {
    return [self r:0xC7 g:0x23 b:0x1A];
}

@end

@interface AlertHelper ()
<
    AlertViewDelegate
>
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) id message;
@property (weak, nonatomic) AlertView *alertView;
@property (copy, nonatomic) AlertActionHandler actionHandler;

@end

@implementation AlertHelper

// 弹框
+ (instancetype)alertWithTitle:(NSString *)title message:(id)message actionHandler:(AlertActionHandler)actionHandler {
    AlertHelper *helper = [[AlertHelper alloc] initWithTitle:title message:message actionHandler:actionHandler];
    [helper showWithAnimated:YES];
    return helper;
}

- (instancetype)initWithTitle:(NSString *)title message:(id)message actionHandler:(AlertActionHandler)actionHandler {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.actionHandler = actionHandler;
    }
    return self;
}

- (void)showWithAnimated:(BOOL)animated {
    AlertView *alertView = self.alertView;
    if (!alertView) {
        alertView = [[AlertView alloc] initWithHelper:self title:self.title message:self.message cancelTitle:@"CANCEL" okayTitle:@"OK"];
        self.alertView = alertView;
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    alertView.alpha = 0.0;
    if (alertView.superview != keyWindow) {
        [alertView removeFromSuperview];
        [keyWindow addSubview:alertView];
        // 约束 上下左右居父视图为0
        alertView.translatesAutoresizingMaskIntoConstraints = NO;
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[alertView]-0-|" options:0 metrics:nil views:@{@"alertView":alertView}]];
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[alertView]-0-|" options:0 metrics:nil views:@{@"alertView":alertView}]];
    }
    
    if (!animated) {
        self.alertView.alpha = 1.0;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.alertView.alpha = 1.0;
        }];
    }
}
- (void)dismissWithAnimated:(BOOL)animated {
    if (!animated) {
        [self.alertView removeFromSuperview];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.alertView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.alertView removeFromSuperview];
        }];
    }
}

- (void)alertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.actionHandler) {
        self.actionHandler(buttonIndex);
        [self dismissWithAnimated:YES];
    }
}

@end
