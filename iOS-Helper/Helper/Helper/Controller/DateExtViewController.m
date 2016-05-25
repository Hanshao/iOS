//
//  DateExtViewController.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "DateExtViewController.h"
#import "NSDate+Helper.h"

@interface DateExtViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DateExtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSDate *now = [NSDate date];
    NSDate *utc = [now GMT];
    
    NSDateFormatter *dateFormatter = [NSDate defaultFormatter];
    NSString *title = [NSString stringWithFormat:@"now : %@", [dateFormatter stringFromDate:now]];
    title = [title stringByAppendingFormat:@"\nutc : %@", [dateFormatter stringFromDate:utc]];
    title = [title stringByAppendingFormat:@"\nnow time interval %.0f, utc time interval = %.0f, offset = %.0f",
          [now timeIntervalSince1970], [utc timeIntervalSince1970], 8.0 * 3600];
    self.titleLabel.text = title;
}

@end
