//
//  XPickerView.m
//  zencro
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import "XPickerView.h"

@interface AuxPickerView : UIPickerView

@property (strong, nonatomic) NSArray *auxCons;

@end

@implementation AuxPickerView

@end

@interface XPickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

// 子视图
@property (strong, nonatomic) UIView *titlesView;
@property (strong, nonatomic) UIView *pickersView;
@property (strong, nonatomic) NSMutableArray *pickers;

@end

@implementation XPickerView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubviews];
    }
    return self;
}

// 初始化
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self initPickers:self.pickers];
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self initPickers:self.pickers];
}

- (UIView *)pickersView {
    if (_pickersView) return _pickersView;
    _pickersView = [[UIView alloc] init];
    [self addSubview:_pickersView];
    // 添加约束 水平:左右距父视图都为0 垂直:顶部距离titlesView底部为0, 底部居父视图为0
    _pickersView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pickerView]-0-|" options:0 metrics:nil views:@{@"pickerView":_pickersView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_pickersView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titlesView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_pickersView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    UIView *banView = [[UIView alloc] init];
    [_pickersView addSubview:banView];
    // 添加约束 水平:左右距父视图都为0 垂直:centerY对齐 高度:42
    banView.translatesAutoresizingMaskIntoConstraints = NO;
    [_pickersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[banView]-0-|" options:0 metrics:nil views:@{@"banView":banView}]];
    [_pickersView addConstraint:[NSLayoutConstraint constraintWithItem:banView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_pickersView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [banView addConstraint:[NSLayoutConstraint constraintWithItem:banView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:42]];
    banView.backgroundColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1.0];
    
    _pickersView.clipsToBounds = YES;
    return _pickersView;
}

- (UIView *)titlesView {
    if (_titlesView) return _titlesView;
    _titlesView = [[UIView alloc] init];
    [self addSubview:_titlesView];
    // 约束 水平:左右居父视图都为0 垂直:顶部居父视图为0 高度:64
    _titlesView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titlesView]-0-|" options:0 metrics:nil views:@{@"titlesView":_titlesView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titlesView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [_titlesView addConstraint:[NSLayoutConstraint constraintWithItem:_titlesView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0.0 constant:64]];

    return _titlesView;
}

- (void)initSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.titlesView addSubview:titleLabel];
    // 约束 水平:centerX对齐父视图 垂直:top居父视图为0,并偏移10
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titlesView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.titlesView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.titlesView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titlesView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
    
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    UILabel *detailTitleLabel = [[UILabel alloc] init];
    [self.titlesView addSubview:detailTitleLabel];
    // 添加约束 水平:centerX与父视图对齐 垂直:顶部居titleLabel的底部为0
    detailTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titlesView addConstraint:[NSLayoutConstraint constraintWithItem:detailTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.titlesView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.titlesView addConstraint:[NSLayoutConstraint constraintWithItem:detailTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

    detailTitleLabel.textColor = [UIColor colorWithRed:0x1D/255.0 green:0xDE/255.0 blue:0xBE/255.0 alpha:1.0];
    detailTitleLabel.font = [UIFont systemFontOfSize:14.0];
    // 引用
    _titleLabel = titleLabel;
    _detailTitleLabel = detailTitleLabel;
}

- (NSMutableArray *)pickers {
    if (_pickers) return _pickers;
    _pickers = [NSMutableArray array];
    return _pickers;
}

- (void)initPickers:(NSMutableArray *)pickers {
    // 创建或移除
    NSUInteger num = [self.dataSource numberOfComponentsInPikcerView:self];
    NSUInteger count = pickers.count;
    if (num < count) {  // 移除
        for (int i = (int)count; i > num; -- i) {
            UIPickerView *pickerView = pickers[i - 1];
            [pickerView removeFromSuperview];
            [pickers removeObjectAtIndex:i - 1];
        }
        // 对picker view子视图进行重新布局
        [self layoutPickers:pickers];
    } else if (num > count) {   // 添加
        for (int i = (int)count; i < num; ++ i) {
            AuxPickerView *pickerView = [[AuxPickerView alloc] init];
            [pickerView setValue:[UIColor whiteColor] forKey:@"textColor"];
            pickerView.clipsToBounds = YES;
            pickerView.dataSource = self;
            pickerView.delegate = self;
            [self.pickersView addSubview:pickerView];
            [pickers addObject:pickerView];
        }
        // 对picker view子视图进行重新布局
        [self layoutPickers:pickers];
    }
}
- (void)layoutPickers:(NSArray *)pickers {
    AuxPickerView *pickerView = nil;
    for (int i = 0; i < pickers.count; ++ i) {
        AuxPickerView *curPickerView = pickers[i];
        // 通过移除再添加更新约束
        for (NSLayoutConstraint *cons in curPickerView.auxCons) {
            [self.pickersView removeConstraint:cons];
        }
        curPickerView.auxCons = nil;
        NSMutableArray *auxCons = @[].mutableCopy;
        // 约束 水平:第一个左侧居父视图为0, 最后一个右侧距父视图为0, 中间相距为0 垂直:上下距父视图为0 宽度:等宽
        curPickerView.translatesAutoresizingMaskIntoConstraints = NO;
        if (!pickerView) {
            NSLayoutConstraint *cons = [NSLayoutConstraint constraintWithItem:curPickerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pickersView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
            [self.pickersView addConstraint:cons];
            [auxCons addObject:cons];
        } else {
            NSLayoutConstraint *lcons = [NSLayoutConstraint constraintWithItem:curPickerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
            [self.pickersView addConstraint:lcons];
            [auxCons addObject:lcons];
            NSLayoutConstraint *wcons = [NSLayoutConstraint constraintWithItem:curPickerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:pickerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
            [self.pickersView addConstraint:wcons];
            [auxCons addObject:wcons];
        }
        NSArray *consArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pickerView]-0-|" options:0 metrics:nil views:@{@"pickerView":curPickerView}];
        [self.pickersView addConstraints:consArray];
        [auxCons addObjectsFromArray:consArray];
        
        pickerView = curPickerView;
        if (i == pickers.count - 1) {
            pickerView.auxCons = auxCons;
        } else {
            pickerView.auxCons = [NSArray arrayWithArray:auxCons];
        }
    }
    
    if (pickerView) {
        // 约束 最有一个右侧距父视图为0
        NSLayoutConstraint *cons = [NSLayoutConstraint constraintWithItem:pickerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.pickersView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        [self.pickersView addConstraint:cons];
        NSMutableArray *consArray = (NSMutableArray *)pickerView.auxCons;
        [consArray addObject:cons];
        pickerView.auxCons = [NSArray arrayWithArray:consArray];
    }
}

- (NSInteger)numberOfComponents {
    return self.pickers.count;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component {
    if (component < 0 || component >= self.pickers.count) return 0;
    return [self.pickers[component] numberOfRowsInComponent:0];
}

// 刷新数据
- (void)reloadAllComponents {
    for (UIPickerView *pickerView in self.pickers) {
        [pickerView reloadAllComponents];
    }
}

- (void)reloadComponent:(NSInteger)component {
    if (component < 0 || component >= self.pickers.count) return;
    [self.pickers[component] reloadComponent:0];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    if (component < 0 || component >= self.pickers.count) return;
    [self.pickers[component] selectRow:row inComponent:0 animated:animated];
}
- (NSInteger)selectedRowInComponent:(NSInteger)component {
    if (component < 0 || component >= self.pickers.count) return 0;
    return [self.pickers[component] selectedRowInComponent:0];
}

#pragma mark
#pragma mark DataSource/Delegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    component = [self.pickers indexOfObject:pickerView];
    if (NSNotFound != component && [self.dataSource respondsToSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
        return [self.dataSource pickerView:self numberOfRowsInComponent:component];
    }
    return 0;
}
// NSAttributedString和Title不能完美的实现文本的定制, 所以使用下面的代理方法
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UILabel *)reuseView {
    if (!reuseView) {
        reuseView = [[UILabel alloc] init];
        reuseView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        reuseView.textColor = [UIColor whiteColor];
        reuseView.textAlignment = NSTextAlignmentCenter;
    }
    
    component = [self.pickers indexOfObject:pickerView];
    if (NSNotFound != component && [self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        NSString *title = [self.delegate pickerView:self titleForRow:row forComponent:component];
        reuseView.text = title;
    } else {
        reuseView.text = nil;
    }
    return reuseView;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    component = [self.pickers indexOfObject:pickerView];
    if (NSNotFound != component && [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

- (void)dealloc {
    NSLog(@"picker.dealloc");
}

@end
