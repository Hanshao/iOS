//
//  GCDTimer.h
//  BonecoAir
//
//  Created by Shaojun Han on 5/13/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 计时器类型
 */
typedef dispatch_source_t GCDTimer;

/**
 * 创建重复定时器
 * 参数 queue 定时器回调执行队列
 * 参数 timeInterval 定时时间
 * 参数 handler 定时器触发方法
 */
GCDTimer ScheduledRecurringTimer(dispatch_queue_t queue, NSTimeInterval timeinterval, dispatch_block_t handler);

/**
 * 停止定时器
 * 参数 timer 定时器
 */
void CancelTimer(GCDTimer timer);
