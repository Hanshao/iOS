//
//  ColorExtViewController.m
//  Helper
//
//  Created by Shaojun Han on 3/17/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ColorExtViewController.h"
#import "UIImage+Helper.h"

@interface ColorExtViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ColorExtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageView.image = [UIImage imageNamed:@"352"];
    self.imageView2.image = [UIImage imageNamed:@"352G"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIColor *destColor = [UIColor darkGrayColor];
    [UIView transitionWithView:self.imageView duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.imageView.image = [[UIImage imageNamed:@"352"] imageWithTintColor:destColor];
        self.imageView2.image = [[UIImage imageNamed:@"352G"] imageWithGradientTintColor:destColor];
    } completion:nil];
}

@end
