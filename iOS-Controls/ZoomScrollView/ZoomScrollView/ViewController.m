//
//  ViewController.m
//  ZoomScrollView
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
<
    UIScrollViewDelegate
>

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"ssl_handshake"];
    [imageView sizeToFit];
    
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = imageView.bounds.size;
    self.imageView = imageView;
    
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *doubleGestureRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandle:)];
    doubleGestureRecognizer.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark
#pragma mark Event Handle
- (void)doubleTapHandle:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [sender locationInView:self.imageView];
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - 20, touchPoint.y - 20, 40, 40) animated:YES];
    }
}
@end
