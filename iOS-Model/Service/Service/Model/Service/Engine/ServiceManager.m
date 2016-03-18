//
//  ServiceManager.m
//  AirCleaner
//
//  Created by Shaojun Han on 10/16/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "ServiceManager.h"

#define FIEXD_HEADER_LENGTH     9
#define TAG_FIEXD_LENGTH_HEADER 10890
#define TAG_FLEX_LENGTH_BODY    20890

#define BroadMacAddress @"FFFFFFFFFFFF"

/**
 * 代理回调类
 */
@interface DriverProxy : NSObject

@property (strong, nonatomic) NSDate    *date;          // 创建日期
@property (assign, nonatomic) SEL       selector;       // 解析包方法
@property (copy, nonatomic)   id        completion;     // 回调

- (instancetype)init;

@end

@implementation DriverProxy

- (instancetype)init {
    if (self = [super init]) {
        _date = [NSDate date];
    }
    return self;
}

@end

/**
 * 回调类
 */
@interface DriverKeeper : NSObject

@property (weak, nonatomic) id          observer;       // 观察者
@property (copy, nonatomic) id          completion;     // 回调block
@property (copy, nonatomic) NSString    *mac;           // MAC地址
@property (strong, nonatomic) NSDate    *date;          // 创建日期

- (instancetype)initWithObserver:(id)observer mac:(NSString *)mac handler:(id)handler;

@end

@implementation DriverKeeper

- (instancetype)init {
    if (self = [super init]) {
        _date = [NSDate date];
    }
    return self;
}

- (instancetype)initWithObserver:(id)observer mac:(NSString *)mac handler:(id)handler {
    if (self = [self init]) {
        self.mac = mac;
        self.observer = observer;
        self.completion = handler;
    }
    return self;
}

@end

/**
 * 服务驱动类
 * 实现
 */
// 代理
@interface ServiceManager ()
<
    LocalServiceDelegate,
    RemoteServiceDelegate,
    NetworkUtilDelegate,
    WifiManagerDelegate
>
@end

@interface ServiceManager ()

@property (strong, nonatomic) dispatch_source_t resolveTimer;
@property (strong, nonatomic) dispatch_source_t beatTimer;
@property (strong, nonatomic) dispatch_source_t bindTimer;

@end

// 网络与处理
@interface ServiceManager ()

@property (strong, nonatomic) NSMutableDictionary *xproxyQueue;  // 处理队列(序列号)
@property (strong, nonatomic) NSMutableDictionary *keeperQueue;  // handler队列(观察者)
@property (strong, nonatomic) NSMutableDictionary *proxyQueue;   // 处理队列(观察者)

@property (strong, nonatomic) LocalService *localService;
@property (strong, nonatomic) RemoteService *remoteService;
@property (strong, nonatomic) RemoteService *resolveService;

@end

// 远程TCP心跳
@interface ServiceManager ()

@property (assign, nonatomic) BOOL  beatEnable;

@end

// 接入工作服务器
@interface ServiceManager ()

@property (assign, nonatomic) UInt16 author;
@property (copy, nonatomic) NSString *account;  // 工作服务器用户名
@property (copy, nonatomic) NSString *key;      // 工作服务器密码

@end

@implementation ServiceManager

+ (instancetype)sharedInstance {
    static ServiceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ServiceManager new];
    });
    return manager;
}

- (void)dealloc {
    [self removeReachableService];
}

// 初始化函数
- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *sslMoreSettings = @{GCDAsyncSocketSSLProtocolVersionMin:[NSNumber numberWithInt:2], GCDAsyncSocketSSLProtocolVersionMax:[NSNumber numberWithInt:8], GCDAsyncSocketManuallyEvaluateTrust:[NSNumber numberWithBool:YES]};
        NSDictionary *sslSettings = [SSLManager sslSettingsWithHost:AddressOflevelingServer file:SSLCertificateFile key:SSLCertificatePassword other:sslMoreSettings];
        
        _xproxyQueue = [NSMutableDictionary dictionary];
        _keeperQueue = [NSMutableDictionary dictionary];
        _proxyQueue = [NSMutableDictionary dictionary];
        
        _localService = [[LocalService alloc] initWithDelegate:self];
        _remoteService = [[RemoteService alloc] initWithDelegate:self sslSettings:sslSettings trustHandler:nil];
        _resolveService = [[RemoteService alloc] initWithDelegate:self sslSettings:sslSettings trustHandler:nil];
    }
    return self;
}

/**
 * 注册网络服务
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
 * 停止
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
 * 启动
 * 保留最后的启动
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
#pragma mark 本地(绑定/关闭)
/**
 * 绑定本地服务
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
    
    self.localOnline = NO;
    [self.localService close];
}

#pragma mark
#pragma mark 远程(连接/断开)
/**
 * 远程服务接入
 */
- (void)connect {
    [self disconnect];
    [self reconnectWithTimeinterval:0];
}
- (void)reconnect {
    if (!(self.account && self.key)) return;
    [self.resolveService connectToHost:AddressOflevelingServer
                                  port:PortOflevelingServer];
}
- (void)disconnect {
    [self stopBeating];
    [self invalidateResolver];
    
    self.remoteOnline = NO;
    [self.resolveService disConnect];
    [self.remoteService disConnect];
}

/**
 * 对处理队列清理
 */
- (void)clear {
    [self.keeperQueue removeAllObjects];
    [self.proxyQueue removeAllObjects];
    [self.xproxyQueue removeAllObjects];
}
- (void)lightClear {
    NSMutableArray *list = [NSMutableArray array];
    NSMutableArray *klist = [NSMutableArray array];
    for (NSString *key in self.keeperQueue) {
        NSMutableArray *array = [self.keeperQueue objectForKey:key];
        
        for (int i = 0; i < array.count; ++ i) {
            DriverKeeper *keeper = [array objectAtIndex:i];
            if (!keeper.observer) [list addObject:keeper];
        }
        
        if (list.count) {
            [array removeObjectsInArray:list];
            [list removeAllObjects];
        }
        
        if (array.count < 1) [klist addObject:key];
    }
    if (klist.count) {
        [self.keeperQueue removeObjectsForKeys:klist];
    }
}

#pragma mark
#pragma mark 服务器连接处理
- (void)reconnectWithTimeinterval:(NSTimeInterval)interval {
    [self stopBeating];
    [self startResolveWithTimeinterval:interval];
}
- (void)invalidateBinder {
    if(self.bindTimer) dispatch_source_cancel(self.bindTimer);
}
- (void)rebindWithTimeinterval:(NSTimeInterval)interval {
    [self invalidateBinder];
    __weak typeof(self) weakSelf = self;
    self.bindTimer = [self scheduledWithTimeinterval:interval action:^{
        [weakSelf invalidateBinder];
        [weakSelf rebind];
    }];
}
- (void)invalidateResolver {
    if(self.resolveTimer) dispatch_source_cancel(self.resolveTimer);
}
// 启动重连接计时器
- (void)startResolveWithTimeinterval:(NSTimeInterval)interval {
    [self invalidateResolver];
    __weak typeof(self) weakSelf = self;
    self.resolveTimer = [self scheduledWithTimeinterval:interval action:^{
        [weakSelf invalidateResolver];
        [weakSelf reconnect];
    }];
}
- (void)invalidateBeater {
    if (self.beatTimer) dispatch_source_cancel(self.beatTimer);
}
- (void)startBeatWithTimeInterval:(NSTimeInterval)interval {
    [self invalidateBeater];
    __weak typeof(self) weakSelf = self;
    self.beatTimer = [self scheduledWithTimeinterval:interval action:^{
        [weakSelf invalidateBeater];
        [weakSelf beatOnce];
    }];
}
- (dispatch_source_t)scheduledWithTimeinterval:(NSTimeInterval)timeinterval action:(dispatch_block_t)action {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, timeinterval * NSEC_PER_SEC),
                              timeinterval * NSEC_PER_SEC, 0.2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{ action(); });
    dispatch_resume(timer);
    return timer;
}

#pragma mark
#pragma mark 发送数据
// 发送数据
- (void)localSendPackage:(Package *)package host:(NSString *)host {
    if (host.length < 1) return;    // 非法的主机
    [self.localService sendPacket:[package data] toHost:host port:PortOflocalService timeoutInterval:60.0];
}
- (void)localSendPackage:(Package *)package host:(NSString *)host port:(UInt16)port {
    if (host.length < 1) return;    // 非法的主机
    [self.localService sendPacket:[package data] toHost:host port:port timeoutInterval:60.0];
}
- (void)remoteSendPackage:(Package *)package {
    [self.remoteService sendPacket:[package data] timeoutInterval:60.0];
}

#pragma mark
#pragma mark Local代理
- (void)localService:(LocalService *)service didRecieve:(NSData *)data address:(NSString *)address {
    Package *package = [[Package alloc] initWithData:data style:PackageByLocal mark:address];
    if (![Package isRecieveOkay:package]) return;   // 过滤本机或其他手机广播包
    
    if ([Package isSerialOkay:package]) {
        DriverProxy *proxy = [self proxyWithSerial:[package serial]];
        if (proxy.selector && proxy.completion) {    // performSelector: 和普通的消息发送时等价的
            [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
        }
    }
    
    UInt8 code = [self codeOfPackage:package];
    DriverProxy *proxy = [self proxyWithCode:code];
    NSLog(@"udp revieve key>>>>>>>>>>selector = %@, key = Code.%u, code = %d, %@",
          NSStringFromSelector(proxy.selector), code, code, package.raw);
    if (proxy.selector && proxy.completion) {   // performSelector: 和普通的消息发送时等价的
        [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
    }
}
- (void)localServiceDidClose:(LocalService *)service error:(NSError *)error {
    self.localOnline = NO;
    dispatch_async(dispatch_get_main_queue(), ^{ // 发送UDP离线通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ServiceLocalOffline object:nil];
    });
    // 正常断开
    if (error == nil) return;
    // 尝试重新连接
    [self rebindWithTimeinterval:30];
}
- (void)localServiceDidNotBind:(LocalService *)service error:(NSError *)error {
    NSLog(@"bind>>>>>>>>>%@", @"绑定失败");
    self.localOnline = NO;
}
- (void)localServiceDidBind:(LocalService *)service {
    [self invalidateBinder];
    NSLog(@"bind>>>>>>>>> %@", @"绑定成功");
    self.localOnline = YES;
    dispatch_async(dispatch_get_main_queue(), ^{ // 发送UDP在线通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ServiceLocalOnline object:nil];
    });
}

#pragma mark
#pragma mark Remote代理
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
- (void)remoteServiceDidConnect:(RemoteService *)service {
    [self invalidateResolver];
    // 判断是否连接工作服务器
    if (service == self.resolveService) {
        // 发送解析工作服务器数据包
        [self.resolveService recieveDataToSize:FIEXD_HEADER_LENGTH tag:TAG_FIEXD_LENGTH_HEADER];
        
        UInt16 serial = [Package grow];
        Package *package = [Package resolveWorkServer:serial
                                              company:CodeOfAppCompany type:CodeOfAppType author:CodeOfAppAuthor];
        [self.resolveService sendPacket:[package data]];
        
    } else if (service == self.remoteService) {
        // 启动心跳，接入工作服务器
        [self.remoteService recieveDataToSize:FIEXD_HEADER_LENGTH tag:TAG_FIEXD_LENGTH_HEADER];
        [self joinWorkServer];
    }
}
- (void)remoteServiceDidDisconnect:(RemoteService *)service error:(NSError *)error {
    if (service == self.remoteService) {
        self.remoteOnline = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ServiceRemoteOffline object:nil];
        });
    }
    
    if (error == nil) { NSLog(@"remote disconnect normally."); return; }
    if (service == self.remoteService) {
        // TCP连接失败，30后重新连接
        NSLog(@"disconnect abnormally!!!");
        [self reconnectWithTimeinterval:30];
    } else if (self.resolveService == service) {
        // 解析过程中关停
        self.remoteOnline = NO;
        // TCP连接失败，30后重新连接
        [self reconnectWithTimeinterval:30];
    }
}
- (void)remoteServiceDidNotConnect:(RemoteService *)service error:(NSError *)error {
    self.remoteOnline = NO;
    // 解析过程中关停
    // TCP连接失败，30后重新连接
    [self reconnectWithTimeinterval:30];
}

- (void)joinWorkServer {
    UInt16 serial = [Package grow];
    // 注册接入工作服务器的反馈
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(joinWorkServer:completion:) parser:^(NSString *imac, UInt8 result) {
        NSLog(@"tcp join work server>>>>>>>>>>>>>%d", result);
        if (!(0x00 == result)) {
            [weakSelf reconnectWithTimeinterval:30];
        } else {
            weakSelf.remoteOnline = YES;
            [weakSelf startBeating];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ServiceRemoteOnline object:nil];
            });
        }
    } serial:serial];
    
    NSLog(@"It's going to join work server with account = %@, key = %@......", self.account, self.key);
    Package *package = [Package joinWorkServer:serial account:self.account key:self.key
                                       company:CodeOfAppCompany type:CodeOfAppType author:self.author
                                      joinCode:CodeOfAppAccessKey joinSize:sizeof(CodeOfAppAccessKey)];
    [self remoteSendPackage:package];
}

// 数据处理
- (void)handleRemoteRecieve:(RemoteService *)service data:(NSData *)data {
    if (service == self.resolveService) {
        // 工作服务器解析完成
        Package *package = [[Package alloc] initWithData:data];
        __weak typeof(self) weakSelf = self;
        [Package resolveWorkServer:package completion:^(NSString *mac, NSString *ip, UInt16 port, UInt16 author) {
            [weakSelf invalidateResolver];
            [service disConnect];
            NSLog(@"tcp resolve ok>>>>>>>>>>ip = %@, port = %d", ip, port);
            weakSelf.author = author;
            [weakSelf.remoteService connectToHost:ip port:port];
        }];
    } else if (service == self.remoteService) {
        Package *package = [[Package alloc] initWithData:data style:PackageByRemote];
        if (![Package isRecieveOkay:package]) return;   // 过滤本机或其他手机广播包
        
        if ([Package isSerialOkay:package]) {
            DriverProxy *proxy = [self proxyWithSerial:[package serial]];
            if (proxy.selector && proxy.completion) {
                [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
            }
        }
        
        UInt8 code = [self codeOfPackage:package];
        DriverProxy *proxy = [self proxyWithCode:code];
        NSLog(@"tcp revieve key>>>>>>>>>>selector = %@, key = Code.%u, code = %d, %@",
              NSStringFromSelector(proxy.selector), code, code, package.raw);
        if (proxy.selector && proxy.completion) {
            [Package performSelector:proxy.selector withObject:package withObject:proxy.completion];
        }
    }
}


#pragma mark
#pragma mark 心跳处理
- (void)startBeating {
    self.beatEnable = YES;
    __weak typeof(self) weakSelf = self;
    [self addBeatObserver:self mac:BroadMacAddress handler:^(NSInteger style, NSTimeInterval timeInterval) {
        NSLog(@"beat interval>>>>>>>>>>%d", (int)timeInterval);
        [weakSelf startBeatWithTimeInterval:timeInterval];
    }];
    [self beatOnce];
}
- (void)beatOnce {
    // 启动心跳，接入工作服务器
    [self invalidateBeater];
    if (NO == self.beatEnable) return;
    
    UInt16 serial = [Package grow];
    Package *package = [Package heart:serial mac:BroadMacAddress company:CodeOfAppCompany
                                 type:CodeOfAppType author:self.author];
    // 注册远程心跳包
    [self remoteSendPackage:package];
}
- (void)stopBeating {
    self.beatEnable = NO;
    [self invalidateBeater];
    [self removeBeatObserver:self mac:BroadMacAddress];
}


#pragma mark
#pragma mark 网络处理
// 广域网
- (void)networkUtil:(NetworkUtil *)util networkStatusChanged:(NetworkStatus)status {
    if (!(status == NotReachable)) {
        self.remoteOnline = NO;
        [self reconnectWithTimeinterval:2.0];
        NSLog(@"nerwork reconnect normally!!!");
    } else {
        [self disconnect];
    }
}
// 局域网
- (void)manager:(WifiManager *)manager reachabilityChanged:(NetworkStatus)status {
    if (status == ReachableViaWiFi) {
        self.localOnline = NO;
        [self rebindWithTimeinterval:2.0];
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
// Keeper查找(观察者)
- (DriverKeeper *)keeperWithObserver:(id)observer mac:(NSString *)mac key:(NSString *)key {
    NSArray *array = [self.keeperQueue objectForKey:key];
    
    if (mac == nil) {
        for (DriverKeeper *object in array) {
            if (object.observer == observer && object.mac == nil)
                return object;
        }
    } else {
        for (DriverKeeper *object in array) {
            if (object.observer == observer && [object.mac isEqualToString:mac])
                return object;
        }
    }
    return nil;
}
// Proxy查找(命令号)
- (id)proxyWithKey:(NSString *)key {
    return [self.proxyQueue objectForKey:key];
}
- (id)proxyWithCode:(UInt8)code {
    NSString *key = [self keyWithCode:code];
    return [self.proxyQueue objectForKey:key];
}
// Proxy查找(序列号)
- (DriverProxy *)proxyWithSerial:(UInt16)serial {
    NSString *key = [self keyWithSerial:serial];
    DriverProxy *proxy = [self.xproxyQueue objectForKey:key];
    
    NSDate *date = [NSDate date];
    NSMutableArray *list = [NSMutableArray arrayWithObject:key];
    [self.xproxyQueue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DriverProxy *proxy = (DriverProxy *)obj;
        if ([date timeIntervalSinceDate:proxy.date] > 60.0) {
            [list addObject:key];
        }
    }];
    [list addObject:key];
    [self.xproxyQueue removeObjectsForKeys:list];
    
    return proxy;
}


#pragma mark
#pragma mark 扩展
// key值
- (NSString *)keyWithCode:(UInt8)code {
    return [NSString stringWithFormat:@"Code.%u", code];
}
- (NSString *)keyWithSerial:(UInt16)serial {
    return [NSString stringWithFormat:@"SNO.%u", serial];
}
// Completion查找
- (NSArray *)handlerWithKey:(NSString *)key mac:(NSString *)mac {
    NSMutableArray *array = [self.keeperQueue objectForKey:key];
    NSMutableArray *list = [NSMutableArray array];
    if (mac == nil) {
        for (DriverKeeper *keeper in array) {
            if (keeper.observer && keeper.mac == nil) {
                [list addObject:keeper.completion];
            }
        }
    } else {
        for (DriverKeeper *keeper in array) {
            if (keeper.observer && (keeper.mac == nil || [keeper.mac isEqualToString:mac])) {
                [list addObject:keeper.completion];
            }
        }
    }

    return list;
}
// Observer添加/移除
- (void)removeObserver:(id)observer mac:(NSString *)mac key:(NSString *)key {
    NSMutableArray *array = [self.keeperQueue objectForKey:key];
    
    if (mac == nil) {
        for (int i = (int)array.count - 1; i >= 0; -- i) {
            DriverKeeper *handler = [array objectAtIndex:i];
            if (handler.observer == nil || handler.completion == nil) {
                [array removeObjectAtIndex:i];
            } else if (handler.observer == observer && handler.mac == nil) {
                [array removeObject:handler]; break;
            }
        }
    } else {
        for (int i = (int)array.count - 1; i >= 0; -- i) {
            DriverKeeper *handler = [array objectAtIndex:i];
            if (handler.observer == nil || handler.completion == nil) {
                [array removeObjectAtIndex:i];
            } else if (handler.observer == observer && [handler.mac isEqualToString:mac]) {
                [array removeObjectAtIndex:i]; break;
            }
        }
    }
}
- (void)addObserver:(id)observer mac:(NSString *)mac key:(NSString *)key handler:(id)handler {
    if ([self keeperWithObserver:observer mac:mac key:key]) return;
    
    NSMutableArray *array = [self.keeperQueue objectForKey:key];
    if (!array) {
        array = [NSMutableArray array];
        [self.keeperQueue setObject:array forKey:key];
    }
    
    DriverKeeper *keeper = [[DriverKeeper alloc] initWithObserver:observer mac:mac handler:handler];
    [array addObject:keeper];
}
// Parser查找
- (id)parserWithCode:(UInt8)code {
    DriverProxy *proxy = [self proxyWithCode:code];
    return proxy.completion;
}
// Parser添加
- (void)addSelector:(SEL)selector parser:(id)parser code:(UInt8)code {
    NSString *key = [self keyWithCode:code];
    DriverProxy *proxy = [[DriverProxy alloc] init];
    proxy.selector = selector;
    proxy.completion = parser;
    [self.proxyQueue setObject:proxy forKey:key];
}
- (void)addSelector:(SEL)selector parser:(id)parser serial:(UInt16)serial {
    NSString *key = [self keyWithSerial:serial];
    DriverProxy *proxy = [[DriverProxy alloc] init];
    proxy.selector = selector;
    proxy.completion = parser;
    [self.xproxyQueue setObject:proxy forKey:key];
}


#pragma mark
#pragma mark 报文回调注册
/**
 * 注册发送广播
 * 观察者对感兴趣的事件和设备进行注册
 * 参数 observer 观察者，当为空时，注册失败
 * 参数 device 设备，为空时是所有设备
 * 参数 mac 设备mac地址，地址为nil时表示注册所有设备
 * 参数 completion 完成时回调
 */
// 注册发现包
- (void)removeFinderObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfFinder];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addFinderObserver:(id)observer mac:(NSString *)mac handler:(FinderHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfFinder];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(finder:completion:)
               parser:^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (FinderHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(imac, ip, company, type, author);
            });
        }
    } code:CodeOfFinder];
}


// 注册设备信息查询反馈
- (void)removeQueryObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfQuery];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addQueryObserver:(id)observer mac:(NSString *)mac handler:(QueryHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfQuery];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(query:completion:)
               parser:^(NSString *imac, NSInteger style, NSString *hardVersion, NSString *softVersion, NSString *nickName){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (QueryHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(style, hardVersion, softVersion, nickName);
            });
        }
    } code:CodeOfQuery];
}


// 注册设备心跳反馈
- (void)removeBeatObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfHeart];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addBeatObserver:(id)observer mac:(NSString *)mac handler:(BeatHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfHeart];
    // 添加waiter
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(heart:completion:) parser:^(NSString *imac, NSInteger style, NSTimeInterval timeInterval){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (BeatHandler handler in array) {
            handler(style, timeInterval);
        }
    } code:CodeOfHeart];    
}


// 注册设备锁定反馈
- (void)removeUlockObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfLock];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addUlockObserver:(id)observer mac:(NSString *)mac handler:(UlockHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfLock];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(ulock:completion:) parser:^(NSString *imac, BOOL lock, UInt8 result){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (UlockHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(lock);
            });
        }
    } code:CodeOfLock];
}


// 注册设备重命名反馈
- (void)removeRenameObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfRename];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addRenameObserver:(id)observer mac:(NSString *)mac handler:(RenameHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfRename];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(rename:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result) {
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (RenameHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(style, 0x00 == result);
            });
        }
    } code:CodeOfRename];
}


// 注册设备固件升级反馈
- (void)removeFirmwareUpdateObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfFirUpdate];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addFirmwareUpdateObserver:(id)observer mac:(NSString *)mac handler:(FirmwareUpdateHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfFirUpdate];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(firmwareUpdate:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (FirmwareUpdateHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(style, 0x00 == result);
            });
        }
    } code:CodeOfFirUpdate];
}


// 注册设备远程在/离线
- (void)removeOnlineQueryObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfOnlineQuery];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addOnlineQueryObserver:(id)observer mac:(NSString *)mac handler:(OnlineQueryHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfOnlineQuery];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(onlineQuery:completion:) parser:^(NSString *imac, UInt8 status) {
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (OnlineQueryHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(status);
            });
        }
    } code:CodeOfOnlineQuery];
}

// 注册接入工作服务器的反馈
- (void)removeJoinObserver:(id)observer {
    NSString *key = [self keyWithCode:CodeOfAskAccess];
    [self removeObserver:observer mac:nil key:key];
}
- (void)addJoinObserver:(id)observer handler:(JoinHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfAskAccess];
    // 添加keeper
    [self addObserver:observer mac:nil key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(joinWorkServer:completion:) parser:^(NSString *imac, UInt8 result){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (JoinHandler handler in array) {
            handler(0x00 == result);
        }
    } code:CodeOfAskAccess];
}

// 订阅设备事件
- (void)removeOnlineUpdateObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfOnlineUpdate];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addOnlineUpdateObserver:(id)observer mac:(NSString *)mac handler:(OnlineUpdateHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfOnlineUpdate];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(onlineUpdate:completion:)
               parser:^(NSString *imac, UInt8 reserved, UInt8 status){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (OnlineUpdateHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(status);
            });
        }
    } code:CodeOfOnlineUpdate];
}

// 注册订阅事件
- (void)removeSubscribeObserver:(id)observer mac:(NSString *)mac {
    NSString *key = [self keyWithCode:CodeOfSubscribe];
    [self removeObserver:observer mac:mac key:key];
}
- (void)addSubscribeObserver:(id)observer mac:(NSString *)mac handler:(SubscribeHandler)handler {
    if (!handler) return;
    NSString *key = [self keyWithCode:CodeOfSubscribe];
    // 添加keeper
    [self addObserver:observer mac:mac key:key handler:handler];
    if ([self proxyWithKey:key]) return;
    // 添加proxy
    __weak typeof(self) weakSelf = self;
    [self addSelector:@selector(subscribe:completion:) parser:^(NSString *imac, UInt8 result){
        NSArray *array = [weakSelf handlerWithKey:key mac:imac];
        for (SubscribeHandler handler in array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(0x00 == result);
            });
        }
    } code:CodeOfSubscribe];
}


#pragma mark
#pragma mark 数据包


/**
 * 数据包
 * 发送响应数据包
 * 部分数据包仅局域网发送，部分仅因特网发送，其他的则局域网有限（设备局域网在线则只局域网，否则考虑因特网，如果因特网也不在线，则不发送）
 */
// 0x23发现包，局域网，handler(基于序列号，可为nil)
- (void)finderWithPackage:(Package *)package{
    NSString *broadAddress = WifiManagerInstance.broadAddress;
    [self localSendPackage:package host:broadAddress port:PortOflocalService];
}
- (void)finderWithHandler:(FinderHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        FinderHandler newHandler = [handler copy];
        [self addSelector:@selector(finder:completion:)
                   parser:^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(imac, ip, company, type, author);
            });
        } serial:serial];
    }
    
    [self finderWithPackage:[Package finder:serial company:DefaultDeviceCompany type:DefaultDeviceType
                                     author:DefaultDeviceAuthor]];
}
- (void)finderWithMacaddress:(NSString *)mac handler:(FinderHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        FinderHandler newHandler = [handler copy];
        [self addSelector:@selector(finder:completion:)
                   parser:^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(imac, ip, company, type, author);
            });
        } serial:serial];
    }
    
    [self finderWithPackage:[Package finder:serial mac:mac company:DefaultDeviceCompany
                                       type:DefaultDeviceType author:DefaultDeviceAuthor]];
}
- (void)finderWithDevice:(WifiDevice *)device handler:(FinderHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        FinderHandler newHandler = [handler copy];
        [self addSelector:@selector(finder:completion:)
                   parser:^(NSString *imac, NSString *ip, UInt8 company, UInt8 type, UInt16 author){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(imac, ip, company, type, author);
            });
        } serial:serial];
    }
    
    [self finderWithPackage:[Package finder:serial mac:device.mac company:device.company
                                       type:device.type author:device.author]];
}

// 0x62查询设备信息包，局域网/因特网，handler(基于序列号，可为nil)
- (void)queryWithDevice:(WifiDevice *)device handler:(QueryHandler)handler {
    if (!(device.localOnline || self.remoteOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        QueryHandler newHandler = [handler copy];
        [self addSelector:@selector(query:completion:)
                   parser:^(NSString *imac, NSInteger style, NSString *hardVersion, NSString *softVersion, NSString *nickName){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(style, hardVersion, softVersion, nickName);
            });
        } serial:serial];
    }
    
    Package *package = [Package query:serial mac:device.mac company:device.company
                                 type:device.type author:device.author];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip port:PortOflocalService];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 0x61局域网心跳包，局域网，handler(基于序列号，可为nil)
- (void)beatWithDevice:(WifiDevice *)device handler:(BeatHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        BeatHandler newHandler = [handler copy];
        [self addSelector:@selector(heart:completion:) parser:^(NSString *imac, NSInteger style, NSTimeInterval timeInterval){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(style, timeInterval);
            });
        } serial:serial];
    }
    
    Package *package = [Package heart:serial mac:device.mac company:device.company
                                 type:device.type author:device.author];
    [self localSendPackage:package host:device.ip port:PortOflocalService];
}

// 0x24锁定设备包，局域网，handler(基于序列号，可为nil)
- (void)lockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        UlockHandler newHandler = [handler copy];
        [self addSelector:@selector(ulock:completion:) parser:^(NSString *imac, BOOL lock, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package ulock:serial mac:device.mac company:device.company
                                 type:device.type author:device.author lock:YES];
    [self localSendPackage:package host:device.ip port:PortOflocalService];
}
- (void)unlockWithDevice:(WifiDevice *)device handler:(UlockHandler)handler {
    if (!self.localOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        UlockHandler newHandler = [handler copy];
        [self addSelector:@selector(ulock:completion:) parser:^(NSString *imac, BOOL lock, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package ulock:serial mac:device.mac company:device.company
                                 type:device.type author:device.author lock:NO];
    [self localSendPackage:package host:device.ip port:PortOflocalService];
}

// 0x63设备重命名包，局域网/因特网，handler(基于序列号，可为nil)
- (void)renameWithDevice:(WifiDevice *)device name:(NSString *)name handler:(RenameHandler)handler {
    if (!(device.localOnline || self.remoteOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        RenameHandler newHandler = [handler copy];
        [self addSelector:@selector(rename:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(style, 0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package rename:serial mac:device.mac company:device.company
                                  type:device.type author:device.author name:name];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip port:PortOflocalService];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 0x64设备固件升级包，局域网/因特网，handler(基于序列号，可为nil)
- (void)firmwareUpdateWithDevice:(WifiDevice *)device url:(NSString *)url handler:(FirmwareUpdateHandler)handler {
    if (!(device.localOnline || self.remoteOnline)) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        FirmwareUpdateHandler newHandler = [handler copy];
        [self addSelector:@selector(firmwareUpdate:completion:) parser:^(NSString *imac, NSInteger style, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(style, 0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package firmwareUpdate:serial mac:device.mac company:device.company
                                          type:device.type author:device.author url:url];
    if (device.localOnline) {
        [self localSendPackage:package host:device.ip port:PortOflocalService];
    } else if (self.remoteOnline) {
        [self remoteSendPackage:package];
    }
}

// 0x83查询设备是否远程在线，因特网，handler(基于序列号，可为nil)
- (void)onlineQueryWithDevice:(WifiDevice *)device handler:(OnlineQueryHandler)handler {
    if (!self.remoteOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        OnlineQueryHandler newHandler = [handler copy];
        [self addSelector:@selector(onlineQuery:completion:) parser:^(NSString *imac, UInt8 status){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(status);
            });
        } serial:serial];
    }
    
    Package *package = [Package onlineQuery:serial mac:device.mac company:device.company
                                       type:device.type author:device.author];
    [self remoteSendPackage:package];
}

// 0x84订阅设备事件，因特网，handler(基于序列号，可为nil)
- (void)subscribeWithDevice:(WifiDevice *)device enable:(BOOL)enable handler:(SubscribeHandler)handler {
    if (!self.remoteOnline) return;
    
    UInt16 serial = [Package grow];
    if (handler) {
        SubscribeHandler newHandler = [handler copy];
        [self addSelector:@selector(subscribe:completion:) parser:^(NSString *imac, UInt8 result){
            dispatch_async(dispatch_get_main_queue(), ^{
                newHandler(0x00 == result);
            });
        } serial:serial];
    }
    
    Package *package = [Package subscribe:serial mac:device.mac company:device.company
                                     type:device.type author:device.author code:CodeOfOnlineUpdate enable:enable];
    [self remoteSendPackage:package];
}

@end
