//
//  HSSegmentView.m
//  AirCleaner
//
//  Created by Shaojun Han on 9/8/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "HSSegmentView.h"

typedef NS_ENUM(NSInteger, HSSegmentItemState) {
    HSSegmentItemStateNormal      = 0,    // 正常状态
    HSSegmentItemStateSelected    = 1     // 选中状态
};

@class HSSegmentItem;

@protocol HSSegmentItemDelegate <NSObject>
@optional
- (void)didSelectItem:(HSSegmentItem *)item;

@end

@interface HSSegmentItem : UIView

@property (strong, nonatomic) UIImageView       *imageView;                 // 图片视图
@property (strong, nonatomic) UILabel           *textLabel;                 // 文本视图
@property (strong, nonatomic) UIImageView       *lineImageView;             // 下划线

@property (strong, nonatomic) NSString          *text;                      // 文本
@property (strong, nonatomic) UIImage           *image;                     // 图片
@property (strong, nonatomic) UIFont            *font;                      // 字体

@property (strong, nonatomic) UIColor           *selectedBackgroundColor;   // 选中时背景色
@property (strong, nonatomic) UIColor           *normalBackgroundColor;     // 正常背景色

@property (strong, nonatomic) UIColor           *normalLineColor;           // 下划线正常颜色
@property (strong, nonatomic) UIColor           *selectedLineColor;         // 选中时下划线颜色

@property (strong, nonatomic) UIColor           *selectedTextColor;         // 选中时文本颜色
@property (strong, nonatomic) UIColor           *normalTextColor;           // 正常文本颜色

@property (assign, nonatomic) HSSegmentItemState      state;
@property (weak, nonatomic) id<HSSegmentItemDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)init;

@end

@implementation HSSegmentItem

#pragma mark
#pragma mark 初始化
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    if (self = [self init]) {
        self.text = title;
        self.image = image;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.userInteractionEnabled = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.userInteractionEnabled = YES;
    
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.lineImageView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.imageView];
    [self addSubview:self.textLabel];
    [self addSubview:self.lineImageView];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                initWithTarget:self action:@selector(tapHandler:)]];
}

#pragma mark
#pragma mark 布局
- (void)layoutSubviews {
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    self.imageView.bounds = self.bounds;
    self.imageView.center = CGPointMake(width / 2, height / 2);
    
    self.textLabel.bounds = self.bounds;
    self.textLabel.center = CGPointMake(width / 2, height / 2);
    
    self.lineImageView.bounds = CGRectMake(0, 0, width, 2.0);
    self.lineImageView.center = CGPointMake(width / 2.0, height - 1.0);
}

#pragma mark
#pragma mark 点击事件处理
- (void)tapHandler:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        [self.delegate didSelectItem:self];
    }
}

#pragma mark
#pragma mark 参数
- (void)setText:(NSString *)text {
    if (_text == text) return;
    _text = text;
    self.textLabel.text = text;
}

- (void)setFont:(UIFont *)font {
    if (_font == font) return;
    _font = font;
    self.textLabel.font = font;
}

- (void)setImage:(UIImage *)image {
    if (_image == image) return;
    _image = image;
    self.imageView.image = image;
}

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    if (_normalBackgroundColor == normalBackgroundColor) return;
    _normalBackgroundColor = normalBackgroundColor;
    if (self.state == HSSegmentItemStateNormal) {
        self.imageView.backgroundColor = normalBackgroundColor;
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    if (_selectedBackgroundColor == selectedBackgroundColor) return;
    _selectedBackgroundColor = selectedBackgroundColor;
    if (self.state == HSSegmentItemStateSelected) {
        self.imageView.backgroundColor = selectedBackgroundColor;
    }
}

- (void)setNormalTextColor:(UIColor *)normalTextColor {
    if (_normalTextColor == normalTextColor) return;
    _normalTextColor = normalTextColor;
    if (self.state == HSSegmentItemStateNormal) {
        self.textLabel.textColor = normalTextColor;
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    if (_selectedTextColor == selectedTextColor) return;
    _selectedTextColor = selectedTextColor;
    if (self.state == HSSegmentItemStateSelected) {
        self.textLabel.textColor = selectedTextColor;
    }
}

- (void)setNormalLineColor:(UIColor *)normalLineColor {
    if (_normalLineColor == normalLineColor) return;
    _normalLineColor = normalLineColor;
    if (self.state == HSSegmentItemStateNormal) {
        self.lineImageView.backgroundColor = normalLineColor;
    }
}
- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    if (_selectedLineColor == selectedLineColor) return;
    _selectedLineColor = selectedLineColor;
    if (self.state == HSSegmentItemStateSelected) {
        self.lineImageView.backgroundColor = selectedLineColor;
    }
}

- (void)setState:(HSSegmentItemState)state {
    _state = state;
    if (_state == HSSegmentItemStateNormal) {
        self.textLabel.textColor = self.normalTextColor;
        self.imageView.backgroundColor = self.normalBackgroundColor;
        self.lineImageView.backgroundColor = self.normalLineColor;
    } else if (_state == HSSegmentItemStateSelected) {
        self.textLabel.textColor = self.selectedTextColor;
        self.imageView.backgroundColor = self.selectedBackgroundColor;
        self.lineImageView.backgroundColor = self.selectedLineColor;
    }
}

@end

@interface HSSegmentView () <HSSegmentItemDelegate>

@property (strong, nonatomic) NSArray   *titleArray;    // 标题数组

@end

@implementation HSSegmentView

#pragma mark
#pragma mark 初始化
- (instancetype)initWithTitles:(NSArray *)titles {
    if (self = [super init]) {
        self.titleArray = [titles copy];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // 初始化参数
    [self reloadTitles];
    self.selectedBackgroundColor = [UIColor colorWithRed:116/255.0 green:195/255.0 blue:174/255.0 alpha:1.0];
    self.normalBackgroundColor = [UIColor whiteColor];
    self.selectedTextColor = [UIColor whiteColor];
    self.normalTextColor = [UIColor grayColor];
}
- (void)setTitles:(NSArray *)titles {
    self.titleArray = [titles copy];
    [self reloadTitles];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)reloadTitles {
    NSInteger number = self.titleArray.count;
    NSArray *subArray = self.subviews;
    for (int i = (int)subArray.count - 1; i >= number; -- i) {
        [[subArray objectAtIndex:i] removeFromSuperview];
    }
    
    subArray = self.subviews;
    for (int i = subArray.count; i < number; ++ i) {
        HSSegmentItem *item = [[HSSegmentItem alloc] init];
        item.selectedBackgroundColor = self.selectedBackgroundColor;
        item.normalBackgroundColor = self.normalBackgroundColor;
        item.selectedTextColor = self.selectedTextColor;
        item.normalTextColor = self.normalTextColor;
        item.selectedLineColor = self.selectedLineColor;
        item.normalLineColor = self.normalLineColor;
        item.font = self.font;
        item.delegate = self;
        [self addSubview:item];
    }
    
    if (number < 1) return;
    
    subArray = self.subviews;
    for (int i = 0; i < subArray.count; ++ i) {
        NSString *title = [self.titleArray objectAtIndex:i];
        HSSegmentItem *item = [subArray objectAtIndex:i];
        item.text = title;
    }
}

#pragma mark
#pragma mark 布局
- (void)layoutSubviews {
    CGFloat width = self.subviews.count > 0 ? self.bounds.size.width / self.subviews.count : 0;
    CGFloat height = self.bounds.size.height, x = 0;
    for (UIView *view in self.subviews) {
        view.bounds = CGRectMake(0, 0, width, height);
        view.center = CGPointMake(width / 2 + x , height / 2);
        x += width;
    }
}

#pragma mark
#pragma mark 代理
- (void)didSelectItem:(HSSegmentItem *)item {
    NSInteger selectedIndex = [self.subviews indexOfObject:item];
    self.selectedIndex = selectedIndex;
    if ([self.delegate respondsToSelector:@selector(segmentView:itemSelectedAtIndex:)]) {
        [self.delegate segmentView:self itemSelectedAtIndex:self.selectedIndex];
    }
}

#pragma mark
#pragma mark 参数
- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    if (_normalBackgroundColor == normalBackgroundColor) return;
    _normalBackgroundColor = normalBackgroundColor;
    for (HSSegmentItem *item in self.subviews) {
        item.normalBackgroundColor = normalBackgroundColor;
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    if (_selectedBackgroundColor == selectedBackgroundColor) return;
    _selectedBackgroundColor = selectedBackgroundColor;
    for (HSSegmentItem *item in self.subviews) {
        item.selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (void)setNormalTextColor:(UIColor *)normalTextColor {
    if (_normalTextColor == normalTextColor) return;
    _normalTextColor = normalTextColor;
    for (HSSegmentItem *item in self.subviews) {
        item.normalTextColor = normalTextColor;
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    if (_selectedTextColor == selectedTextColor) return;
    _selectedTextColor = selectedTextColor;
    for (HSSegmentItem *item in self.subviews) {
        item.selectedTextColor = selectedTextColor;
    }
}

- (void)setNormalLineColor:(UIColor *)normalLineColor {
    if (_normalLineColor == normalLineColor) return;
    _normalLineColor = normalLineColor;
    for (HSSegmentItem *item in self.subviews) {
        item.normalLineColor = normalLineColor;
    }
}
- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    if (_selectedLineColor == selectedLineColor) return;
    _selectedLineColor = selectedLineColor;
    for (HSSegmentItem *item in self.subviews) {
        item.selectedLineColor = selectedLineColor;
    }
}

- (void)setFont:(UIFont *)font {
    if (_font == font) return;
    _font = font;
    for (HSSegmentItem *item in self.subviews) {
        item.font = font;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= self.subviews.count || selectedIndex < 0) return;
    HSSegmentItem *oldItem = [self.subviews objectAtIndex:_selectedIndex];
    oldItem.state = HSSegmentItemStateNormal;
    HSSegmentItem *item = [self.subviews objectAtIndex:selectedIndex];
    item.state = HSSegmentItemStateSelected;
    _selectedIndex = selectedIndex;
}

#pragma mark
#pragma mark 配置
- (void)setImage:(UIImage *)image forItemAtIndex:(NSInteger)index {
    if (index >= self.subviews.count || index < 0) return;
    HSSegmentItem *item = [self.subviews objectAtIndex:index];
    item.image = image;
}
- (UIImage *)imageOfItemAtIndex:(NSInteger)index {
    if (index >= self.subviews.count || index < 0) return nil;
    HSSegmentItem *item = [self.subviews objectAtIndex:index];
    return item.image;
}
- (void)setTitle:(NSString *)title forItemAtIndex:(NSInteger)index {
    if (index >= self.subviews.count || index < 0) return;
    HSSegmentItem *item = [self.subviews objectAtIndex:index];
    item.text = title;
}
- (NSString *)titleOfItemAtIndex:(NSInteger)index {
    if (index >= self.subviews.count || index < 0) return nil;
    HSSegmentItem *item = [self.subviews objectAtIndex:index];
    return item.text;
}

@end
