//
//  ViewController.m
//  SlideShow
//
//  Created by Shaojun Han on 8/21/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "SlideViewController.h"
#import "SlideShowView.h"
#import "HSSlideShowView.h"

@interface SlideViewController ()
<
    SlideShowViewDelegate
>
@property (strong, nonatomic) IBOutlet SlideShowView *slideShowView;
@property (weak, nonatomic) IBOutlet HSSlideShowView *cycleShowView;

@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation SlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.slideShowView.delegate = self;
    self.dataArray = @[@"healthy_life_pic1.jpg", @"healthy_life_pic2.jpg", @"healthy_life_pic3.jpg"];
    NSArray *webArray = @[@"http://yun.yimaokeji.com/UploadedFile/241ac142-8fe3-42ef-8e5d-719dd9c562b9.jpg",
                          @"http://yun.yimaokeji.com/UploadedFile/0447f502-436e-47e0-a634-9b49441ab38e.jpg",
                          @"http://yun.yimaokeji.com/UploadedFile/47df4a24-23ae-4ce2-bab6-8052f8fac08a.jpg",
                          @"http://yun.yimaokeji.com/UploadedFile/a923f426-7159-4e9d-b943-84a10e9bddf0.jpg"];
    [self.cycleShowView setWebArray:webArray placeHolder:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cycleShowView reloadAllSlides];
}

- (NSInteger)numberOfSlides {
    return 2;
}
- (UIImage *)slideShowView:(SlideShowView *)ssView imageOfSlide:(NSInteger)index {
    return [UIImage imageNamed:self.dataArray[index]];
}
//- (UIImageView *)slideShowView:(SlideShowView *)slideShowView imageViewOfSlide:(NSInteger)slide reuseImageView:(UIImageView *)imageView {
//    imageView = [[UIImageView alloc] init];
//    NSString *imageName = [self.dataArray objectAtIndex:slide];
//    imageView.image = [UIImage imageNamed:imageName];
//    return imageView;
//}
- (void)slideShowView:(SlideShowView *)ssView didSelectSlide:(NSInteger)index {
    NSLog(@"select slide at index %d", (int)index);
}
- (IBAction)displayModeHandle:(id)sender {
    self.slideShowView.cotentDisplayMode = UIViewContentModeCenter;
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
