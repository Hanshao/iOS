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

@end

@implementation CircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.circleView animatedToSliceNumber:4];
//        [self.circleView animatedToSliceWeight:8.0];
//        [self.circleView animatedToSliceColor:[UIColor blackColor] slice:0];
//        [self.circleView animatedWithType:CircleAnimationRotateType];
    });
}

@end
