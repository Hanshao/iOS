//
//  XSettingItem.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "XSettingModel.h"

@implementation XSettingModel

- (instancetype)initWithKeyedValues:(NSDictionary *)keyedValues {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:keyedValues];
    }
    return self;
}

+ (instancetype)settingItemWithKeyedValues:(NSDictionary *)keyedValues {
    return [[self alloc] initWithKeyedValues:keyedValues];
}

+ (NSMutableArray *)settingItemsWithArray:(NSArray *)values {
    NSUInteger count = values.count;
    NSMutableArray *outArray = [NSMutableArray array];
    [values enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        // 创建到一个可变数组
        NSMutableDictionary *keyedValues = [item mutableCopy];
        Class itemType = [self class];
        // 如果是自定型子类
        if (item[@"itemType"]) {
            // 从可变数组中删除这个key,因为要实例化的类没有这个key会报错
            itemType = item[@"itemType"];
            [keyedValues removeObjectForKey:@"itemType"];
        }
        // 判断是否是第一个item,作为标记
        if (idx == 0 && nil == [keyedValues objectForKey:@"front"]) {
            [keyedValues setObject:@(YES) forKey:@"front"];
        }
        if (idx == count && nil == [keyedValues objectForKey:@"front"]) {
            [keyedValues setObject:@(YES) forKey:@"trail"];
        }
        // 创建实例
        XSettingModel *instance = [[itemType alloc] initWithKeyedValues:keyedValues];
        [outArray addObject:instance];
    }];
    
    NSLog(@"xsetting.item.values = %@", values);
    return outArray;
}

@end
