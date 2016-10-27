//
//  HSAnalysisView.h
//  Controls
//
//  Created by Shaojun Han on 2/25/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//  0.1.0 稳定版

#import <UIKit/UIKit.h>

@class HSAnalysisView;

@protocol HSAnalysisViewDataSource <NSObject>
@required
// y coordinate line
- (NSInteger)numberOfYGraphiclinesInAnalysisView:(HSAnalysisView *)analysisView;
- (CGFloat)yGraphicHeightInAnalysisView:(HSAnalysisView *)analysisView;
- (UIColor *)colorOfYGraphiclineInAnalysisView:(HSAnalysisView *)analysisView;

@optional
// x coordinate line
- (NSInteger)numberOfXGraphiclinesInAnalysisView:(HSAnalysisView *)analysisView;
- (CGFloat)xGraphicWeightInAnalysisView:(HSAnalysisView *)analysisView;
- (UIColor *)colorOfXGraphiclineInAnalysisView:(HSAnalysisView *)analysisView;

// xy scale plates(color, scale)
- (UIColor *)colorOfXGraphicAxisInAnalysisView:(HSAnalysisView *)analysisView;
- (UIColor *)colorOfYGraphicAxisInAnalysisView:(HSAnalysisView *)analysisView;
- (NSString *)analysisView:(HSAnalysisView *)analysisView yGraphicAxis:(NSInteger)yaxis;
- (NSString *)analysisView:(HSAnalysisView *)analysisView xGraphicAxis:(NSInteger)xaxis;

// bar chart
- (CGFloat)barGraphicWeightInAnalysisView:(HSAnalysisView *)analysisView;
- (CGFloat)analysisView:(HSAnalysisView *)analysisView barGraphicHeight:(NSInteger)xaxis;
- (UIColor *)analysisView:(HSAnalysisView *)analysisView barGraphicColor:(NSInteger)xaxis;

// bezier curve chart(smooth curve)
- (CGFloat)analysisView:(HSAnalysisView *)analysisView slineGraphicHeight:(NSInteger)xaxis;
- (UIColor *)slineGraphicColorInAnalysisView:(HSAnalysisView *)analysisView;

@end

@protocol HSAnalysisViewDelegate <NSObject>
@optional
- (void)anaysisView:(HSAnalysisView *)anaysisView touchAtXaxis:(NSInteger)xaxis;
- (void)anaysisView:(HSAnalysisView *)anaysisView didScale:(CGFloat)scale;

@end

/**
 * block for refresh
 */
typedef void (^HSAnalysisRefreshingBlock)();

@interface HSAnalysisView : UIView

@property (weak, nonatomic) id<HSAnalysisViewDataSource> dataSource;
@property (weak, nonatomic) id<HSAnalysisViewDelegate> delegate;

// scale(zoom)
- (void)setScaleEnable:(BOOL)enable;

// color for dot line(when long pressing)
- (void)setColorOfDotline:(UIColor *)color;
// width for dot line. bug : if it's refreshing and you do call the setDotlineWeight:, the refreshing effect will disappear 
- (void)setDotlineWeight:(CGFloat)weight;
// enable/disable long press
- (void)setDotlineEnable:(BOOL)enable;

// set refresh enable
- (void)setAutoRefreshing:(BOOL)enable;
// add refresh block or target/action. and only one can be available
- (void)addRefreshingBlock:(HSAnalysisRefreshingBlock)refreshingBlock;
- (void)addRefreshingTarget:(id)target refreshingAction:(SEL)action;
// begin/end refreshing
- (void)beginRefreshing;
- (void)endRefreshing;

// reload data all right
- (void)reloadGraphics;

@end
