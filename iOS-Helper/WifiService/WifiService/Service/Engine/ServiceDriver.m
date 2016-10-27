//
//  ServiceDriver.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/16/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "ServiceDriver.h"
#import "GCDTimer.h"

/**
 * 回调代理类 (0.2.0)
 * 封装了解析方法名和解析的block
 * 使用了超时计时器, 超时计时器在使用序列号回调时使用
 */
@interface DriverProxy : NSObject
// 键值id
@property (copy, nonatomic, readonly) NSString    *key;       // id
@property (strong, nonatomic, readonly) NSDate    *birthday;  // 创建日期
// 回调
@property (assign, nonatomic, readonly) SEL       selector;   // 解析包方法
@property (copy, nonatomic, readonly)   id        completion; // 解析回调
// 初始化方法
- (instancetype)initWithKey:(NSString *)key;
- (instancetype)initWithKey:(NSString *)key selector:(SEL)selector completion:(id)completion;
@end

@implementation DriverProxy
- (instancetype)initWithKey:(NSString *)key {
    if (self = [super init]) {
        _key = [key copy];
        _birthday = [NSDate date];
    }
    return self;
}
- (instancetype)initWithKey:(NSString *)key selector:(SEL)selector completion:(id)completion {
    if (self = [self initWithKey:key]) {
        _selector = selector;
        _completion = [completion copy];
    }
    return self;
}
@end

@interface XDriverProxy : DriverProxy
// 回调类型
@property (assign, nonatomic) NSUInteger style; // 本地或远程
// 超时
@property (strong, nonatomic) GCDTimer  lifeTimer;  // 超时计时
@property (assign, nonatomic, readonly) NSTimeInterval  life; // 超时时间
@property (copy, nonatomic, readonly) ServiceBadHandler badHandler; // 异常回调(主要是超时)
// 初始化方法
- (instancetype)initWithKey:(NSString *)key style:(NSInteger)style selector:(SEL)selector completion:(id)completion badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval;
// 计时器
- (void)fireWithHandler:(void (^)(void))handler;
- (void)revoke;
@end

@implementation XDriverProxy
- (instancetype)initWithKey:(NSString *)key style:(NSInteger)style selector:(SEL)selector completion:(id)completion badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self = [self initWithKey:key selector:selector completion:completion]) {
        _style = style;
        _life = timeoutInterval;
        _badHandler = [badHandler copy];
    }
    return self;
}
// 计时器
- (void)fireWithHandler:(void (^)(void))handler {
    [self revoke]; self.lifeTimer =
    ScheduledRecurringTimer(nil, self.life, handler);
}
- (void)revoke {
    CancelTimer(self.lifeTimer);
}
@end


/**
 * 回调执行类 (0.2.0)
 * 封装了处理的回调
 * 该处理是添加了监听的类的回调处理, 不使用超时规则
 */
@interface DriverHolder : NSObject
// 时间处理
@property (strong, nonatomic, readonly) NSString  *key;         // id
@property (strong, nonatomic, readonly) NSDate    *birthday;    // 创建日期
// 回调
@property (copy, nonatomic, readonly) NSString    *objKey;      // MAC地址
@property (weak, nonatomic, readonly) id          observer;     // 观察者
@property (copy, nonatomic, readonly) id          handler;      // 回调block

- (instancetype)init;
- (instancetype)initWithObserver:(id)observer objKey:(NSString *)objKey handler:(id)handler;
@end

@implementation DriverHolder
- (instancetype)init {
    if (self = [super init]) {
        _key = nil; // 当前版本不需要key值
        _birthday = [NSDate date];
    }
    return self;
}
- (instancetype)initWithObserver:(id)observer objKey:(NSString *)objKey handler:(id)handler {
    if (self = [self init]) {
        _observer = observer;
        _objKey = [objKey copy];
        _handler = [handler copy];
    }
    return self;
}
@end


///////////////////////////////////// 通信驱动类 ////////////////////////////////////
// 通信层上离线通知
NSString *const klocalServiceOnlineNoteKey = @"localServiceOnlineNoteKey";
NSString *const klocalServiceOfflineNoteKey = @"localServiceOfflineNoteKey";
NSString *const kremoteServiceOnlineNoteKey = @"remoteServiceOnlineNoteKey";
NSString *const kremoteServiceOfflineNoteKey = @"remoteServiceOfflineNoteKey";
// 数据包类型码(局域网, 互联网)
UInt8 const localPackageStyle = 0x01;
UInt8 const remotePackageStyle = 0x02;
// 协议数据包 定长长度和标识
#define FIEXD_HEADER_LENGTH 9
#define TAG_FLEX_LENGTH_BODY 10890
#define TAG_FIEXD_LENGTH_HEADER 20890
// 广播地址
#define BroadMACAddress @"FFFFFFFFFFFF"

/**
 * 服务驱动类
 * 完成通信层部分的驱动
 */
@interface ServiceDriver ()
<
LocalServiceDelegate, RemoteServiceDelegate,
NetworkUtilDelegate, WifiManagerDelegate
>
@end

@interface ServiceDriver ()
@property (strong, nonatomic) GCDTimer resolveTimer;
@property (strong, nonatomic) GCDTimer beatTimer;
@property (strong, nonatomic) GCDTimer bindTimer;
@end

// 网络与处理
@interface ServiceDriver ()
@property (strong, nonatomic) NSMutableDictionary *xproxyQueue;  // 处理队列(序列号)
@property (strong, nonatomic) NSMutableDictionary *holderQueue;  // handler队列(观察者)
@property (strong, nonatomic) NSMutableDictionary *proxyQueue;   // 处理队列(观察者)

@property (strong, nonatomic) LocalService  *localService;
@property (strong, nonatomic) RemoteService *remoteService;
@property (strong, nonatomic) RemoteService *resolveService;
@end

// 远程TCP心跳
@interface ServiceDriver ()
@property (assign, nonatomic) BOOL  beatEnable;
@end

// 接入工作服务器
@interface ServiceDriver ()
@property (assign, nonatomic) UInt16 author;
@property (copy, nonatomic) NSString *account;  // 工作服务器用户名
@property (copy, nonatomic) NSString *key;      // 工作服务器密码
@end

@implementation ServiceDriver

+ (instancetype)sharedInstance {
    static ServiceDriver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ServiceDriver new];
    });
    return sharedInstance;
}

- (void)dealloc {
    [self removeReachableService];
}

/**
 * 初始化函数
 */
- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    _xproxyQueue = [NSMutableDictionary dictionary];
    _holderQueue = [NSMutableDictionary dictionary];
    _proxyQueue = [NSMutableDictionary dictionary];
    
    NSDictionary *sslMoreSettings = @{GCDAsyncSocketSSLProtocolVersionMin:@(2), GCDAsyncSocketSSLProtocolVersionMax:@(8), GCDAsyncSocketManuallyEvaluateTrust:@(YES)};
    NSDictionary *sslSettings = [SSLManager sslSettingsWithHost:AddressOflevelingServer file:SSLCertificateFile key:SSLCertificatePassword other:sslMoreSettings];
    
    _localService = [[LocalService alloc] initWithDelegate:self];
    _remoteService = [[RemoteService alloc] initWithDelegate:self sslSettings:sslSettings trustHandler:nil];
    _resolveService = [[RemoteService alloc] initWithDelegate:self sslSettings:sslSettings trustHandler:nil];
}

/**
 * 注册/注销网络服务
 */
- (void)registerReachableService {
    [NetworkUtilInstance addDelegate:self];
    [WifiManagerInstance addDelegate:self];
}
- (void)removeReachableService {
    [NetworkUtilInstance removeDelegate:self];
    [WifiManagerInstance removeDelegate:self];
}

/**
 * 停止/停止并清理
 */
- (void)halt {
    [self close];
    [self disconnect];
}
- (void)revoke {
    self.key = nil;
    self.account = nil;
    
    [self halt];
    [self clear];
}

/**
 * 启动/重置账户密码后启动
 */
- (void)launch {
    [self bind];
    [self connect];
}
- (void)launchByAccount:(NSString *)account key:(NSString *)key {
    self.key = key;
    self.account = account;
    
    [self launch];
}

#pragma mark
#pragma mark 本地服务
/**
 * 绑定/关闭本地服务
 */
- (void)bind {
    [self close];
    [self rebindWithTimeinterval:0];
}
- (void)rebind {
    if (!(self.account && self.key)) return;
     [self.localService bindToPort:PortOflocalService];
}
- (void)close {
    [self invalidateBinder];
    
    _localOnline = NO;
    [self.localService close];
}

#pragma mark
#pragma mark 远程服务
/**
 * 远程服务接入/断开
 */
- (void)connect {
    [self disconnect];
    [self reconnectWithTimeinterval:0];
}
- (void)reconnect {
    if (!(self.account && self.key)) return;
    [self.resolveService connectToHost:AddressOflevelingServer port:PortOflevelingServer];
}
- (void)disconnect {
    [self stopBeating];
    [self invalidateResolver];
    
    _remoteOnline = NO;
    [self.resolveService disconnect];
    [self.remoteService disconnect];
}

/**
 * 对处理队列深度清理/清理
 */
- (void)clear {
    [self.holderQueue removeAllObjects];
    [self.proxyQueue removeAllObjects];
    [self.xproxyQueue removeAllObjects];
}
- (void)lightClear {
    NSMutableArray *list = [NSMutableArray array];
    NSMutableArray *klist = [NSMutableArray array];
    for (NSString *key in self.holderQueue) {
        NSMutableArray *array = [self.holderQueue objectForKey:key];
        
        for (int i = 0; i < array.count; ++ i) {
            DriverHolder *holder = [array objectAtIndex:i];
            if (!holder.observer) [list addObject:holder];
        }
        
        if (list.count) {
            [array removeObjectsInArray:list];
            [list removeAllObjects];
        }
        
        if (array.count < 1) [klist addObject:key];
    }
    if (klist.count) {  //
        [self.holderQueue removeObjectsForKeys:klist];
    }
}

#pragma mark
#pragma mark 服务器连接处理
- (void)reconnectWithTimeinterval:(NSTimeInterval)interval {
    [self stopBeating];
    [self resolveWithTimeinterval:interval];
}
- (void)rebindWithTimeinterval:(NSTimeInterval)interval {
    [self invalidateBinder];
    __weak typeof(self) wSelf = self;
    self.bindTimer = ScheduledRecurringTimer(nil, interval, ^{
        [wSelf invalidateBinder];
        [wSelf rebind];
    });
}
// 启动重连接计时器
- (void)resolveWithTimeinterval:(NSTimeInterval)interval {
    [self invalidateResolver];
    __weak typeof(self) wSelf = self;
    self.resolveTimer = ScheduledRecurringTimer(nil, interval, ^{
        [wSelf invalidateResolver];
        [wSelf reconnect];
    });
}
- (void)rebeatWithTimeInterval:(NSTimeInterval)interval {
    [self invalidateBeater];
    __weak typeof(self) wSelf = self;
    self.beatTimer = ScheduledRecurringTimer(nil, interval, ^{
        [wSelf invalidateBeater];
        [wSelf beatOnce];
    });
}
- (void)invalidateBinder {
    CancelTimer(self.bindTimer);
}
- (void)invalidateResolver {
    CancelTimer(self.resolveTimer);
}
- (void)invalidateBeater {
    CancelTimer(self.beatTimer);
}


#pragma mark
#pragma mark 发送数据
- (void)remoteSendPackage:(Package *)package timeoutInterval:(NSTimeInterval)timeoutInterval {
    UInt16 serial = [package serial];
    [self.remoteService sendPacket:[package data] tag:serial timeoutInterval:timeoutInterval];
}
- (void)localSendPackage:(Package *)package host:(NSString *)host timeoutInterval:(NSTimeInterval)timeoutInterval {
    UInt16 serial = [package serial];
    [self.localService sendPacket:[package data] toHost:host port:PortOflocalService tag:serial timeoutInterval:timeoutInterval];
}
// 发送数据
- (void)remoteSendPackage:(Package *)package selector:(SEL)selector parser:(id)parser badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    UInt16 serial = [package serial];
    if (parser || badHandler) {
        NSString *key = [self keyBySerial:serial];
        XDriverProxy *xproxy = [[XDriverProxy alloc] initWithKey:key style:remotePackageStyle selector:selector completion:parser badHandler:badHandler timeoutInterval:timeoutInterval];
        [self.xproxyQueue setObject:xproxy forKey:key];
        // 超时处理
        __weak typeof(self) wSelf = self;
        [xproxy fireWithHandler:^{
            XDriverProxy *xproxy = [wSelf proxyWithSerial:serial];
            [xproxy revoke]; [wSelf removeProxyWithSerial:serial];
            if (xproxy.badHandler) {
                dispatch_async_main_safe(^{ xproxy.badHandler(ServiceTimeoutError); });
            }
        }];  // 启动
    }
    // 数据发送
    [self.remoteService sendPacket:[package data] tag:serial timeoutInterval:timeoutInterval];
}
- (void)localSendPackage:(Package *)package host:(NSString *)host selector:(SEL)selector parser:(id)parser badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    UInt16 serial = [package serial];
    if (parser || badHandler) {
        NSString *key = [self keyBySerial:serial];
        XDriverProxy *xproxy = [[XDriverProxy alloc] initWithKey:key style:localPackageStyle selector:selector completion:parser badHandler:badHandler timeoutInterval:timeoutInterval];
        [self.xproxyQueue setObject:xproxy forKey:key];
        // 超时处理
        __weak typeof(self) wSelf = self;
        [xproxy fireWithHandler:^{
            XDriverProxy *xproxy = [wSelf proxyWithSerial:serial];
            [xproxy revoke]; [wSelf removeProxyWithSerial:serial];
            if (xproxy.badHandler) {
                dispatch_async_main_safe(^{ xproxy.badHandler(ServiceTimeoutError); });
            }
        }];  // 启动
    }
    // 数据发送
    [self.localService sendPacket:[package data] toHost:host port:PortOflocalService tag:serial timeoutInterval:timeoutInterval];
}

#pragma mark
#pragma mark Local代理
// 发送失败
- (void)localService:(LocalService *)service didNotSendWithTag:(long)tag error:(NSError *)error {
    UInt16 serial = tag; XDriverProxy *proxy = [self proxyWithSerial:serial];
    [proxy revoke]; [self removeProxyWithSerial:serial];
    if (proxy && proxy.badHandler) {
        dispatch_async_main_safe(^{
            proxy.badHandler(ServiceNetworkError);
        });
    }
}
// 读取成功
- (void)localService:(LocalService *)service didRecieve:(NSData *)data address:(NSString *)address {
    Package *package = [[Package alloc] initWithData:data style:localPackageStyle accessory:address];
    if (![Package isRecieveOkay:package]) return;   // 过滤本机或其他手机广播包
    
    if ([Package isSerialOkay:package]) {
        UInt16 serial = [package serial]; XDriverProxy *proxy = [self proxyWithSerial:serial];
        [proxy revoke]; [self removeProxyWithSerial:serial];
        if (proxy.selector && proxy.completion) {    // performSelector: 和普通的消息发送时等价的
            NSLog(@"tcp revieve key>>>>>>>>>>>>>>>selector = %@, serial = %u", NSStringFromSelector(proxy.selector), serial);
            [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
        }
    }
    
    NSString *key = [self keyByCode:[self codeOfPackage:package]];
    DriverProxy *proxy = [self proxyWithKey:key];
    if (proxy.selector && proxy.completion) {   // performSelector: 和普通的消息发送时等价的
        NSLog(@"udp revieve key>>>>>>>>>>>>>>>selector = %@, key = %@", NSStringFromSelector(proxy.selector), key);
        [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
    }
}
// 绑定成功
- (void)localServiceDidBind:(LocalService *)service {
    [self invalidateBinder]; _localOnline = YES;
    dispatch_async_main_safe(^{ // 发送UDP在线通知
        [[NSNotificationCenter defaultCenter]
         postNotificationName:klocalServiceOnlineNoteKey object:nil];
    });
    NSLog(@"bind = %@", @"绑定成功");
}
// 绑定不成功
- (void)localServiceDidNotBind:(LocalService *)service error:(NSError *)error {
    _localOnline = NO;
    NSLog(@"bind = %@", @"绑定失败");
}
// 连接断开
- (void)localServiceDidClose:(LocalService *)service error:(NSError *)error {
    _localOnline = NO;
    dispatch_async_main_safe(^{ // 发送UDP离线通知
        [[NSNotificationCenter defaultCenter]
         postNotificationName:klocalServiceOfflineNoteKey object:nil];
    });
    // 异常回调
    [self closeProxyBylocalStyle];
    // 正常断开
    if (error == nil) return;
    // 尝试重新连接(网络可达的情况下重连)
    if (WifiManagerInstance.networkStatus == ReachableViaWiFi)
        [self rebindWithTimeinterval:30];
}
- (void)closeProxyBylocalStyle {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in self.xproxyQueue) {
        XDriverProxy *xproxy = [self.xproxyQueue objectForKey:key];
        if (xproxy.style == localPackageStyle && xproxy.badHandler) {
            [xproxy revoke]; [keys addObject:key];
            dispatch_async_main_safe(^{ xproxy.badHandler(ServiceNetworkError); });
        }
    }
    [self.xproxyQueue removeObjectsForKeys:keys];
}


#pragma mark
#pragma mark Remote代理
// 读取成功
- (void)remoteService:(RemoteService *)service timeoutWriteWithTag:(long)tag {
    UInt16 serial = tag; XDriverProxy *proxy = [self proxyWithSerial:serial];
    [proxy revoke]; [self removeProxyWithSerial:serial];
    
    if (proxy && proxy.badHandler) {
        dispatch_async_main_safe(^{
            proxy.badHandler(ServiceNetworkError);
        });
    }
}
- (void)remoteService:(RemoteService *)service didRecieve:(NSData *)data tag:(long)tag{
    static NSMutableData *response = nil;
    if (TAG_FIEXD_LENGTH_HEADER == tag) {
        response = [NSMutableData dataWithData:data];
        UInt8 *bytes = (UInt8 *)[response bytes];
        NSUInteger size = bytes[response.length - 1];
        
        [service recieveDataToSize:size tag:TAG_FLEX_LENGTH_BODY];
    } else if (TAG_FLEX_LENGTH_BODY == tag){
        [response appendData:data];
        [self handleRemoteRecieve:service data:response];
        [service recieveDataToSize:FIEXD_HEADER_LENGTH tag:TAG_FIEXD_LENGTH_HEADER];
    }
}
// 连接成功
- (void)remoteServiceDidConnect:(RemoteService *)service {
    [self invalidateResolver];
    // 判断是否连接工作服务器
    if (service == self.resolveService) {
        // 发送解析工作服务器数据包
        [self.resolveService recieveDataToSize:FIEXD_HEADER_LENGTH tag:TAG_FIEXD_LENGTH_HEADER];
        Package *package =
        [Package resolveWorkServer:[Package grow] company:DefaultAppCompany type:DefaultAppType author:DefaultAppAuthor];
        [self.resolveService sendPacket:[package data]];
        
    } else if (service == self.remoteService) {
        // 启动心跳，接入工作服务器
        [self.remoteService recieveDataToSize:FIEXD_HEADER_LENGTH tag:TAG_FIEXD_LENGTH_HEADER];
        [self joinWorkServer];
    }
}
// 连接失败
- (void)remoteServiceDidNotConnect:(RemoteService *)service error:(NSError *)error {
    _remoteOnline = NO;
    // TCP连接失败，30后重新连接
    [self reconnectWithTimeinterval:30];
}
// 断开连接
- (void)remoteServiceDidDisconnect:(RemoteService *)service error:(NSError *)error {
    if (service == self.remoteService) {
        _remoteOnline = NO;
        dispatch_async_main_safe(^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kremoteServiceOfflineNoteKey object:nil];
        });
        // 异常回调
        [self closeProxyByRemoteStyle];
    }
    
    if (error == nil) { NSLog(@"remote disconnect normally."); return; }
    if (service == self.remoteService) {
        NSLog(@"disconnect abnormally!!!");
        // TCP连接失败，30后重新连接, 尝试重新连接(网络可达的情况下重连)
        if (WifiManagerInstance.networkStatus != NotReachable)
            [self reconnectWithTimeinterval:30];
    } else if (self.resolveService == service) {
        // 解析过程中关停
        _remoteOnline = NO;
        // TCP连接失败，30后重新连接, 尝试重新连接(网络可达的情况下重连)
        if (NetworkUtilInstance.networkStatus != NotReachable)
            [self reconnectWithTimeinterval:30];
    }
}
- (void)closeProxyByRemoteStyle {
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in self.xproxyQueue) {
        XDriverProxy *xproxy = [self.xproxyQueue objectForKey:key];
        if (xproxy.style == remotePackageStyle && xproxy.badHandler) {
            [xproxy revoke]; [keys addObject:key];
            dispatch_async_main_safe(^{ xproxy.badHandler(ServiceNetworkError); });
        }
    }
    [self.xproxyQueue removeObjectsForKeys:keys];
}
// 接入工作服务器
- (void)joinWorkServer {
    // 注册接入工作服务器的反馈
    NSLog(@"........It's going to join work server with account = %@, key = %@", self.account, self.key);
    Package *package = [Package joinWorkServer:[Package grow] account:self.account key:self.key company:DefaultAppCompany type:DefaultAppType author:self.author joinCode:DefaultAppAccessKey joinSize:sizeof(DefaultAppAccessKey)];
    __weak typeof(self) wSelf = self;
    [self remoteSendPackage:package selector:@selector(joinWorkServer:completion:) parser:^(NSString *imac, UInt8 result){
        NSLog(@"........Tcp join work server>>>>>>>>>>>>>>>result = %d", result);
        if (!(0x00 == result)) {
            [wSelf reconnectWithTimeinterval:30];
        } else {
            [wSelf setValue:@(YES) forKey:@"remoteOnline"]; // 使用kvc
            [wSelf startBeating];
            dispatch_async_main_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kremoteServiceOnlineNoteKey object:nil];
            });
        }
    } badHandler:nil timeoutInterval:60];
}
// 数据处理(远程)
- (void)handleRemoteRecieve:(RemoteService *)service data:(NSData *)data {
    NSLog(@"remote did read>>>>>>>>>>>>>>>\n%@", [self format:data]);
    if (service == self.resolveService) {
        // 工作服务器解析完成
        Package *package = [[Package alloc] initWithData:data style:remotePackageStyle];
        __weak typeof(self) wSelf = self;
        [Package resolveWorkServer:package completion:^(NSString *mac, NSString *ip, UInt16 port, UInt16 author) {
            [wSelf invalidateResolver]; [service disconnect];
            // 尝试接入工作服务器
            wSelf.author = author; [wSelf.remoteService connectToHost:ip port:port];
            NSLog(@"tcp resolve ok>>>>>>>>>>>>>>>ip = %@, port = %d", ip, port);
        }];
    } else if (service == self.remoteService) {
        Package *package = [[Package alloc] initWithData:data style:remotePackageStyle];
        if (![Package isRecieveOkay:package]) return;   // 过滤本机或其他手机广播包
        
        if ([Package isSerialOkay:package]) {
            UInt16 serial = [package serial]; XDriverProxy *proxy = [self proxyWithSerial:serial];
            [proxy revoke]; [self removeProxyWithSerial:serial];    // 删除
            if (proxy.selector && proxy.completion) {
                NSLog(@"tcp revieve key>>>>>>>>>>>>>>>selector = %@, serial = %u", NSStringFromSelector(proxy.selector), serial);
                [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
            }
        }
        
        NSString *key = [self keyByCode:[self codeOfPackage:package]];
        DriverProxy *proxy = [self proxyWithKey:key];
        if (proxy.selector && proxy.completion) {
            NSLog(@"tcp revieve key>>>>>>>>>>>>>>>selector = %@, key = %@", NSStringFromSelector(proxy.selector), key);
            [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
        }
    }
}
/**
 * 日志函数
 */
- (NSString *)format:(NSData *)data {
    static UInt8 table[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    if (!data.length) return nil;
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *res = [NSMutableString string];
    [res appendFormat:@"%c%c", table[(bytes[0] >> 4 & 0x0F)], table[(bytes[0] & 0x0F)]];
    for (int i = 1; i < data.length; ++ i) {
        [res appendFormat:@"  %c%c", table[(bytes[i] >> 4 & 0x0F)], table[(bytes[i] & 0x0F)]];
    }
    return res;
}


#pragma mark
#pragma mark 心跳处理
- (void)startBeating {
    self.beatEnable = YES;
    __weak typeof(self) wSelf = self;
    // 注册远程心跳包
    [self addBeatObserver:self mac:BroadMACAddress handler:^(NSInteger style, NSTimeInterval timeInterval) {
        NSLog(@"beat interval>>>>>>>>>>>>>>>%d", (int)timeInterval);
        [wSelf rebeatWithTimeInterval:timeInterval];
    }];
    [self beatOnce];
}
- (void)beatOnce {
    // 启动心跳，接入工作服务器
    [self invalidateBeater];
    if (NO == self.beatEnable) return;
    
    Package *package =
    [Package heart:[Package grow] mac:BroadMACAddress company:DefaultAppCompany type:DefaultAppType author:self.author];
    [self remoteSendPackage:package timeoutInterval:60];
}
- (void)stopBeating {
    self.beatEnable = NO;
    [self invalidateBeater];
    [self removeBeatObserver:self mac:BroadMACAddress];
}


#pragma mark
#pragma mark 网络处理
// 广域网
- (void)networkUtil:(NetworkUtil *)util networkStatusChanged:(NetworkStatus)status {
    if (!(status == NotReachable)) {
        _remoteOnline = NO;
        [self reconnectWithTimeinterval:0.2];
        NSLog(@"nerwork reconnect normally!!!");
    } else {
        [self disconnect];
    }
}
// 局域网
- (void)manager:(WifiManager *)manager reachabilityChanged:(NetworkStatus)status {
    if (status == ReachableViaWiFi) {
        _localOnline = NO;
        [self rebindWithTimeinterval:0.2];
    } else {
        [self close];
    }
}


#pragma mark
#pragma mark 辅助方法
// 数据包命令码
- (UInt8)codeOfPackage:(Package *)package {
    return package.code;
}
// Proxy查找(命令号)
- (id)proxyWithKey:(NSString *)key {
    return [self.proxyQueue objectForKey:key];
}
// Proxy查找(序列号)
- (XDriverProxy *)proxyWithSerial:(UInt16)serial {
    NSString *key = [self keyBySerial:serial];
    return [self.xproxyQueue objectForKey:key];
}
- (void)removeProxyWithKey:(NSString *)key {
    [self.proxyQueue removeObjectForKey:key];
}
- (void)removeProxyWithSerial:(UInt16)serial {
    NSString *key = [self keyBySerial:serial];
    [self.xproxyQueue removeObjectForKey:key];
}
// behaver查找(观察者)
- (DriverHolder *)holderWithObserver:(id)observer mac:(NSString *)mac forKey:(NSString *)key {
    NSArray *array = [self.holderQueue objectForKey:key];
    
    if (mac == nil) {
        for (DriverHolder *holder in array) {
            if (holder.observer == observer && holder.objKey == nil)
                return holder;
        }
    } else {
        for (DriverHolder *holder in array) {
            if (holder.observer == observer && [holder.objKey isEqualToString:mac])
                return holder;
        }
    }
    return nil;
}


#pragma mark
#pragma mark 扩展
// 获取工作服务器授权码
- (UInt16)author {
    return _author;
}
// key值
- (NSString *)keyByCode:(UInt8)code {
    return [NSString stringWithFormat:@"Code.%u", code];
}
// key值(序列号)
- (NSString *)keyBySerial:(UInt16)serial {
    return [NSString stringWithFormat:@"SNO.%u", serial];
}
// Completion查找
- (NSArray *)handlersWithKey:(NSString *)key mac:(NSString *)mac {
    NSMutableArray *array = [self.holderQueue objectForKey:key];
    NSMutableArray *handlers = [NSMutableArray array];
    if (mac == nil) {
        for (DriverHolder *holder in array) {
            if (holder.observer && holder.objKey == nil) {
                if (holder.handler) [handlers addObject:holder.handler];
            }
        }
    } else {
        for (DriverHolder *holder in array) {
            if (holder.observer && (holder.objKey == nil || [holder.objKey isEqualToString:mac])) {
                if (holder.handler) [handlers addObject:holder.handler];
            }
        }
    }
    
    return [NSArray arrayWithArray:handlers];
}
// Observer添加/移除
- (void)removeObserver:(id)observer mac:(NSString *)mac forKey:(NSString *)key {
    NSMutableArray *array = [self.holderQueue objectForKey:key];
    
    if (mac == nil) {
        for (int i = (int)array.count - 1; i >= 0; -- i) {
            DriverHolder *holder = [array objectAtIndex:i];
            if (holder.observer == nil || holder.handler == nil) {
                [array removeObjectAtIndex:i];
            } else if (holder.observer == observer && holder.objKey == nil) {
                [array removeObject:holder]; break;
            }
        }
    } else {
        for (int i = (int)array.count - 1; i >= 0; -- i) {
            DriverHolder *holder = [array objectAtIndex:i];
            if (holder.observer == nil || holder.handler == nil) {
                [array removeObjectAtIndex:i];
            } else if (holder.observer == observer && [holder.objKey isEqualToString:mac]) {
                [array removeObjectAtIndex:i]; break;
            }
        }
    }
}
- (void)addObserver:(id)observer mac:(NSString *)mac forKey:(NSString *)key handler:(id)handler {
    if ([self holderWithObserver:observer mac:mac forKey:key]) return;
    
    NSMutableArray *array = [self.holderQueue objectForKey:key];
    if (!array) {
        array = [NSMutableArray array];
        [self.holderQueue setObject:array forKey:key];
    }
    
    DriverHolder *holder = [[DriverHolder alloc] initWithObserver:observer objKey:mac handler:handler];
    [array addObject:holder];
}
// Parser查找
- (id)parserWithKey:(NSString *)key {
    DriverProxy *proxy = [self proxyWithKey:key];
    return proxy.completion;
}
// Parser添加
- (void)setSelector:(SEL)selector parser:(id)parser forKey:(NSString *)key {
    DriverProxy *proxy = [[DriverProxy alloc] initWithKey:key selector:selector completion:parser];
    [self.proxyQueue setObject:proxy forKey:key];
}
// Parser查找(序列号)
- (id)parserWithSerial:(UInt16)serial {
    DriverProxy *proxy = [self proxyWithSerial:serial];
    return proxy.completion;
}


#pragma mark
#pragma mark 报文回调注册
/**
 * 注册发送广播
 * 观察者对感兴趣的事件和设备进行注册
 * 参数 observer 观察者，当为空时，注册失败
 * 参数 mac 设备mac地址，地址为nil时表示注册所有设备
 * 参数 handler 完成时回调
 * 参数 style 表示局域网/互联网
 */
// 注册发现包
- (void)removeFinderObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfFinder];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addFinderObserver:(id)observer mac:(NSString *)mac handler:(FinderHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfFinder];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(finder:completion:) parser:^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author, id obj){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (FinderHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(imac, ip, company, type, author, obj);
            });
        }
    } forKey:key];
}


// 注册设备信息查询反馈
- (void)removeQueryObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfQuery];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addQueryObserver:(id)observer mac:(NSString *)mac handler:(QueryHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfQuery];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(query:completion:) parser:^(NSString *imac, NSInteger style, NSString *hardVer, NSString *softVer, NSString *nickName){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (QueryHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(style, hardVer, softVer, nickName);
            });
        }
    } forKey:key];
}


// 注册设备心跳反馈
- (void)removeBeatObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfHeart];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addBeatObserver:(id)observer mac:(NSString *)mac handler:(BeatHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfHeart];
    // 添加waiter
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(heart:completion:) parser:^(NSString *imac, NSInteger style, NSTimeInterval timeInterval){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (BeatHandler handler in array) {
            handler(style, timeInterval);
        }
    } forKey:key];
}


// 注册设备锁定反馈
- (void)removeUlockObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfLock];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addUlockObserver:(id)observer mac:(NSString *)mac handler:(UlockHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfLock];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(ulock:completion:) parser:^(NSString *imac, BOOL lock, UInt8 result){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (UlockHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(lock);
            });
        }
    } forKey:key];
}


// 注册设备重命名反馈
- (void)removeRenameObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfRename];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addRenameObserver:(id)observer mac:(NSString *)mac handler:(RenameHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfRename];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(rename:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result) {
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (RenameHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        }
    } forKey:key];
}


// 注册设备固件升级反馈
- (void)removeFirmwareUpdateObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfFirUpdate];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addFirmwareUpdateObserver:(id)observer mac:(NSString *)mac handler:(FirmwareUpdateHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfFirUpdate];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(firmwareUpdate:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (FirmwareUpdateHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        }
    } forKey:key];
}

// 注册固件版本反馈
- (void)removeFirmwareVerObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfAskFirVersion];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addFirmwareVerObserver:(id)observer mac:(NSString *)mac handler:(FirmwareVerHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfAskFirVersion];
    // 添加handler
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加处理代理
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(firmwareVersion:completion:) parser:^(NSString *imac, NSString *softVer, NSString *url){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (FirmwareVerHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(imac, softVer, url);
            });
        }
    } forKey:key];
}


// 注册设备远程在/离线
- (void)removeOnlineQueryObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfOnlineQuery];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addOnlineQueryObserver:(id)observer mac:(NSString *)mac handler:(OnlineQueryHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfOnlineQuery];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(onlineQuery:completion:) parser:^(NSString *imac, UInt8 status) {
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (OnlineQueryHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(status);
            });
        }
    } forKey:key];
}

// 注册接入工作服务器的反馈
- (void)removeJoinObserver:(id)observer {
    NSString *key = [self keyByCode:CodeOfAskAccess];
    [self removeObserver:observer mac:nil forKey:key];
}
- (void)addJoinObserver:(id)observer handler:(JoinHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfAskAccess];
    // 添加behaver
    [self addObserver:observer mac:nil forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(joinWorkServer:completion:) parser:^(NSString *imac, UInt8 result){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (JoinHandler handler in array) {
            handler(0x00 == result);
        }
    } forKey:key];
}

// 订阅设备事件
- (void)removeOnlineUpdateObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfOnlineUpdate];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addOnlineUpdateObserver:(id)observer mac:(NSString *)mac handler:(OnlineUpdateHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfOnlineUpdate];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(onlineUpdate:completion:)
               parser:^(NSString *imac, UInt8 reserved, UInt8 status){
                   NSArray *array = [wSelf handlersWithKey:key mac:imac];
                   for (OnlineUpdateHandler handler in array) {
                       dispatch_async_main_safe(^{
                           handler(status);
                       });
                   }
               } forKey:key];
}

// 注册订阅事件
- (void)removeSubscribeObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyByCode:CodeOfSubscribe];
    [self removeObserver:observer mac:mac forKey:key];
}
- (void)addSubscribeObserver:(id)observer mac:(NSString *)mac handler:(SubscribeHandler)handler {
    if (!handler) return;
    NSString *key = [self keyByCode:CodeOfSubscribe];
    // 添加behaver
    [self addObserver:observer mac:mac forKey:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) wSelf = self;
    [self setSelector:@selector(subscribe:completion:) parser:^(NSString *imac, UInt8 result){
        NSArray *array = [wSelf handlersWithKey:key mac:imac];
        for (SubscribeHandler handler in array) {
            dispatch_async_main_safe(^{
                handler(0x00 == result);
            });
        }
    } forKey:key];
}


#pragma mark
#pragma mark 数据包


/**
 * 数据包
 * 发送响应数据包
 * 部分数据包仅局域网发送，部分仅因特网发送，其他的则局域网有限（设备局域网在线则只局域网，否则考虑因特网，如果因特网也不在线，则不发送）
 * 参数 device 设备
 * 参数 mac 设备mac地址
 * 参数 handler 接收到反馈是回调
 * 参数 badHandler 异常时回调, 包括超时
 * 参数 timeoutInterval 超时时间(发送到接收的时间)
 */
- (void)finderWithTimeoutInterval:(NSTimeInterval)timeoutInterval {
    [self finderWithHandler:nil badHandler:nil timeoutInterval:timeoutInterval];
}
- (void)finderWithDevice:(WifiDevice *)device timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self finderWithDevice:device handler:nil badHandler:nil timeoutInterval:timeoutInterval];
}
- (void)finderWithMACAddress:(NSString *)mac timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self finderWithMACAddress:mac handler:nil badHandler:nil timeoutInterval:timeoutInterval];
}
- (void)finderWithHandler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self finderWithMACAddress:BroadMACAddress handler:handler badHandler:badHandler timeoutInterval:timeoutInterval];
}
- (void)finderWithDevice:(WifiDevice *)device handler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    [self finderWithMACAddress:device.mac handler:handler badHandler:badHandler timeoutInterval:timeoutInterval];
}
- (void)finderWithMACAddress:(NSString *)mac handler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSString *broadIPAddress = WifiManagerInstance.broadAddress;
    [self finderWithMACAddress:mac host:broadIPAddress handler:handler badHandler:badHandler timeoutInterval:timeoutInterval];
}
- (void)finderWithMACAddress:(NSString *)mac host:(NSString *)host handler:(FinderHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.localOnline) {
        Package *package = [Package finder:[Package grow] mac:mac company:DefaultDeviceCompany type:DefaultDeviceType author:DefaultDeviceAuthor];
        // 发送数据
        [self localSendPackage:package host:host selector:@selector(finder:completion:) parser:handler ? ^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author, id obj) {
            dispatch_async_main_safe(^{
                handler(imac, ip, company, type, author, obj);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x62查询设备信息包，局域网/因特网，handler(基于序列号，可为nil)
- (void)queryWithDevice:(WifiDevice *)device handler:(QueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package query:[Package grow] mac:device.mac company:device.company type:device.type author:device.author];
        [self localSendPackage:package host:device.ip selector:@selector(query:completion:) parser:handler ? ^(NSString *imac, NSInteger style, NSString *hardVer, NSString *softVer, NSString *nickName) {
            dispatch_async_main_safe(^{
                handler(style, hardVer, softVer, nickName);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package query:[Package grow] mac:device.mac company:device.company type:device.type author:device.author];
        [self remoteSendPackage:package selector:@selector(query:completion:) parser:handler ? ^(NSString *imac, NSInteger style, NSString *hardVer, NSString *softVer, NSString *nickName) {
            dispatch_async_main_safe(^{
                handler(style, hardVer, softVer, nickName);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x61局域网心跳包，局域网，handler(基于序列号，可为nil)
- (void)beatWithDevice:(WifiDevice *)device handler:(BeatHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.localOnline) {
        Package *package = [Package heart:[Package grow] mac:device.mac company:device.company type:device.type author:device.author];
        [self localSendPackage:package host:device.ip selector:@selector(heart:completion:) parser:handler ? ^(NSString *imac, NSInteger style, NSTimeInterval timeInterval) {
            dispatch_async_main_safe(^{
                handler(style, timeInterval);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x24锁定设备包，局域网，handler(基于序列号，可为nil)
- (void)lockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.localOnline) {
        Package *package = [Package ulock:[Package grow] mac:device.mac company:device.company type:device.type author:device.author lock:YES];
        [self localSendPackage:package host:device.ip selector:@selector(ulock:completion:) parser:handler ? ^(NSString *imac, BOOL lock, UInt8 result) {
            // 因为是序列号, 直接使用结果就可以
            dispatch_async_main_safe(^{
                handler(YES == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}
- (void)unlockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.localOnline) {
        Package *package = [Package ulock:[Package grow] mac:device.mac company:device.company type:device.type author:device.author lock:NO];
        [self localSendPackage:package host:device.ip selector:@selector(ulock:completion:) parser:handler ? ^(NSString *imac, BOOL lock, UInt8 result) {
            // 因为是序列号, 直接使用结果就可以
            dispatch_async_main_safe(^{
                handler(YES == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x63设备重命名包，局域网/因特网，handler(基于序列号，可为nil)
- (void)renameWithDevice:(WifiDevice *)device name:(NSString *)name handler:(RenameHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (device.localOnline) {
        Package *package = [Package rename:[Package grow] mac:device.mac company:device.company type:device.type author:device.author name:name];
        [self localSendPackage:package host:device.ip selector:@selector(rename:completion:) parser:handler ? ^(NSString *imac, NSInteger style, UInt8 result) {
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package rename:[Package grow] mac:device.mac company:device.company type:device.type author:device.author name:name];
        [self remoteSendPackage:package selector:@selector(rename:completion:) parser:handler ? ^(NSString *imac, NSInteger style, UInt8 result) {
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 设备固件版本报文，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareVerWithDevice:(WifiDevice *)device handler:(FirmwareVerHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeoutInterval {
    if (self.remoteOnline) {
        Package *package = [Package firmwareVersion:[Package grow] mac:device.mac company:device.company type:device.type author:device.author];
        [self remoteSendPackage:package selector:@selector(firmwareVersion:completion:) parser:handler ? ^(NSString *imac, NSString *softVer, NSString *url) {
            dispatch_async_main_safe(^(){
                handler(imac, softVer, url);
            });
        } : nil badHandler:badHandler timeoutInterval:timeoutInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^(){ badHandler(ServiceOfflineError);});
        }
    }
}

// 0x64设备固件升级包，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareUpdateWithDevice:(WifiDevice *)device url:(NSString *)url handler:(FirmwareUpdateHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval {
    if (device.localOnline) {
        Package *package = [Package firmwareUpdate:[Package grow] mac:device.mac company:device.company type:device.type author:device.author url:url];
        [self localSendPackage:package host:device.ip selector:@selector(firmwareUpdate:completion:) parser:handler ? ^(NSString *imac, NSInteger style, UInt8 result){
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeouInterval];
    } else if (self.remoteOnline) {
        Package *package = [Package firmwareUpdate:[Package grow] mac:device.mac company:device.company type:device.type author:device.author url:url];
        [self remoteSendPackage:package selector:@selector(firmwareUpdate:completion:) parser:handler ? ^(NSString *imac, NSInteger style, UInt8 result){
            dispatch_async_main_safe(^{
                handler(style, 0x00 == result);
            });
        } : nil badHandler:badHandler timeoutInterval:timeouInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x83查询设备是否远程在线，因特网，handler(基于序列号，可为nil)
- (void)onlineQueryWithDevice:(WifiDevice *)device handler:(OnlineQueryHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval {
    if (self.remoteOnline) {
        Package *package = [Package onlineQuery:[Package grow] mac:device.mac company:device.company type:device.type author:device.author];
        [self remoteSendPackage:package selector:@selector(onlineQuery:completion:) parser:handler ? ^(NSString *imac, UInt8 status){
            dispatch_async_main_safe(^{
                handler(status);
            });
        } : nil badHandler:badHandler timeoutInterval:timeouInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

// 0x84订阅设备事件，因特网，handler(基于序列号，可为nil)
- (void)subscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler badHandler:(ServiceBadHandler)badHandler timeoutInterval:(NSTimeInterval)timeouInterval {
    if (self.remoteOnline) {
        Package *package = [Package subscribe:[Package grow] mac:device.mac company:device.company type:device.type author:device.author code:CodeOfOnlineUpdate enable:enable];
        [self remoteSendPackage:package selector:@selector(subscribe:completion:) parser:(handler ? ^(NSString *imac, UInt8 result){
            dispatch_async_main_safe(^{
                handler(0x00 == result);
            });
        } : nil) badHandler:badHandler timeoutInterval:timeouInterval];
    } else {
        if (badHandler) {
            dispatch_async_main_safe(^{ badHandler(ServiceOfflineError); });
        }
    }
}

@end
