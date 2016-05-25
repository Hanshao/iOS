//
//  ViewController.m
//  WifiService
//
//  Created by Shaojun Han on 5/23/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Extension.h"
#import "ServiceDriver+UART.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
// 账户密码输入框
@property (weak, nonatomic) IBOutlet UITextField *accountTField;
@property (weak, nonatomic) IBOutlet UITextField *keyTField;
@end

@implementation ViewController

- (void)dealloc {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kremoteServiceOnlineNoteKey object:nil];
    [defaultCenter removeObserver:self name:kremoteServiceOfflineNoteKey object:nil];

    [defaultCenter removeObserver:self name:klocalServiceOnlineNoteKey object:nil];
    [defaultCenter removeObserver:self name:klocalServiceOfflineNoteKey object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(remoteOnline:) name:kremoteServiceOnlineNoteKey object:nil];
    [defaultCenter addObserver:self selector:@selector(remoteOffline:) name:kremoteServiceOfflineNoteKey object:nil];
    [defaultCenter addObserver:self selector:@selector(localOnline:) name:klocalServiceOnlineNoteKey object:nil];
    [defaultCenter addObserver:self selector:@selector(localOffline:) name:klocalServiceOfflineNoteKey object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)remoteOnline:(NSNotification *)note {
    NSString *text = self.infoTextView.text; if (!text) text = @"";
    text = [text stringByAppendingFormat:@"\n[%@]Remote online", [[self formatter] stringFromDate:[NSDate date]]];
    self.infoTextView.text = text;
}
- (void)remoteOffline:(NSNotification *)note {
    NSString *text = self.infoTextView.text; if (!text) text = @"";
    text = [text stringByAppendingFormat:@"\n[%@]Remote offline", [[self formatter] stringFromDate:[NSDate date]]];
    self.infoTextView.text = text;
}
- (void)localOnline:(NSNotification *)note {
    NSString *text = self.infoTextView.text; if (!text) text = @"";
    text = [text stringByAppendingFormat:@"\n[%@]Local online", [[self formatter] stringFromDate:[NSDate date]]];
    self.infoTextView.text = text;
}
- (void)localOffline:(NSNotification *)note {
    NSString *text = self.infoTextView.text; if (!text) text = @"";
    text = [text stringByAppendingFormat:@"\n[%@]Local offline", [[self formatter] stringFromDate:[NSDate date]]];
    self.infoTextView.text = text;
}
- (NSDateFormatter *)formatter {
    NSDateFormatter *formatter = nil;
    if (formatter) return formatter;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return formatter;
}

#pragma mark
#pragma mark Event Handle
- (IBAction)logClearHandle:(id)sender {
    self.infoTextView.text = @"";
}
// 关闭连接
- (IBAction)stopHandle:(id)sender {
    [ServiceDriverInstance halt];
}
// 启动连接
- (IBAction)startHandle:(id)sender {
    NSString *account = [self.accountTField.text trimWhiteAndNewline];
    NSString *key = [self.keyTField.text trimWhiteAndNewline];
    // 启动连接: 此接口经过压力测试, 在极限0.2秒每次的调用中, 通信层会稳定在最后一次调用所使用的用户名和密码
    [ServiceDriverInstance launchByAccount:account key:[key MD5]];
}
// 关闭连接并清理
- (IBAction)closeHandle:(id)sender {
    [ServiceDriverInstance revoke];
}
/** 请求/响应方式 **/
/** 请求响应模式中, 只针对某次发送时的序列号进行响应, 因此某些透传请使用订阅/发布方式; 超时时间以发送到接收的时间间隔计算 **/
- (IBAction)findHandle:(id)sender {
    [ServiceDriverInstance finderWithHandler:^(NSString *mac, NSString *ip, UInt8 company, UInt8 type, UInt16 author, id obj) {
        NSLog(@"发现设备 mac = %@", mac);
    } badHandler:^(NSInteger error) {
        NSLog(@"出现异常");
    } timeoutInterval:30];
}
/** 订阅/发布方式 **/
/** 订阅发布模式中, 所有关于此MAC地址的某类响应包都会发生回调, 因此此处订阅的发现包回调也会对上面findHandle:sender的反馈产生回调, 如果要监听非MAC地址相关的数据包, 在调用时mac字段传nil. **/
- (IBAction)registerFinderService {
    [ServiceDriverInstance addFinderObserver:self mac:@"FFFFFFFFFFFF" handler:^(NSString *mac, NSString *ip, UInt8 company, UInt8 type, UInt16 author, id obj) {
        NSLog(@"发现设备 mac = %@", mac);
    }];
}
- (IBAction)removeFinderService {
    [ServiceDriverInstance removeFinderObserver:self mac:@"FFFFFFFFFFFF"];
}

@end
