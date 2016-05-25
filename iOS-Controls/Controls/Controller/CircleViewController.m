//
//  CircleViewController.m
//  Controls
//
//  Created by Shaojun Han on 3/17/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "CircleViewController.h"
#import "HSCircleView.h"

@interface CircleViewController ()

@property (weak, nonatomic) IBOutlet HSCircleView *circleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleAspectConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

static NSInteger tick = 0;

@implementation CircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:2.8 animations:^{
        self.circleAspectConstraint.constant = -200;
        [self.view layoutIfNeeded];
    }];
    static NSTimer *timer = nil; tick = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.circleView animatedToSliceColor:[UIColor blackColor] slice:0];
//        [self.circleView animatedToSliceNumber:4];
//        [self.circleView animatedToSliceWeight:24.0];
//        [self.circleView animatedWithType:CircleAnimationUnfoldType];
//    });
}
- (void)timerHandle:(NSTimer *)timer {
//    CALayer *layer = [self.circleView.layer presentationLayer];
    NSLog(@"circle frame = %@", NSStringFromCGRect(self.circleView.frame));
    ++ tick; if (tick > 100) [timer invalidate];
}

@end
