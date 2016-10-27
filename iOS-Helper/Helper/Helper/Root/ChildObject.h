//
//  ChildObject.h
//  Helper
//
//  Created by Shaojun Han on 7/12/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "SuperObject.h"

@interface ChildObject : SuperObject

@property (strong, nonatomic, readwrite) NSString *name;

- (void)startTimer;
- (void)stopTimer;

@end
