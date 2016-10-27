//
//  XSettingGroup.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XSettingGroup.h"
#import "XSettingItem.h"

@implementation XSettingGroup

// 构造方法
- (instancetype)initWithKeyedValues:(NSDictionary *)keyedValues {
    if (self = [super init]) {
        self.header = keyedValues[@"header"];
        self.footer = keyedValues[@"footer"];
        
        self.headerHeight = 24;
        self.footerHeight = 24;
        if ([keyedValues objectForKey:@"headerHeight"]) {
            self.headerHeight = [[keyedValues objectForKey:@"headerHeight"] doubleValue];
        }
        if ([keyedValues objectForKey:@"footerHeight"]) {
            self.footerHeight = [[keyedValues objectForKey:@"footerHeight"] doubleValue];
        }
        
        NSArray *values = keyedValues[@"items"];
        NSLog(@"xsetting.group.init.keyedvalues = %@", keyedValues);
        self.items = [XSettingItem settingItemsWithArray:values];
    }
    return self;
}
+ (instancetype)settingGroupWithKeyedValues:(NSDictionary *)keyedValues {
    return [[self alloc] initWithKeyedValues:keyedValues];
}
+ (NSMutableArray *)settingGroupsWithArray:(NSArray *)values {
    NSMutableArray *outArray = [NSMutableArray array];
    [values enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        [outArray addObject:[[self alloc] initWithKeyedValues:item]];
    }];
    NSLog(@"xsetting.group.outArray = %@", outArray);
    return outArray;
}

@end
