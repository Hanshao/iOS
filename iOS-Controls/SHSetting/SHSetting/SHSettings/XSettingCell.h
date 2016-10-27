//
//  XSettingCell.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XSettingItem.h"
#import "XCellAttributes.h"

@class XCellAttributes;

@interface XSettingCell : UITableViewCell
// item
@property (nonatomic, strong) XSettingItem *item;
// cell属性
@property (nonatomic, strong) XCellAttributes *cellAttrs;

// 配置数据
- (void)setup;

// 应用属性
- (void)initAttrs;

// 便利构造器
+ (instancetype)settingCellWithTalbeView:(UITableView *)tableView cellAttrs:(XCellAttributes *)cellAttrs;
+ (instancetype)settingCellWithTalbeView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier cellAttrs:(XCellAttributes *)cellAttrs;

// 返加不同类型的cell的重用标识字符串
+ (NSString *)settingCellReuseIdentifier;

@end
