//
//  XSettings.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIViewController+XSettings.h"
#import "XCellAttributes.h"
#import "XTableViewDataSource.h"
#import "XSettingGroup.h"
#import "XSettingItem.h"
#import "XSettingCell.h"
#import "XSettingSwitchCell.h"

// 组信息
/**
 *  分组头信息
 */
extern NSString * const XSettingGroupHeaderKey;
/**
 *  分组头高度
 */
extern NSString * const XSettingGroupHeaderHeightKey;
/**
 *  每一组的多个Cell
 */
extern NSString * const XSettingGroupItemsKey;
/**
 *  分组页脚信息
 */
extern NSString * const XSettingGroupFooterKey;
/**
 *  分组页脚高度
 */
extern NSString * const XSettingGroupFooterHeightKey;

// 每个Item的可用配置
/**
 *  Cell的模型类型
 */
extern NSString * const XSettingItemTypeKey;
/**
 *  Cell图标
 */
extern NSString * const XSettingItemIconKey;
/**
 *  Cell标题
 */
extern NSString * const XSettingItemTitleKey;
/**
 * Cell子标题
 */
extern NSString * const XSettingItemSubTitleKey;
/**
 * Cell的Accessory类型
 */
extern NSString * const XSettingItemAccessoryTypeKey;
/**
 *  Cell的类型
 */
extern NSString * const XSettingItemCellTypeKey;
/**
 * Cell配置时回调
 */
extern NSString * const XSettingItemSetupBlockKey;
/**
 *  Cell点击后的执行代码块
 */
extern NSString * const XSettingItemOptionBlockKey;
