//
//  ViewController.m
//  HttpServer
//
//  Created by Shaojun Han on 7/13/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "EchoServer.h"

@interface ViewController ()
@property (strong, nonatomic) EchoServer *server;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    EchoServer *server = [[EchoServer alloc] init];
    [server listen];
    self.server = server;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
