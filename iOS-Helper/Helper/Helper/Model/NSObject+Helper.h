//
//  NSObject+Helper.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 拓展(NSObject)
 * 1. KVC保护
 */
@interface NSObject (KVCSafe)
// KVC保护
- (void)setNilValueForKey:(NSString *)key;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end
