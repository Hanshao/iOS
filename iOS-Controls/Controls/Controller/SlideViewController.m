//
//  ViewController.m
//  SlideShow
//
//  Created by Shaojun Han on 8/21/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "SlideViewController.h"
#import "SlideShowView.h"

@interface SlideViewController ()
<
    SlideShowViewDelegate
>
@property (strong, nonatomic) IBOutlet SlideShowView *slideShowView;
@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation SlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.slideShowView.delegate = self;
    self.dataArray = @[@"healthy_life_pic1.jpg", @"healthy_life_pic2.jpg", @"healthy_life_pic3.jpg"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSlides {
    return 2;
}
- (UIImage *)slideShowView:(SlideShowView *)ssView imageOfSlide:(NSInteger)index {
    return [UIImage imageNamed:self.dataArray[index]];
}
- (void)slideShowView:(SlideShowView *)ssView didSelectSlide:(NSInteger)index {
    NSLog(@"select slide at index %d", (int)index);
}
- (IBAction)displayModeHandle:(id)sender {
    self.slideShowView.displayMode = UIViewContentModeCenter;
}
- (IBAction)timeIntervalHandle:(UIButton *)sender {
    NSTimeInterval interval = arc4random() % 10 + 0.5;
    self.slideShowView.autoSlideTimeInterval = interval;
    NSString *title = [NSString stringWithFormat:@"时间间隔%.2f秒", interval];
    [sender setTitle:title forState:UIControlStateNormal];
}
- (IBAction)frameHandle:(id)sender {
    CGPoint center = self.slideShowView.center;
    CGFloat weight = self.view.bounds.size.width;
    CGRect rect = CGRectMake(0, 0, arc4random() % (int)weight, arc4random() % 201 + 80);
    if (rect.size.width < 80) rect.size.width = 80;
    self.slideShowView.bounds = rect;
    self.slideShowView.center = center;
}
- (IBAction)slideHandle:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.slideShowView fire];
    } else {
        [self.slideShowView stop];
    }
}

@end
