//
//  UIViewController+Picker.m
//  Helper
//
//  Created by Shaojun Han on 7/6/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Picker)
// 图片选择
+ (UIImagePickerController *)imagePickerWithSoureType:(UIImagePickerControllerSourceType)sourceType editable:(BOOL)editable {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.editing = editable;
    return imagePicker;
}

@end
