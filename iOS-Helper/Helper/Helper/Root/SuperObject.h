//
//  SuperObject.h
//  Helper
//
//  Created by Shaojun Han on 7/12/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIScrollView (Delegate)

@property (weak, nonatomic) id<UINavigationBarDelegate> delegate;

@end

@interface SuperObject : UIScrollView

@property (strong, nonatomic, readonly) NSString *name;
@property (weak, nonatomic) id<UINavigationBarDelegate> delegate;

@end
