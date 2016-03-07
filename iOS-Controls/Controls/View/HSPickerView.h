//
//  HSPickerView.h
//  YiMaoAgent
//
//  Created by Shaojun Han on 1/26/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSPickerView;

@protocol HSPickerViewDelegate <NSObject>
@required
/**
 * 某列的行数
 */
- (NSInteger)pickerView:(HSPickerView *)pickerView numberOfRowsOfComponent:(NSInteger)component;

@optional
/**
 * 列数，默认1列
 */
- (NSInteger)numberOfComponentsOfPickerView:(HSPickerView *)pickerView;

/**
 * 每行的高度，在同一列中，行高是相同的
 */
- (CGFloat)pickerView:(HSPickerView *)pickerView rowHeightOfComponent:(NSInteger)component;

/**
 * 每行的标题
 */
- (NSString *)pickerView:(HSPickerView *)pickerView titleOfRow:(NSInteger)row ofComponent:(NSInteger)component;

/**
 * 每行的标题
 */
- (NSAttributedString *)pickerView:(HSPickerView *)pickerView attributedTitleOfRow:(NSInteger)row ofComponent:(NSInteger)component;

/**
 * 选中时的回调
 */
- (void)pickerView:(HSPickerView *)pickerView didSelectRow:(NSInteger)row ofComponent:(NSInteger)component;

/**
 * 外观:每列的颜色
 */
- (UIColor *)pickerView:(HSPickerView *)pickerView backgroundColorOfComponent:(NSInteger)component;

/**
 * 圆环的颜色
 */
- (UIColor *)pickerView:(HSPickerView *)pickerView colorOfComponent:(NSInteger)component;

@end

@interface HSPickerView : UIView

@property (strong, nonatomic) UIColor *normalTitleColor;
@property (nonatomic,readonly) NSInteger numberOfComponents;
@property (weak, nonatomic) id<HSPickerViewDelegate> delegate;

/**
 * 刷新视图
 */
- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

// 行数
- (NSInteger)numberOfRowsOfComponent:(NSInteger)component;
- (CGSize)rowSizeOfComponent:(NSInteger)component;
// 滚动到选中
- (void)selectRow:(NSInteger)row ofComponent:(NSInteger)component animated:(BOOL)animated;
// 当前选中
- (NSInteger)selectedRowOfComponent:(NSInteger)component;

@end