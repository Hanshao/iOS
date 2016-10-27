//
//  UIViewController+SHSettings.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XSettingsDelegate.h"

@class XCellAttributes;
@protocol XTableViewDataProxy, XSettingsProxy;

@interface UIViewController (XSettings) <XSettingsDelegate>

@property (nonatomic, weak) UITableView *xTableView;
@property (nonatomic, weak) id<XTableViewDataProxy> xDataProxy;
@property (nonatomic, strong) NSMutableArray *xSettingGroups;
@property (nonatomic, strong) XCellAttributes *xCellAttrs;

// 启动配置
- (void)setupSettings;

// 重新加载
- (void)reloadSettings;

@end
