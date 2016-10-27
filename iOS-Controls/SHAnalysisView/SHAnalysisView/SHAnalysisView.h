//
//  SHAnalysisView.h
//  SHAnalysisView
//
//  Created by Shaojun Han on 7/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHAnalysisView;

@protocol SHAnalysisViewDelegate <NSObject>
@required
// 横线数
- (CGFloat)rowHeightInAnalysisView:(SHAnalysisView *)analysisView;
- (NSInteger)numbersOfRowlineInAnalysisView:(SHAnalysisView *)analysisView;
- (NSString *)titleInAnalysisView:(SHAnalysisView *)analysisView forRowline:(NSInteger)rowline;

// 纵线数
- (CGFloat)columnWidthInAnalysisView:(SHAnalysisView *)analysisView;
- (NSInteger)numbersOfColumnlineInAnalysisView:(SHAnalysisView *)analysisView;
- (NSString *)titleInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)column;
- (CGFloat)valueHeightInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)column;

@optional
- (UIView *)accessoryViewInAnalysisView:(SHAnalysisView *)analysisView forColumnline:(NSInteger)column;

@end

#define CurveWidth 2.0  // 曲线宽度
#define AxisWidth 0.5   // 坐标线宽度

@interface SHAnalysisView : UIView

// 虚线颜色
@property (strong, nonatomic) UIColor *dotcolor;
// 曲线颜色
@property (strong, nonatomic) UIColor *curcolor;
@property (strong, nonatomic) UIColor *shacolor;    // 阴影颜色
// 渐变颜色
@property (strong, nonatomic) UIColor *begincolor;
@property (strong, nonatomic) UIColor *endcolor;
// 文本
@property (strong, nonatomic) UIColor *textcolor;   // 文本色
@property (strong, nonatomic) UIFont  *font;        // 文本大小
// 坐标线颜色
@property (strong, nonatomic) UIColor *axiscolor;
// 代理
@property (weak, nonatomic) id<SHAnalysisViewDelegate> delegate;

// 显示虚线
- (void)showDotline:(BOOL)visible atColumnline:(NSInteger)column;

// 刷新绘图
- (void)reloadGraphics;

// 刷新辅助视图
- (void)reloadAccessorys;
- (UIView *)dequeueAccessoryViewForColumnline:(NSInteger)column;

@end
