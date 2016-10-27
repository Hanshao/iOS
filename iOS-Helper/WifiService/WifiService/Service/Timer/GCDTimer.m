//
//  GCDTimer.m
//  BonecoAir
//
//  Created by Shaojun Han on 5/13/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "GCDTimer.h"

// 创建计时器
GCDTimer ScheduledRecurringTimer(dispatch_queue_t queue, NSTimeInterval timeinterval, dispatch_block_t handler) {
    if (queue == nil) queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, timeinterval * NSEC_PER_SEC), timeinterval * NSEC_PER_SEC, 0.2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{ if(handler) handler(); });
    dispatch_resume(timer);
    return timer;
}
// 停止计时器
void CancelTimer(GCDTimer timer) {
    if (timer) dispatch_source_cancel(timer);
}