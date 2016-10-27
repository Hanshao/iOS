//
//  XSettingGroup.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

// 分组信息
@interface XSettingGroup : NSObject

@property (nonatomic, copy) NSString *header;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *footer;
@property (assign, nonatomic) double headerHeight;
@property (assign, nonatomic) double footerHeight;

// 构造方法
- (instancetype)initWithKeyedValues:(NSDictionary *)keyedValues;
+ (instancetype)settingGroupWithKeyedValues:(NSDictionary *)keyedValues;
+ (NSMutableArray *)settingGroupsWithArray:(NSArray *)values;

@end
