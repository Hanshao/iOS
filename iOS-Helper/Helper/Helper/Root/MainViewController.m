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
#import "UIViewController+Helper.h"
#import "UIImage+Helper.h"

#import "Helper-Swift.h"

@interface MainViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSArray *actionArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actionArray = @[@"enterDateExtPage", @"enterImagePickerPage", @"enterColorExtPage"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //        MyImagePickerController *picker = [[MyImagePickerController alloc] init];
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        picker.allowsEditing = YES;
//        [self presentViewController:picker animated:YES completion:nil];
//    });
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"navigation.willshow");
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addSomeElements:viewController];
    });
}

//
- (UIView *)findView:(UIView *)view name:(NSString *)name {
    Class cls = view.class;
    if ([name isEqualToString:NSStringFromClass(cls)]) {
        return view;
    }
    for (UIView *subview in view.subviews) {
        Class cls = subview.class;
        if ([name isEqualToString:NSStringFromClass(cls)]) {
            return subview;
        }
    }
    return nil;
}
- (UIButton *)findView:(UIView *)view title:(NSString *)title {
    if ([view isKindOfClass:UIButton.class] && [title isEqualToString:[(UIButton *)view titleForState:UIControlStateNormal]]) {
        return (UIButton *)view;
    }
    for (UIButton *subview in view.subviews) {
        if ([subview isKindOfClass:UIButton.class] && [title isEqualToString:[subview titleForState:UIControlStateNormal]]) {
            return subview;
        }
    }
    return nil;
}

//
- (void)addSomeElements:(UIViewController *)viewController {
//    PLImagePickerCameraView
//        CMKButtomBar
//        PLCropOverlay
//            PLCropOverlayBottomBar
//                PLCropOverlayPreviewBottomBar
    
    UIView *PLCameraView = [self findView:viewController.view name:@"PLImagePickerCameraView"];
    UIView *PLCropOverlay = [self findView:PLCameraView name:@"PLCropOverlay"];
    UIView *PLCropOverlayBottomBar = [self findView:PLCropOverlay name:@"PLCropOverlayBottomBar"];
    UIView *PLCropOverlayPreviewBottomBar = [self findView:PLCropOverlayBottomBar name:@"PLCropOverlayPreviewBottomBar"];
    
    UIButton *retake = [self findView:PLCropOverlayPreviewBottomBar title:@"Retake"];
    [retake setTitle:@"重拍" forState:UIControlStateNormal];
    NSLog(@"add some elements.retake = %@", retake);
    UIButton *save = [self findView:PLCropOverlayPreviewBottomBar title:@"Use Photo"];
    [save setTitle:@"选择" forState:UIControlStateNormal];
    NSLog(@"add some elements.save = %@", save);
    
    UIView *CMKBottomBar = [self findView:PLCameraView name:@"CMKBottomBar"];
    UIButton *cancel = [self findView:CMKBottomBar title:@"Cancel"];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    NSLog(@"add some elements.cancel = %@", cancel);
}

#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.actionArray.count;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
    NSString *action = [self.actionArray objectAtIndex:row];
    [self performSelector:NSSelectorFromString(action) withObject:nil];
#pragma clang diagnostic pop
}

- (void)enterDateExtPage {
    [self.navigationController pushViewController:[DateExtViewController new] animated:YES];
}
- (void)enterColorExtPage {
    [self.navigationController pushViewController:[ColorExtViewController new] animated:YES];
}
- (void)enterImagePickerPage {
}

@end
