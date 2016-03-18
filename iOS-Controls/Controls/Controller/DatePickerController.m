//
//  DatePickerController.m
//  YiMaoAgent
//
//  Created by Shaojun Han on 1/25/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "DatePickerController.h"
#import "HSPickerView.h"
#import "HSSegmentView.h"

@interface DatePickerController ()
<
    HSPickerViewDelegate, HSSegmentViewDelegate
>
{
    dispatch_once_t once_token;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet HSSegmentView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *yTitleView;
@property (weak, nonatomic) IBOutlet UIView *mTitleView;

@property (strong, nonatomic) HSPickerView *yPickerView;
@property (strong, nonatomic) HSPickerView *mPickerView;

@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger month;
@property (assign, nonatomic) NSInteger day;
@property (assign, nonatomic) NSInteger hour;
@property (assign, nonatomic) NSInteger minute;

@end

@implementation DatePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.segmentView setTitles:@[@"年月日", @"时分"]];
    self.segmentView.delegate = self;
    self.segmentView.selectedBackgroundColor = [UIColor clearColor];
    self.segmentView.normalBackgroundColor = [UIColor clearColor];
    self.segmentView.selectedLineColor = RGB(0x00, 0xAE, 0xEF, 0xFF);
    self.segmentView.selectedTextColor = RGB(0x00, 0xAE, 0xEF, 0xFF);
    self.segmentView.selectedIndex = 0;

    // 添加 日期选择器
    self.year = 2016, self.month = 1, self.day = 1;
    self.hour = 0, self.minute = 0;
    self.yPickerView = [[HSPickerView alloc] initWithFrame:CGRectMake(0, 0, 272, 150)];
    self.yPickerView.backgroundColor = [UIColor whiteColor];
    self.yPickerView.delegate = self;
    [self.scrollView addSubview:self.yPickerView];
    
    self.mPickerView = [[HSPickerView alloc] initWithFrame:CGRectMake(0, 0, 272, 150)];
    self.yPickerView.backgroundColor = [UIColor whiteColor];
    self.mPickerView.delegate = self;
    [self.scrollView addSubview:self.mPickerView];
    self.scrollView.contentSize = CGSizeMake(272 * 2, 150);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 此处的代码是非必要的，可以通过添加约束而减少此处的不必要代码
    dispatch_once(&once_token, ^{
        CGSize size = self.scrollView.bounds.size;
        self.yPickerView.frame = CGRectMake(0, 0, size.width, size.height);
        self.mPickerView.frame = CGRectMake(size.width, 0, size.width, size.height);
        self.scrollView.contentSize = CGSizeMake(size.width * 2, size.height);
        [self.yPickerView selectRow:9 ofComponent:0 animated:YES];
        [self.yPickerView reloadAllComponents];
        [self.mPickerView reloadAllComponents];
    });
}

#pragma mark
#pragma mark HSSegmentViewDelegate
- (void)segmentView:(HSSegmentView *)view itemSelectedAtIndex:(NSInteger)index {
    if (0 == index) {
        self.yTitleView.hidden = NO; self.mTitleView.hidden = YES;
        CGSize size = self.scrollView.bounds.size;
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, size.width, size.height) animated:YES];
    } else {
        self.yTitleView.hidden = YES; self.mTitleView.hidden = NO;
        CGSize size = self.scrollView.bounds.size;
        [self.scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:YES];
    }
}

#pragma mark
#pragma mark HSPickerViewDelegate
- (NSInteger)pickerView:(HSPickerView *)pickerView numberOfRowsOfComponent:(NSInteger)component {
    if (self.yPickerView == pickerView) {
        NSInteger days[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        NSInteger mdays[] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        NSInteger day = [self isLeapYear:self.year] ? mdays[self.month - 1] : days[self.month - 1];
        return 0 == component ? 50 : component == 1 ? 12 : day;  // 50年
    } else {
        return 0 == component ? 24 : 60;
    }
}
- (NSInteger)numberOfComponentsOfPickerView:(HSPickerView *)pickerView {
    return pickerView == self.yPickerView ? 3 : 2;
}
- (CGFloat)pickerView:(HSPickerView *)pickerView rowHeightOfComponent:(NSInteger)component {
    return 44.0f;
}
- (NSString *)pickerView:(HSPickerView *)pickerView titleOfRow:(NSInteger)row ofComponent:(NSInteger)component {
    if (self.yPickerView == pickerView) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%d", (int)(2025 - row)];
        } else {
            return [NSString stringWithFormat:@"%d", (int)(row + 1)];
        }
    } else {
        return [NSString stringWithFormat:@"%d", (int)row];
    }
}
/**
 * you can configure the color
 */
/**
- (UIColor *)pickerView:(HSPickerView *)pickerView backgroundColorOfComponent:(NSInteger)component {
    return 0 == component ? [UIColor orangeColor] : 1 == component ? [UIColor grayColor] : [UIColor whiteColor];
}
- (UIColor *)pickerView:(HSPickerView *)pickerView colorOfComponent:(NSInteger)component {
    return 0 == component ? [UIColor whiteColor] : 1 == component ? [UIColor orangeColor] : [UIColor grayColor];
}
*/
- (void)pickerView:(HSPickerView *)pickerView didSelectRow:(NSInteger)row ofComponent:(NSInteger)component {
    if (self.yPickerView == pickerView) {
        if (component == 0) {
            if ([self isLeapYear:self.year] != [self isLeapYear:(2025 - row)]) {
                self.year = 2025 - row;
                if (2 != self.month) return;
                [pickerView reloadComponent:1];
                [pickerView reloadComponent:2];
            } else {
                self.year = 2025 - row;
            }
        }
        if (component == 1 && self.month != row + 1) {
            self.month = row + 1;
            [pickerView reloadComponent:2];
        }
        if (component == 2) self.day = row + 1;
    } else {
        if (component == 0) self.hour = row;
        if (component == 1) self.minute = row;
    }
}

- (BOOL)isLeapYear:(NSInteger)year {
    return (year % 400 == 0) || ((year % 4 == 0) && (year % 100 != 0));
}
@end
