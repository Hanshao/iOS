//
//  XTableViewProxy.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XTableViewProxy.h"
#import "XSettingItem.h"
#import "XSettingCell.h"
#import "XSettingGroup.h"

@implementation XTableViewProxy

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingsProxy.xSettingGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsProxy.xSettingGroups[section] items].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // cell的模型
    NSInteger section = indexPath.section, row = indexPath.row;
    XSettingItem *item = [self.settingsProxy.xSettingGroups[section] items][row];
    // 显示的cell
    XSettingCell *cell = nil;
    // 如果有自定义的cell类型
    if (item.cellType) {
        cell = [item.cellType settingCellWithTalbeView:tableView cellAttrs:self.settingsProxy.xCellAttrs];
    } else { // 使用默认类型
        cell = [XSettingCell settingCellWithTalbeView:tableView cellAttrs:self.settingsProxy.xCellAttrs];
    }
    // 绑定item
    cell.item = item;
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.settingsProxy.xSettingGroups[section] header];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.settingsProxy.xSettingGroups[section] footer];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    double headerHeight = [self.settingsProxy.xSettingGroups[section] headerHeight];
    return headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    double footerHeight = [self.settingsProxy.xSettingGroups[section] footerHeight];
    return footerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 回调
    NSInteger section = indexPath.section, row = indexPath.row;
    XSettingItem *item = [self.settingsProxy.xSettingGroups[section] items][row];
    // 如果有操作要执行
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone && item.optionBlock) {
        item.optionBlock([tableView cellForRowAtIndexPath:indexPath], XSettingPhaseInteractType, nil);
    }
}

@end
