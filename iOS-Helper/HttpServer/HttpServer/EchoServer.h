//
//  HttpServer.h
//  HttpServer
//
//  Created by Shaojun Han on 7/13/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EchoServer : NSObject

- (BOOL)listen;
- (void)stop;

@end
