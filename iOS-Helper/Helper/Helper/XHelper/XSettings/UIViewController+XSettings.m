//
//  UIViewController+SHSettings.m
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "UIViewController+XSettings.h"
#import <objc/runtime.h>
#import "XCellAttributes.h"
#import "XTableViewDataProxy.h"
#import "XSettingGroup.h"
#import "XTableViewProxy.h"

@implementation UIViewController (XSettings)

static void *xSettingsTableView = (void *)@"xSettingsTableView";
static void *xSettingsDataProxy = (void *)@"xSettingsDataProxy";
static void *xSettingsSettingGroups = (void *)@"xSettingsSettingGroups";
static void *xSettingsCellAttrs = (void *)@"xSettingsCellAttributes";
static void *xSettingsProxy = (void *)@"xSettingsProxy";

- (UITableView *)xTableView {
    UITableView *xTableView = objc_getAssociatedObject(self, &xSettingsTableView);
    if (!xTableView) {
        UITableViewStyle style = self.xCellAttrs.tableViewStyle;
        xTableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        [self.view addSubview:xTableView];
        [self setXTableView:xTableView];
    }
    return xTableView;
}
- (void)setXTableView:(UITableView *)xTableView {
    objc_setAssociatedObject(self, &xSettingsTableView, xTableView, OBJC_ASSOCIATION_ASSIGN);
}

- (XCellAttributes *)xCellAttrs {
    return objc_getAssociatedObject(self, &xSettingsCellAttrs);
}
- (void)setXCellAttrs:(XCellAttributes *)xCellAttrs {
    objc_setAssociatedObject(self, &xSettingsCellAttrs, xCellAttrs, OBJC_ASSOCIATION_RETAIN);
}

- (id<XTableViewDataProxy>)xDataProxy {
    return objc_getAssociatedObject(self, &xSettingsDataProxy);
}
- (void)setXDataProxy:(id<XTableViewDataProxy>)xDataProxy {
    objc_setAssociatedObject(self, &xSettingsDataProxy, xDataProxy, OBJC_ASSOCIATION_ASSIGN);
}

- (NSMutableArray *)xSettingGroups {
    NSMutableArray *groups = objc_getAssociatedObject(self, &xSettingsSettingGroups);
    if (!groups) {
        NSArray *source = [self.xDataProxy settingItems];
        groups = [XSettingGroup settingGroupsWithArray:source];
        [self setXSettingGroups:groups];
    }
    return groups;
}
- (void)setXSettingGroups:(NSMutableArray *)xSettingGroups {
    objc_setAssociatedObject(self, &xSettingsSettingGroups, xSettingGroups, OBJC_ASSOCIATION_RETAIN);
}

- (void)setXProxy:(XTableViewProxy *)xProxy {
    objc_setAssociatedObject(self, &xSettingsProxy, xProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XTableViewProxy *)xProxy {
    XTableViewProxy *proxy = objc_getAssociatedObject(self, &xSettingsProxy);
    if(!proxy){
        proxy = [[XTableViewProxy alloc] init];
        proxy.settingsProxy = self;
        [self setXProxy:proxy];
    }
    return proxy;
}

- (void)setupSettings {
    self.xTableView.dataSource = self.xProxy;
    self.xTableView.delegate = self.xProxy;
    // 是否取消系统划线
    if (self.xCellAttrs.cellFullLineEnable) {
        self.xTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    // 约束
    self.xTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[xTableView]-0-|" options:0 metrics:nil views:@{@"xTableView":self.xTableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[xTableView]-0-|" options:0 metrics:nil views:@{@"xTableView":self.xTableView}]];
}

- (void)reloadSettings {
    NSArray *source = [self.xDataProxy settingItems];
    NSMutableArray *groups = [XSettingGroup settingGroupsWithArray:source];
    [self setXSettingGroups:groups];
    // 是否取消系统划线
    if (self.xCellAttrs.cellFullLineEnable) {
        self.xTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.xTableView reloadData];
}


@end
