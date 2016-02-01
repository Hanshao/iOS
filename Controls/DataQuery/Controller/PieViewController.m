//
//  MyViewController.m
//  YiMaoAgent
//
//  Created by Shaojun Han on 1/25/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "PieViewController.h"
#import "XYPieChart.h"

@interface PieViewController ()
<
    XYPieChartDataSource, XYPieChartDelegate
>

@property (weak, nonatomic) IBOutlet UIView *chartContentView;
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;

@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *unacceptTitleLabel;

@property (strong, nonatomic) NSMutableArray *slices;
@property (strong, nonatomic) NSArray *sliceColors;

@end

@implementation PieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.slices = [NSMutableArray array];
    for(int i = 0; i < 5; i ++) {
        NSNumber *one = [NSNumber numberWithInt:rand()%60+20];
        [self.slices addObject:one];
    }

    [self.pieChartView setDelegate:self];
    [self.pieChartView setDataSource:self];
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setShowPercentage:YES];
    [self.pieChartView setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChartView setPieCenter:CGPointMake(240, 240)];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1],nil];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat width = self.pieChartView.bounds.size.width, height = self.pieChartView.bounds.size.height;
    [self.pieChartView setPieCenter:CGPointMake(width/2, height/2)];
    [self.pieChartView reloadData];
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will select slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will deselect slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did deselect slice at index %d", (int)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did select slice at index %d", (int)index);
}


@end
