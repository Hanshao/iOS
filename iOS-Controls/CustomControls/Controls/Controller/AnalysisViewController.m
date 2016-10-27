//
//  AnalysisViewController.m
//  Controls
//
//  Created by Shaojun Han on 2/25/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "AnalysisViewController.h"

#import "HSAnalysisView.h"

@interface AnalysisViewController ()
<
    UIScrollViewDelegate,
    HSAnalysisViewDataSource, HSAnalysisViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) HSAnalysisView *analysisView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *curveArray;

@property (assign, nonatomic) NSInteger mark;

@end

@implementation AnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.analysisView = [[HSAnalysisView alloc] init];
    [self.scrollView addSubview:self.analysisView];
    self.analysisView.backgroundColor = [UIColor whiteColor];
    [self.analysisView setColorOfDotline:[UIColor colorWithRed:0x6A/255.0 green:0x9B/255.0 blue:0xBA/255.0 alpha:1.0]];
    [self.analysisView setAutoRefreshing:YES];
    
    __weak typeof(self) wSelf = self;
    [self.analysisView addRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"auto refreshing end");
            [wSelf.analysisView endRefreshing];
            for (int i = 0; i < 5; ++ i) {
                [wSelf.dataArray insertObject:@(arc4random()%150) atIndex:0];
                [wSelf.curveArray insertObject:@(arc4random()%150) atIndex:0];
            }
            [wSelf.analysisView reloadGraphics];
        });
    }];
    self.analysisView.delegate = self;
    self.analysisView.dataSource = self;
    
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 0.5;
    
    self.dataArray = [NSMutableArray array];
    self.curveArray = [NSMutableArray array];
    for (int i = 0; i < 9; ++ i) {
        [self.dataArray addObject:@(arc4random()%150)];
        [self.curveArray addObject:@(arc4random()%150)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.analysisView.frame = self.scrollView.bounds;
    [self.analysisView reloadGraphics];
    
    // just for test
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.analysisView setColorOfDotline:[UIColor purpleColor]];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.analysisView setDotlineWeight:0.8];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.analysisView setDotlineEnable:NO];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.analysisView setAutoRefreshing:NO];
//        NSLog(@"auto refreshing no");
//    });
}

//- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.analysisView;
//}

#pragma mark
#pragma mark 代理
// UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize contentSize = scrollView.contentSize;
    CGSize size = scrollView.bounds.size;
    if (contentSize.width > size.width) {
        self.analysisView.center = CGPointMake(contentSize.width/2, contentSize.height/2);
    } else {
        self.analysisView.center = CGPointMake(size.width/2, size.height/2);
    }
}

// HSAnalysisViewDataSource
- (NSInteger)numberOfYGraphiclinesInAnalysisView:(HSAnalysisView *)analysisView {
    return 5;
}
- (NSInteger)numberOfXGraphiclinesInAnalysisView:(HSAnalysisView *)analysisView {
    return self.dataArray.count + 1;
}
- (CGFloat)yGraphicHeightInAnalysisView:(HSAnalysisView *)analysisView {
    return 32;
}
- (CGFloat)xGraphicWeightInAnalysisView:(HSAnalysisView *)analysisView {
    return [UIScreen mainScreen].bounds.size.width / 9;
}

- (UIColor *)colorOfXGraphiclineInAnalysisView:(HSAnalysisView *)analysisView {
    return [UIColor clearColor];
}
- (UIColor *)colorOfYGraphiclineInAnalysisView:(HSAnalysisView *)analysisView {
    // 0x11111133;
    return [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:0x33/255.0];
}
- (UIColor *)colorOfXGraphicAxisInAnalysisView:(HSAnalysisView *)analysisView {
    return [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:0x33/255.0];
}
- (UIColor *)colorOfYGraphicAxisInAnalysisView:(HSAnalysisView *)analysisView {
    return [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:0x33/255.0];
}
- (NSString *)analysisView:(HSAnalysisView *)analysisView yGraphicAxis:(NSInteger)yaxis {
    NSArray *axis = @[@"Perfect", @"Good", @"Ok", @"Bad"];
    if (yaxis < 0 || yaxis >= axis.count) return nil;
    return [axis objectAtIndex:yaxis];
}
- (NSString *)analysisView:(HSAnalysisView *)analysisView xGraphicAxis:(NSInteger)xaxis {
    NSInteger mark = self.mark;
    return mark == 0 ? @"23:30" : mark == 1 ? @"Mon" : @"3.2";
}
- (CGFloat)barGraphicWeightInAnalysisView:(HSAnalysisView *)analysisView {
    return 28;
}
- (CGFloat)analysisView:(HSAnalysisView *)analysisView barGraphicHeight:(NSInteger)xaxis {
    return [[self.dataArray objectAtIndex:xaxis] floatValue];
}
- (UIColor *)analysisView:(HSAnalysisView *)analysisView barGraphicColor:(NSInteger)xaxis {
    return [UIColor colorWithRed:0x61/255.0 green:0x61/255.0 blue:0x61/255.0 alpha:0x33/255.0];
}
- (CGFloat)analysisView:(HSAnalysisView *)analysisView slineGraphicHeight:(NSInteger)xaxis {
    return [[self.curveArray objectAtIndex:xaxis] floatValue];
}
- (UIColor *)slineGraphicColorInAnalysisView:(HSAnalysisView *)analysisView {
    return [UIColor colorWithRed:0x6A/255.0 green:0x9B/255.0 blue:0xBA/255.0 alpha:1.0];
}
- (void)anaysisView:(HSAnalysisView *)anaysisView didScale:(CGFloat)scale {
    NSInteger marks[] = {2, 0, 1, 2}, count = 3;
    NSInteger start = (self.mark + 1); // 1, 2, 3
    NSInteger it = scale > 1.0 ? 1 : scale < 1.0 ? -1 : 0;
    self.mark = marks[((start + it) % count)];
    NSLog(@"scale = %.0f", scale);
    [anaysisView reloadGraphics];
}

@end
