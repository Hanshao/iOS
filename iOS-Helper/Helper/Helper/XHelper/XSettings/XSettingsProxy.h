//
//  XSettingsDelegate.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XSettingAttrs;
@protocol XTableViewDataProxy;

@protocol XSettingsProxy <NSObject>

@property (nonatomic, weak) id<XTableViewDataProxy> xDataProxy;
@property (nonatomic, strong) NSMutableArray *xSettingGroups;
@property (nonatomic, strong) XSettingAttrs *xCellAttrs;

@end
