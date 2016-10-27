//
//  ViewController.m
//  SHAnalysisView
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "SHAnalysisView.h"

@interface ViewController ()
<
    SHAnalysisViewDelegate
>
// 统计图
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet SHAnalysisView *analysisView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.analysisView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    { // 阴影
        UIImageView *imageView = self.imageView;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOpacity = 1.0;
        imageView.layer.shadowRadius = 3.0;
        imageView.layer.shadowOffset = CGSizeMake(0, 0);
        
        CGFloat x = imageView.bounds.origin.x, y = imageView.bounds.origin.y;
        CGFloat width = imageView.bounds.size.width, height = imageView.bounds.size.height;
        
        CGPoint points[][2] = {
            {CGPointMake(x + width/2, y - 8), CGPointMake(x + width, y)},
            {CGPointMake(x + width + 8, y + height/2), CGPointMake(x + width, y + height)},
            {CGPointMake(x + width/2, y + height + 8), CGPointMake(x, y + height)},
            {CGPointMake(x - 8, y + height/2), CGPointMake(x, y)}
        };
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(x, y)];
        [path addQuadCurveToPoint:points[0][1] controlPoint:points[0][0]];
        [path addQuadCurveToPoint:points[1][1] controlPoint:points[1][0]];
        [path addQuadCurveToPoint:points[2][1] controlPoint:points[2][0]];
        [path addQuadCurveToPoint:points[3][1] controlPoint:points[3][0]];
        imageView.layer.shadowPath = path.CGPath;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark SHAnalysisViewDelegate
// 横线数
- (CGFloat)rowHeightInAnalysisView:(SHAnalysisView *)analysisView {
    return 32;
}
- (NSInteger)numbersOfRowlineInAnalysisView:(SHAnalysisView *)analysisView {
    return 6;
}
- (NSString *)titleInAnalysisView:(SHAnalysisView *)analysisView forRowline:(NSInteger)rowline {
    return @"100";
}

// 纵线数
- (CGFloat)columnWidthInAnalysisView:(SHAnalysisView *)analysisView {
    return 48;
}
- (NSInteger)numbersOfColumnlineInAnalysisView:(SHAnalysisView *)analysisView {
    return 10;
}
- (NSString *)titleInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)columnline {
    return @"12月";
}
- (CGFloat)valueHeightInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)columnline {
    return arc4random() % 200;
}
- (UIView *)accessoryViewInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)column {
    UIButton *accessory = (UIButton *)[analysisView dequeueAccessoryViewForColumnline:column];
    if (!accessory) {
        accessory = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessory setTitle:@(column).stringValue forState:UIControlStateSelected];
        accessory.titleLabel.font = [UIFont systemFontOfSize:10.0];
        accessory.backgroundColor = [UIColor clearColor];
        accessory.frame = CGRectMake(0, 0, 10, 10);
        accessory.layer.cornerRadius = 5.0;
        accessory.layer.masksToBounds = YES;
        accessory.tag = column;
        [accessory addTarget:self action:@selector(accessoryHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return accessory;
}
- (void)accessoryHandle:(UIButton *)sender {
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
    }
    sender.selected = YES;
    self.selectedButton = sender;
    
    NSInteger column = sender.tag;
    [self.analysisView showDotline:YES atColumnline:column];
}

@end
