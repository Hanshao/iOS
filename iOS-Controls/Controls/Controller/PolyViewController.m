//
//  PolyViewController.m
//  Controls
//
//  Created by Shaojun Han on 2/16/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "PolyViewController.h"
#import "HSPolyline.h"

@interface PolyViewController ()
<
    HSPolylineDataSource, HSPolylineDelegate
>

@property (strong, nonatomic) HSPolyline *polyline;

@end

@implementation PolyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.polyline = [[HSPolyline alloc] initWithFrame:CGRectMake(0, 64, size.width, 400)];
    self.polyline.dataSource = self; self.polyline.delegate = self;
    self.polyline.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.polyline];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.polyline reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.polyline reloadData];
    });
}

- (NSInteger)numberOfRowsInPolyline:(HSPolyline *)polyline {
    return 5;
}
- (NSInteger)numberOfColumnsInPolyline:(HSPolyline *)polyline {
    return 14;
}
- (NSString *)polyline:(HSPolyline *)polyline titleOfColumn:(NSInteger)column {
    return [NSString stringWithFormat:@"%d", (int)column];
}
- (CGFloat)polyline:(HSPolyline *)polyline valueOfColumn:(NSInteger)column {
    return (arc4random()%255) / 255.0;
}
- (UIColor *)polyline:(HSPolyline *)polyline colorAtStart:(NSInteger)start end:(NSInteger)end {
    return [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
}
- (CGFloat)polyline:(HSPolyline *)polyline value2OfColumn:(NSInteger)column {
    return (arc4random()%255) / 255.0;
}
- (UIColor *)polyline:(HSPolyline *)polyline color2AtStart:(NSInteger)start end:(NSInteger)end {
    return [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
}


@end
