//
//  FlatButtonViewController.m
//  Controls
//
//  Created by Shaojun Han on 3/15/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "FlatButtonViewController.h"
#import "HSFlatButton.h"

@interface FlatButtonViewController ()

@end

@implementation FlatButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(size.width/2.0 - 100, size.height/2.0 - 20, 200, 40);
    HSFlatButton *button = [[HSFlatButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor orangeColor];
    [button setColor:[UIColor whiteColor]];
    [button setWeight:4.0];
    [button setRadius:2.0];
    [self.view addSubview:button];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button animatedToType:FlatButtonAddType];
    });
}

@end
