//
//  ViewController.m
//  CustomAlertView
//
//  Created by Shaojun Han on 5/25/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "AlertController.h"
#import "AlertHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okayHandle:(id)sender {
    [AlertController alertByTitle:@"这是标题" message:@"这是内容, 内容较多的情况下回自动换行, 高度自动调整" okayButtonTitle:@"确定" cancelButtonTitle:nil handler:^(AlertActionType actionType) {
        NSLog(@"block 形式 action = %lu", actionType);
    }];
}
- (IBAction)cancelHandle:(id)sender {
    [AlertController alertByTitle:@"这是标题" message:@"这是内容" delegate:nil okayButtonTitle:nil cancelButtonTitle:@"取消"];
}
- (IBAction)noneHandle:(id)sender {
    [AlertController alertByTitle:@"这是标题" message:@"这是内容" delegate:nil okayButtonTitle:nil cancelButtonTitle:nil];
}
- (IBAction)allHandle:(id)sender {
    [AlertController alertByTitle:@"这是标题" message:@"这是内容" delegate:nil okayButtonTitle:@"确定" cancelButtonTitle:@"取消"];
}
- (IBAction)vflVerHandle:(id)sender {
    [AlertHelper alertWithTitle:@"Hello" message:@"你好" actionHandler:^(AlertActionType actionType) {
        
    }];
}


@end
