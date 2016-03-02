//
//  SegmentViewController.m
//  Controls
//
//  Created by Shaojun Han on 2/1/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "SegmentViewController.h"
#import "HSSegmentView.h"

@interface SegmentViewController ()
<
    HSSegmentViewDelegate
>

@property (weak, nonatomic) IBOutlet HSSegmentView *segmentView1;
@property (weak, nonatomic) IBOutlet UIView *segmentContentView;

@end

@implementation SegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.segmentView1 setTitles:@[@"年", @"月", @"日"]];
    self.segmentView1.selectedLineColor = [UIColor blueColor];
    self.segmentView1.selectedTextColor = [UIColor blueColor];
    self.segmentView1.delegate = self;
    self.segmentView1.selectedIndex = 0;
    
    HSSegmentView *segmentView2 = [[HSSegmentView alloc] initWithTitles:@[@"类型1", @"类型2"]];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self.segmentContentView addSubview:segmentView2];
    segmentView2.delegate = self;
    segmentView2.selectedIndex = 1;
    segmentView2.frame = CGRectMake(0, 0, width, self.segmentContentView.bounds.size.height);
}

- (void)segmentView:(HSSegmentView *)view itemSelectedAtIndex:(NSInteger)index {
    if (view == self.segmentView1) {
        NSLog(@"%d", (int)index);
    } else {
        NSLog(@"%@", [view titleForItemAtIndex:index]);
    }
}

@end
