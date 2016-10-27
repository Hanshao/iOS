//
//  XPickerHelper.h
//  zencro
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XPickerView.h"

@interface XPickerHelper : UIView

// 视图
@property (strong, nonatomic) XPickerView *pickerView;

// 显示
- (void)showWithAnimated:(BOOL)animated;

// 隐藏
- (void)dismissWithAnimated:(BOOL)animated;

@end
