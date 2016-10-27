//
//  NSObject+Extension.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (KVCSafe)

- (void)setNilValueForKey:(NSString *)key {
    // empty implementation
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    // empty implementation
}

@end
