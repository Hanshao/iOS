//
//  AlertViewController.m
//  BonecoAir
//
//  Created by Shaojun Han on 3/30/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "AlertController.h"

@protocol AuxAlertViewDelegate <NSObject>
@optional
- (void)closeToggle:(id)sender;
- (void)okayToggle:(id)sender;
- (void)cancelToggle:(id)sender;

@end

@interface AuxAlertView : UIView
// 代理
@property (weak, nonatomic) id<AuxAlertViewDelegate> delegate;
@property (strong, nonatomic) id controller;
// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
// 容器和空间
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIButton *okayControl;
@property (weak, nonatomic) IBOutlet UIButton *cancelControl;
// 约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okayTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okayWeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelWeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTopConstraint;

- (void)setAlertController:(id)controller;
- (void)setTitle:(NSString *)title message:(NSString *)message okayTitle:(NSString *)okayTitle cancelTitle:(NSString *)cancelTitle;
@end

@implementation AuxAlertView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}
- (void)setAlertController:(id)controller {
    self.controller = controller;
}
- (void)setTitle:(NSString *)title message:(id)message okayTitle:(NSString *)okayTitle cancelTitle:(NSString *)cancelTitle {
    self.titleLabel.text = title;
    if ([message isKindOfClass:NSString.class]) {
        self.detailLabel.text = message;
    } else if([message isKindOfClass:NSAttributedString.class]) {
        self.detailLabel.attributedText = message;
    }
    
    [self.okayControl setTitle:okayTitle forState:UIControlStateNormal];
    [self.cancelControl setTitle:cancelTitle forState:UIControlStateNormal];
    
    if (title.length < 1 || [message length] < 1) {
        self.detailTopConstraint.constant = 0;
    } else {
        self.detailTopConstraint.constant = 16.0;
    }
    
    // 按钮
    if (!okayTitle && !cancelTitle) {
        [self.controlView removeConstraint:self.okayTrailingConstraint];
        [self.controlView removeConstraint:self.cancelLeadingConstraint];
        self.bottomHeightConstraint.constant = 0.0;
    } else {
        if (okayTitle && cancelTitle) {
            [self.controlView removeConstraint:self.okayTrailingConstraint];
            [self.controlView removeConstraint:self.cancelLeadingConstraint];
        } else {
            [self.controlView removeConstraint:self.okayWeightConstraint];
            [self.controlView removeConstraint:self.cancelWeightConstraint];
            if (okayTitle) {
                [self.controlView removeConstraint:self.cancelLeadingConstraint];
                self.okayTrailingConstraint.constant = 8.0f;
                self.cancelControl.hidden = YES;
            } else {
                [self.controlView removeConstraint:self.okayTrailingConstraint];
                self.cancelLeadingConstraint.constant = 8.0f;
                self.okayControl.hidden = YES;
            }
        }
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (IBAction)okayHandle:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(okayToggle:)]) {
        [self.delegate okayToggle:sender];
    }
}
- (IBAction)cancelHandle:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cancelToggle:)]) {
        [self.delegate cancelToggle:sender];
    }
}
- (IBAction)closeHandler:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(closeToggle:)]) {
        [self.delegate closeToggle:sender];
    }
}

@end

@interface AlertController ()
<
    AuxAlertViewDelegate
>
@property (weak, nonatomic) AuxAlertView *alertView;
@property (weak, nonatomic) id<AlertDelegate> delegate;
@property (copy, nonatomic) AlertOptionHandler handler;
@end

@implementation AlertController

#pragma mark
#pragma mark Init
+ (instancetype)instanceWithTitle:(NSString *)title message:(id)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle {
    return [self instanceWithTitle:title message:message delegate:delegate okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:-1];
}
+ (instancetype)instanceWithTitle:(NSString *)title message:(id)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory {
    AuxAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:nil options:nil] firstObject];
    [alertView setTitle:title message:message okayTitle:okayButtonTitle cancelTitle:cancelButtonTitle];
    AlertController *controller = [[AlertController alloc] initWithDelegate:delegate accessory:accessory];
    [alertView setController:controller]; [alertView setDelegate:controller];
    controller.alertView = alertView;
    alertView.alpha = 0.0f;
    
    return controller;
}
+ (instancetype)instanceWithTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertOptionHandler)handler {
    return [self instanceWithTitle:title message:message okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:-1 handler:handler];
}
+ (instancetype)instanceWithTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory handler:(AlertOptionHandler)handler {
    AuxAlertView *alertView = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:nil options:nil] firstObject];
    [alertView setTitle:title message:message okayTitle:okayButtonTitle cancelTitle:cancelButtonTitle];
    AlertController *controller = [[AlertController alloc] initWithHandler:handler accessory:accessory];
    [alertView setController:controller]; [alertView setDelegate:controller];
    controller.alertView = alertView;
    alertView.alpha = 0.0f;
    
    return controller;
}

/**
 * 便利弹框方法
 * 参数 title 大标题
 * 参数 message  内容
 * 参数 okayButtonTitle 蓝色按钮标题
 * 参数 cancelButtonTitle 灰色按钮标题
 * 参数 accessory 辅助信息
 * 参数 handler 回调block
 */
+ (void)alertByTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertOptionHandler)handler {
    [self alertByTitle:title message:message okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:-1 handler:handler];
}
+ (void)alertByTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory handler:(AlertOptionHandler)handler {
    AlertController *controller = [AlertController instanceWithTitle:title message:message okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:accessory handler:handler];
    [controller show];
}
/**
 * 便利弹框方法
 * 参数 title 大标题
 * 参数 message  内容
 * 参数 delegate 回调代理
 * 参数 okayButtonTitle 蓝色按钮标题
 * 参数 cancelButtonTitle 灰色按钮标题
 * 参数 accessory 辅助信息
 */
+ (void)alertByTitle:(NSString *)title message:(id)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle {
    [self alertByTitle:title message:message delegate:delegate okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:-1];
}
+ (void)alertByTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory {
    AlertController *controller = [AlertController instanceWithTitle:title message:message delegate:delegate okayButtonTitle:okayButtonTitle cancelButtonTitle:cancelButtonTitle accessory:accessory];
    [controller show];
}

/**
 * 初始化方法
 */
- (instancetype)initWithHandler:(AlertOptionHandler)handler {
    return [self initWithHandler:handler accessory:-1];
}
- (instancetype)initWithHandler:(AlertOptionHandler)handler accessory:(NSUInteger)accessory {
    if (self = [super init]) {
        _accessory = accessory;
        self.handler = handler;
    }
    return self;
}
- (instancetype)initWithDelegate:(id)delegate {
    return [self initWithDelegate:delegate accessory:-1];
}
- (instancetype)initWithDelegate:(id)delegate accessory:(NSUInteger)accessory {
    if (self = [super init]) {
        _accessory = accessory;
        self.delegate = delegate;
    }
    return self;
}

/**
 * 显示
 */
- (void)show {
    self.alertView.alpha = 0.0f;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.alertView];
    
    __weak typeof(self) wSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        wSelf.alertView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}
/**
 * 隐藏
 */
- (void)dismiss {
    __weak typeof(self) wSelf = self;
    self.alertView.alpha = 1.0f;
    [UIView animateWithDuration:0.25 animations:^{
        wSelf.alertView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [wSelf.alertView removeFromSuperview];
    }];
}

#pragma mark
#pragma mark AlertViewDelegate
- (void)closeToggle:(id)sender {
    if (self.handler) {
        self.handler(AlertActionCloseType);
    }
    [self dismiss];
}
- (void)okayToggle:(id)sender {
    if ([self.delegate respondsToSelector:@selector(alertController:okayToggle:)]) {
        [self.delegate alertController:self okayToggle:sender];
    } else if(self.handler) {
        self.handler(AlertActionOkayType);
    }
    [self dismiss];
}
- (void)cancelToggle:(id)sender {
    if ([self.delegate respondsToSelector:@selector(alertController:cancelToggle:)]) {
        [self.delegate alertController:self cancelToggle:sender];
    } else if(self.handler) {
        self.handler(AlertActionCancelType);
    }
    [self dismiss];
}


@end
