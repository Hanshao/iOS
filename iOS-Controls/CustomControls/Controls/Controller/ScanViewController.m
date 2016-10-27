//
//  ScanViewController.m
//  YiMaoCustomerApp
//
//  Created by Shaojun Han on 1/21/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ScanViewController.h"
#import "PhotoLayer.h"
#import "HSScaner.h"

@interface ScanViewController ()
<
    HSScanerDelegate, UIAlertViewDelegate
>


@property (strong, nonatomic) HSScaner *scaner;
@property (strong, nonatomic) PhotoLayer *photoLayer;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    self.photoLayer = [[PhotoLayer alloc] initWithFrame:bounds];
    [self.view insertSubview:self.photoLayer atIndex:0];
    self.photoLayer.boundImage = [UIImage imageNamed:@"scan_squre"];
    self.photoLayer.lineImage = [UIImage imageNamed:@"scan_line"];
    [self initScaner];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.scaner) {
        [self.scaner startRunning];
        [self.photoLayer startAnimations];
    } else { // 没有开启权限
        self.scaner = nil;
        [self.photoLayer stopAnimations];
        [HSScaner requestAccessForVedioType:^(BOOL granted) {
            if (!granted) {
                [self alertWithTitle:@"无法访问相机" message:nil delegate:self];
            } else {
                [self initScaner];
                [self.scaner startRunning];
                [self.photoLayer startAnimations];
            }
        }];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.photoLayer stopAnimations];
    [self.scaner stopRunning];
}
- (void)initScaner {
    self.scaner = [[HSScaner alloc] initWithDelegate:self codeTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    [self.scaner insertPrelayer:self.photoLayer];
    
    CGRect rectangle = self.photoLayer.clearRectangle;
    CGSize size = [UIScreen mainScreen].bounds.size;
    rectangle = CGRectMake(rectangle.origin.y / (size.height - 64),
                           rectangle.origin.x / size.width,
                           rectangle.size.height / (size.height - 64),
                           rectangle.size.width / size.width);
    [self.scaner setActiveRectangle:rectangle];
}

#pragma mark
#pragma mark 事件处理
- (IBAction)returnHandle:(id)sender {
    [self dismiss];
}

#pragma mark
#pragma mark 代理
// 注意这里的接口发生了变化
- (void)scaner:(HSScaner *)scaner didCapture:(NSString *)codeString {
    [self.scaner stopRunning];
    [self.photoLayer stopAnimations];
    [self alertWithTitle:codeString message:nil delegate:self];
}
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                   delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.photoLayer startAnimations];
    [self.scaner startRunning];
}

@end
