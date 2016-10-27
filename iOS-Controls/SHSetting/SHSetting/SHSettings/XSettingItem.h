//
//  XSettingItem.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XSettingPhaseInitType = 1,
    XSettingPhaseLayoutType,
    XSettingPhaseInteractType
} XSettingPhaseType;

@class XSettingItem;

typedef void (^SettingItemOptionBlock)(UITableViewCell *cell, XSettingPhaseType phaseType, id bindValue);
typedef void (^SettingItemSetupBlock)(UITableViewCell *cell, XSettingItem *item);

// XSettingCell的模型
@interface XSettingItem : NSObject
// 图标
@property (strong, nonatomic) NSString *icon;
// 标题
@property (strong, nonatomic) NSString *title;
// 子标题
@property (strong, nonatomic) NSString *subTitle;
// accessory类型, 默认为0即没有辅助类型
@property (assign, nonatomic) NSInteger accessoryType;

// 位置 对于特殊的分割线需要位置信息
@property (assign, nonatomic) BOOL front;
@property (assign, nonatomic) BOOL trail;

// 关联的cell类型
@property (assign, nonatomic) Class cellType;

// 回调block
@property (copy, nonatomic) SettingItemOptionBlock optionBlock;
@property (copy, nonatomic) SettingItemSetupBlock setupBlock;

// 构造方法
- (instancetype)initWithKeyedValues:(NSDictionary *)keyedValues;
+ (instancetype)settingItemWithKeyedValues:(NSDictionary *)keyedValues;
+ (NSMutableArray *)settingItemsWithArray:(NSArray *)values;

@end
