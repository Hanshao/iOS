//
//  XSettingsDelegate.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCellAttributes;
@protocol XTableViewDataSource;

@protocol XSettingsDelegate <NSObject>

@property (nonatomic, weak) id<XTableViewDataSource> xDataSource;
@property (nonatomic, strong) NSMutableArray *xSettingGroups;
@property (nonatomic, strong) XCellAttributes *xCellAttrs;

@end
