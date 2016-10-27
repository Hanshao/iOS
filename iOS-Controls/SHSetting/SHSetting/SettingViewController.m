//
//  SettingViewController.m
//  SHSetting
//
//  Created by Shaojun Han on 8/29/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "SettingViewController.h"
#import "XSettings.h"
#import "Helper.h"

@interface SettingViewController ()<XTableViewDataSource>

@property (assign, nonatomic) NSInteger rand;
@property (assign, nonatomic) BOOL enable;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.xCellAttrs = [XCellAttributes cellAttributesWithBackgroundColor:RGB(0x21, 0x21, 0x21) selBackgroundColor:RGB(170, 170, 170)];
    self.xCellAttrs.disableBottomLine = YES;
    self.xCellAttrs.cellFullLineEnable = YES;
    self.xCellAttrs.cellBackgroundColor = RGB(0x32, 0x32, 0x32);
    self.xCellAttrs.cellBottomLineColor = RGB(0x21, 0x21, 0x21);
    self.xCellAttrs.cellTitleTextColor = [UIColor whiteColor];
    self.xCellAttrs.cellDetailTextColor = [UIColor whiteColor];
    self.xCellAttrs.cellTextMaxSize = 14.0;
    self.xCellAttrs.tableViewStyle = UITableViewStyleGrouped;
    self.xTableView.backgroundColor = RGB(0x21, 0x21, 0x21);
    self.xDataSource = self;
    [self setupSettings];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshHandle:)];
}

- (void)refreshHandle:(id)sender {
    [self.xTableView reloadData];
}

- (NSArray *)settingItems {
    return @[ // groupArr
             @{ // groupModel
                 XSettingGroupHeaderKey: @"基本信息",
                 XSettingGroupFooterKey:@"上述是基本信息",
                 XSettingGroupHeaderHeightKey:@(40),
                 XSettingGroupFooterHeightKey:@(24),
                 XSettingGroupItemsKey : @[ // items
                         @{
                             XSettingItemSetupBlockKey:^(XSettingCell *cell, XSettingItem *item){
                                 cell.textLabel.text = @"Rand";
                                 cell.detailTextLabel.text = [@(self.rand) stringValue];
                                 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                 cell.selectionStyle = 1;   // Warning Value会修改此属性，所以重用的时候需要注意此属性
                             }
                             },
                         @{ // item
                             XSettingItemTitleKey: @"我的朋友",
                             XSettingItemSubTitleKey : @"你的好友",
                             XSettingItemAccessoryTypeKey : @(UITableViewCellAccessoryDisclosureIndicator),
                             XSettingItemCellTypeKey:[XSettingCell class],
                             XSettingItemOptionBlockKey : ^(XSettingCell *cell, XSettingPhaseType phaseType, id bindValue){ // 如果有可选的操作
                                 if (phaseType == XSettingPhaseInitType) {
                                     cell.textLabel.textColor = self.enable ? [UIColor whiteColor] : [UIColor darkGrayColor];
                                     cell.detailTextLabel.textColor = self.enable ? [UIColor whiteColor] : [UIColor darkGrayColor];
                                     cell.selectionStyle = self.enable ? 1 : 0;
                                 } else if (phaseType == XSettingPhaseInteractType) {
                                     self.rand = arc4random() % 1000 + 1;
                                     [self.xTableView reloadData];
                                 }
                             }
                             }, // end item
                         @{ // item
                             XSettingItemTitleKey: @"我的朋友",
                             XSettingItemCellTypeKey:[XSettingSwitchCell class], // 自定义的cell
                             XSettingItemOptionBlockKey : ^(XSettingCell *cell, XSettingPhaseType phaseType, id bindVal){ // 如果有可选的操作
                                 if (phaseType == XSettingPhaseInitType) {
                                     ((XSettingSwitchCell *)cell).switchView.selected = !self.enable;
                                 } else if (phaseType == XSettingPhaseInteractType) {
                                     NSLog(@"viewcontroller.cellinteract.swith");
                                     self.enable = ![bindVal boolValue];
                                     [self.xTableView reloadData];
                                 }
                             }
                             }, // end item
                         ]
                 },
             @{
                 XSettingGroupHeaderHeightKey:@(10),
                 XSettingGroupFooterHeightKey:@(0.001),
                 XSettingGroupItemsKey : @[
                         @{ // item
                             XSettingItemTitleKey: @"我的朋友",
                             XSettingItemCellTypeKey:[XSettingCell class],
                             XSettingItemSetupBlockKey: ^(XSettingCell *cell, XSettingItem *item) {
                                 // 标题
                                 CGFloat textMaxSize = cell.cellAttrs.cellTextMaxSize;
                                 cell.textLabel.hidden = NO;
                                 cell.textLabel.text = item.title;
                                 cell.textLabel.font = [UIFont systemFontOfSize:(textMaxSize > 1.f ? textMaxSize : 13)];
                                 cell.textLabel.textColor = [UIColor orangeColor];
                                 // 有的设置栏没有图标
                                 if (item.icon.length) {
                                     cell.imageView.image = [UIImage imageNamed:item.icon];
                                 }
                                 // 设置辅助视图类型
                                 cell.accessoryType = item.accessoryType;
                                 cell.selectionStyle = 1;
                             },
                             XSettingItemOptionBlockKey : ^(XSettingCell *cell, XSettingPhaseType phaseType, id bindValue){ // 如果有可选的操作
                                 if (phaseType == XSettingPhaseInitType) {
                                     
                                 }
                             }
                             }, // end item
                         @{
                             XSettingItemTitleKey: @"我的朋友",
                             XSettingItemAccessoryTypeKey : @(UITableViewCellAccessoryDetailButton),
                             },
                         @{
                             XSettingItemTitleKey: @"我的朋友",
                             XSettingItemSubTitleKey : @"你的好友",
                             XSettingItemAccessoryTypeKey : @(UITableViewCellAccessoryDisclosureIndicator),
                             XSettingItemIconKey:@"icon_lock",
                             XSettingItemSetupBlockKey: ^(XSettingCell *cell, XSettingItem *item){
                                 cell.textLabel.textColor = [UIColor darkGrayColor];
                                 cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                                 // 标题
                                 CGFloat textMaxSize = cell.cellAttrs.cellTextMaxSize;
                                 cell.textLabel.hidden = NO;
                                 cell.textLabel.text = item.title;
                                 cell.textLabel.font = [UIFont systemFontOfSize:(textMaxSize > 1.f ? textMaxSize : 13)];
                                 cell.textLabel.textColor = [UIColor darkGrayColor];
                                 // 子标题
                                 cell.detailTextLabel.hidden = NO;
                                 cell.detailTextLabel.text = item.subTitle;
                                 cell.detailTextLabel.font = [UIFont systemFontOfSize:(textMaxSize > 1.0 ? textMaxSize : 13)];
                                 cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                                 // 有的设置栏没有图标
                                 if (item.icon.length) {
                                     cell.imageView.image = [UIImage imageNamed:item.icon];
                                 }
                                 // 设置辅助视图类型
                                 cell.accessoryType = item.accessoryType;
                                 cell.selectionStyle = 1;
                             },
                             XSettingItemOptionBlockKey : ^(XSettingCell *cell, XSettingPhaseType phaseType, id bindValue){ // 如果有可选的操作
                                 if (phaseType == XSettingPhaseInitType) {
                                 }
                             }
                             }
                         ]
                 }
             ];
}

@end
