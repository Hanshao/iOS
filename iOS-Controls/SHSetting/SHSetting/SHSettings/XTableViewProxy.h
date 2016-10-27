//
//  XTableViewProxy.h
//  XSetting
//
//  Created by Shaojun Han on 8/26/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XSettingsDelegate.h"

@interface XTableViewProxy : NSObject<UITableViewDelegate, UITableViewDataSource>

// 代理
@property (weak, nonatomic) id<XSettingsDelegate> settingsProxy;

@end
