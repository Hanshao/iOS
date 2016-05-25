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
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImageView *lineImageView = [self findNavigationHairImageView:navigationBar];
    lineImageView.hidden = YES;
}
- (UIImageView *)findNavigationHairImageView:(UIView *)parentView {
    for (UIView *imageView in parentView.subviews) {
        if ([imageView isKindOfClass:UIImageView.class] && imageView.bounds.size.height <= 1.0)
            return (UIImageView *)imageView;
        
        UIImageView *hairImageView = [self findNavigationHairImageView:imageView];
        if (hairImageView) return hairImageView;
    }
    return nil;
}
- (void)clearNavigationBar {
    // we only transparent navigation bar and hide the seperator line, but customize the seperator line.
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = YES;
    for (UIView *subview in self.navigationController.navigationBar.subviews) {
        if ([subview isKindOfClass:UIImageView.class]) {
            subview.hidden = YES; break;
        }
    }
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
    [self presentWithViewController:[CircleViewController new]];
}
- (void)presentWithViewController:(UIViewController *)controller {
    UIViewController *rootViewCtrl = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (nil == rootViewCtrl) rootViewCtrl = self;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        rootViewCtrl.modalPresentationStyle = UIModalPresentationPopover;
    } else {
        rootViewCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    [rootViewCtrl presentViewController:controller animated:YES completion:nil];
}
@end
