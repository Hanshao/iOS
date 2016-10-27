//
//  XPickerView.h
//  zencro
//
//  Created by Shaojun Han on 8/30/16.
//  Copyright © 2016 hexs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XPickerViewDataSource, XPickerViewDelegate;

@interface XPickerView : UIView

@property (weak, nonatomic) id<XPickerViewDataSource> dataSource;
@property (weak, nonatomic) id<XPickerViewDelegate> delegate;

// 标题
@property (strong, nonatomic, readonly) UILabel *titleLabel;
//子标题
@property (strong, nonatomic, readonly) UILabel *detailTitleLabel;
// 列数
@property(nonatomic, nonatomic, readonly) NSInteger numberOfComponents;
// 行数
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

// 刷新数据
- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

// selection. in this case, it means showing the appropriate row in the middle
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger)selectedRowInComponent:(NSInteger)component;

@end


@protocol XPickerViewDataSource <NSObject>

- (NSUInteger)numberOfComponentsInPikcerView:(XPickerView *)pickerView;
- (NSUInteger)pickerView:(XPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol XPickerViewDelegate <NSObject>

- (NSString *)pickerView:(XPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(XPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end