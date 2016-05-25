//
//  MainViewController.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "MainViewController.h"
#import "DateExtViewController.h"
#import "ColorExtViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) NSArray *actionArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionArray = @[@"enterDateExtPage"];
}

#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.actionArray.count;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger row = indexPath.row;
//    NSString *action = [self.actionArray objectAtIndex:row];
//    [self performSelector:NSSelectorFromString(action) withObject:nil];
//}

- (void)enterDateExtPage {
    [self.navigationController pushViewController:[DateExtViewController new] animated:YES];
}
- (void)enterColorExtPage {
    [self.navigationController pushViewController:[ColorExtViewController new] animated:YES];
}

@end
