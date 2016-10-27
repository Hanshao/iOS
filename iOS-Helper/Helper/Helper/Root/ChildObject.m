//
//  ChildObject.m
//  Helper
//
//  Created by Shaojun Han on 7/12/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ChildObject.h"

@interface ChildObject ()

@property (strong, nonatomic) NSTimer *timer;
@end


@implementation ChildObject

@synthesize name = _name;

- (void)dealloc {
    NSLog(@"childobject.dealloc");
    [self stopTimer];
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}
- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}
- (void)tick {
    
}

@end
