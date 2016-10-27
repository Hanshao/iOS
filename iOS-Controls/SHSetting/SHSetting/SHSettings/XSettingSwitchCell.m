//
//  XSettingSwithCell.m
//  XSetting
//
//  Created by Shaojun Han on 8/27/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XSettingSwitchCell.h"

@implementation XSettingSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    UIButton *switchView = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:switchView];
    [switchView setImage:[UIImage imageNamed:@"icon_open"] forState:UIControlStateNormal];
    [switchView setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateSelected];
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[switchView]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"switchView":switchView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[switchView]-16-|" options:0 metrics:nil views:@{@"switchView":switchView}]];
    [switchView addTarget:self action:@selector(switchStateChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.switchView = switchView;
}

// 返加不同类型的cell的重用标识字符串
+ (NSString *)settingCellReuseIdentifier {
    return @"setting_switch_cell_reuse_id";
}

- (void)setup {
    XSettingItem *item = self.item;
    // 标题
    self.textLabel.hidden = NO;
    self.textLabel.text = item.title;
    // 子标题
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
    // 有的设置栏没有图标
    if (item.icon.length) {
        self.imageView.image = [UIImage imageNamed:item.icon];
    }
    // 设置辅助视图类型
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)switchStateChanged:(UIButton *)switchView {
    if (self.item.optionBlock) {
        switchView.selected = !switchView.selected;
        self.item.optionBlock(self, XSettingPhaseInteractType, @(switchView.selected));
    }
}

@end
