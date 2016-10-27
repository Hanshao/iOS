//
//  ViewController.m
//  XPickerViewDemo
//
//  Created by Shaojun Han on 9/1/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "XPickerHelper.h"

@interface ViewController ()<XPickerViewDelegate, XPickerViewDataSource>

@property (strong, nonatomic) XPickerHelper *helper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.helper = [[XPickerHelper alloc] init];
    self.helper.pickerView.dataSource = self;
    self.helper.pickerView.delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:0x21/255.0 green:0x21/255.0 blue:0x21/255.0 alpha:1.0];
    [self.helper showWithAnimated:YES];
    self.helper.pickerView.titleLabel.text = @"Hello, world";
    self.helper.pickerView.detailTitleLabel.text = @"12:00-13:00";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshHandle:)];
}

static NSInteger irand = 1;

#pragma mark
#pragma mark Event Handle
- (void)refreshHandle:(id)sender {
    irand = arc4random()%5 + 1;
    [self.helper.pickerView reloadAllComponents];
    [self.helper showWithAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSUInteger)numberOfComponentsInPikcerView:(XPickerView *)pickerView {
    return irand;
}
- (NSUInteger)pickerView:(XPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    return (irand == 5 && component == 2) || (irand == 3 && component == 1) ? 0 : 10;
    return 10;
}
- (NSString *)pickerView:(XPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @"label";
}
- (void)pickerView:(XPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"demo.picker.select.row");
}
@end
