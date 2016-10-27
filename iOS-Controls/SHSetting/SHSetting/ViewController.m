//
//  ViewController.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "SettingViewController.h"
#import <Foundation/Foundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)settingsHandle:(id)sender {
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

@end
