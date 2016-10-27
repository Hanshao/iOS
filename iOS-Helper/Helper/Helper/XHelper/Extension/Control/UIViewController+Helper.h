//
//  UIViewController+Picker.h
//  Helper
//
//  Created by Shaojun Han on 7/6/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Picker)
// 图片选择器
+ (UIImagePickerController *)imagePickerWithSoureType:(UIImagePickerControllerSourceType)sourceType editable:(BOOL)editable;

@end
