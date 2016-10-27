//
//  AlertHelper.h
//  zencro
//
//  Created by Shaojun Han on 8/25/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import <Foundation/Foundation.h>

// 0 - cancel, 1 - ok
typedef void (^AlertActionHandler)(NSInteger btnIndex);

@interface AlertHelper : NSObject

/**
 * 弹框
 */
+ (instancetype)alertWithTitle:(NSString *)title message:(id)message actionHandler:(AlertActionHandler)actionHandler;

@end
