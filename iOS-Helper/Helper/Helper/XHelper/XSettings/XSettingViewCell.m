//
//  XSettingCell.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XSettingViewCell.h"

@interface XSettingViewCell ()
// 自定义分割线
@property (strong, nonatomic) UIView *bottomLineView;

@end

@implementation XSettingViewCell

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)initAttrs {
    XCellAttributes *cellAttrs = self.cellAttrs;
    CGFloat textMaxSize = cellAttrs.cellTextMaxSize;

    self.textLabel.font = [UIFont systemFontOfSize:(textMaxSize > 1.f ? textMaxSize : 13)];
    self.textLabel.textColor = cellAttrs.cellTitleTextColor ? cellAttrs.cellTitleTextColor : [UIColor blackColor];
    
    self.detailTextLabel.font = [UIFont systemFontOfSize:(textMaxSize > 1.0 ? textMaxSize : 13)];
    self.detailTextLabel.textColor = cellAttrs.cellDetailTextColor ? cellAttrs.cellDetailTextColor : [UIColor blackColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setupBottomline];
}

- (UIView *)bottomLineView {
    if (_bottomLineView == nil) {
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomLineView];
        bottomLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottomLineView]-0-|" options:0 metrics:nil views:@{@"bottomLineView":bottomLineView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLineView(1)]-0-|" options:0 metrics:nil views:@{@"bottomLineView":bottomLineView}]];
        _bottomLineView = bottomLineView;
    }
    return _bottomLineView;
}

// 返加不同类型的cell的重用标识字符串
+ (NSString *)settingCellReuseIdentifier {
    return @"setting_cell_reuse_identifier";
}

+ (instancetype)settingCellWithTalbeView:(UITableView *)tableView cellAttrs:(XCellAttributes *)cellAttrs {
    NSString *reuseID = [self settingCellReuseIdentifier];
    return [self settingCellWithTalbeView:tableView reuseIdentifier:reuseID cellAttrs:cellAttrs];
}
+ (instancetype)settingCellWithTalbeView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier cellAttrs:(XCellAttributes *)cellAttrs {
    XSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.cellAttrs = cellAttrs;
        [cell initAttrs];
        // 设置cell属性
        if (cellAttrs.cellBackgroundColor)
            cell.backgroundColor = cellAttrs.cellBackgroundColor;
        if (cellAttrs.cellSelectedBackgroundColor){
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = cellAttrs.cellSelectedBackgroundColor;
            cell.selectedBackgroundView = view;
        }
        if (cellAttrs.cellBackgroundView) {
            cell.backgroundView = cellAttrs.cellBackgroundView;
        }
        if (cellAttrs.cellSelectedBackgroundView) {
            cell.selectedBackgroundView = cellAttrs.cellSelectedBackgroundView;
        }
    }
    
    return cell;
}

- (void)setItem:(XSettingModel *)item {
    _item = item;
    // 配置Cell
    if (item.setupBlock) {
        item.setupBlock(self, item);
    } else {
        [self setupWithModel:item];
        // 执行初始化
        if (item.optionBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                item.optionBlock(self, XSettingPhaseInitType, nil);
            });
        }
    }
}
// 配置
- (void)setupWithModel:(XSettingModel *)item {
    // 标题
    self.textLabel.hidden = NO;
    self.textLabel.text = item.title;
    // 子标题
    self.detailTextLabel.hidden = NO;
    self.detailTextLabel.text = item.subTitle;
    // 有的设置栏没有图标
    if (item.icon.length) {
        self.imageView.image = [UIImage imageNamed:item.icon];
    }
    // 设置辅助视图类型
    self.accessoryType = item.accessoryType;
    self.selectionStyle = 1;
}

- (void)setupBottomline {
    if (self.cellAttrs.cellFullLineEnable) {
        UIColor *bottomLineColor = [UIColor clearColor];
        if (self.isSelected) {
            bottomLineColor = [UIColor clearColor];
        } else if (self.cellAttrs.cellBottomLineColor) {   // 设置线条颜色
            bottomLineColor = self.cellAttrs.cellBottomLineColor;
        } else if (self.superview.backgroundColor) {
            bottomLineColor = self.superview.backgroundColor;
        }
        self.bottomLineView.backgroundColor = bottomLineColor;
        if (self.cellAttrs.disableBottomLine && self.item.trail) {
            self.bottomLineView.hidden = YES;
        } else {
            self.bottomLineView.hidden = NO;
        }
    } else {
        // 调整系统的下划线
        NSUInteger count = self.subviews.count;
        for (int i = 0; i < count; ++ i) {
            UIView *subView = self.subviews[i];
            if ([subView isMemberOfClass:NSClassFromString(@"_UITableViewCellSeparatorView")]) {
                // 是否隐藏bottomLine
                if (self.cellAttrs.disableBottomLine && self.item.trail) {
                    subView.hidden = YES;
                } else {
                    subView.hidden = NO;
                }
                // 设置线条颜色
                if (self.cellAttrs.cellBottomLineColor) {
                    subView.backgroundColor = self.cellAttrs.cellBottomLineColor;
                }
            }
        }
    }
}

@end
