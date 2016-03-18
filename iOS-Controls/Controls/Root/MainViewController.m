//
//  MainViewController.m
//  Controls
//
//  Created by Shaojun Han on 2/1/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "MainViewController.h"
#import "PieViewController.h"
#import "DatePickerController.h"
#import "SegmentViewController.h"
#import "AnalysisViewController.h"
#import "ScanViewController.h"
#import "FlatButtonViewController.h"
#import "SlideViewController.h"
#import "CircleViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) NSMutableArray *actionArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionArray = [NSMutableArray array];
    [self.actionArray addObject:@[@"enterPiePage", @"enterDatePickerPage", @"enterSegmentPage", @"enterAnalysisPage", @"enterQRScanPage", @"enterFlatButtonPage", @"enterSlidePage", @"enterCirclePage"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *actions = [self.actionArray objectAtIndex:indexPath.section];
    NSString *action = [actions objectAtIndex:indexPath.row];
    [self performSelectorOnMainThread:NSSelectorFromString(action) withObject:nil waitUntilDone:NO];
}

- (void)enterPiePage {
    [self.navigationController pushViewController:[PieViewController new] animated:YES];
}
- (void)enterDatePickerPage {
    [self.navigationController pushViewController:[DatePickerController new] animated:YES];
}
- (void)enterSegmentPage {
    [self.navigationController pushViewController:[SegmentViewController new] animated:YES];
}
- (void)enterAnalysisPage {
    [self.navigationController pushViewController:[AnalysisViewController new] animated:YES];
}
- (void)enterQRScanPage {
    [self.navigationController presentViewController:[ScanViewController new] animated:YES completion:nil];
}
- (void)enterFlatButtonPage {
    [self.navigationController pushViewController:[FlatButtonViewController new] animated:YES];
}
- (void)enterSlidePage {
    [self.navigationController pushViewController:[SlideViewController new] animated:YES];
}
- (void)enterCirclePage {
    [self.navigationController pushViewController:[CircleViewController new] animated:YES];
}
@end
