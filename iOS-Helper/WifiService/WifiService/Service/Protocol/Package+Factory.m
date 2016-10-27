//
//  Protocol+Factory.m
//  AirCleaner
//
//  Created by Shaojun Han on 9/15/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "Package+Factory.h"

static const UInt8  FlagOfRequest       = 0x00;
static const UInt8  FlagOfResponse      = 0x02;
static const UInt8  FlagOfLock          = 0x04;
static const UInt8  FlagOfUnLock        = 0x00;
static const UInt8  PackVersion         = 0xA1;
static const UInt8  DefaultMacAddress[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};

/**
 * 辅助函数
 * 校验和
 * 十六进制字符串转UInt8数组
 * 生成Header的函数
 */
UInt8 CheckSum(UInt8 *bytes, NSUInteger size) {
    UInt8 sum = 0;
    for (int i = 0; i < size ; ++ i) {
        sum += bytes[i];
    }
    return sum;
}
NSString *UInt8s2Hex(UInt8 *src, NSUInteger size) {
    unsigned char map[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    NSMutableData *data = [NSMutableData dataWithCapacity:(size << 1)];
    for (int i = 0; i < size; ++ i) {
        UInt8 byte = src[i];
        UInt8 high = ((byte >> 4) & 0x0F);
        UInt8 low = (byte & 0x0F);
        [data appendBytes:map + high length:1];
        [data appendBytes:map + low length:1];
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
void Hex2UInt8s(NSString *hex, UInt8 *dest, NSUInteger size) {
    NSString *src = [hex uppercaseString];
    UInt8 *bytes = (UInt8 *)[[src dataUsingEncoding:NSASCIIStringEncoding] bytes];
    for (int i = 0, j = 0; i < size; ++ i, j += 2) {
        UInt8 a = bytes[j], b = bytes[j + 1];
        UInt8 high = (a >= 'A') ? (a - 'A' + 10) : (a - '0' + 0);
        UInt8 low = (b >= 'A') ? (b - 'A' + 10) : (b - '0' + 0);
        dest[i] = (high << 4 | low);
    }
}

/**
 * 生成Header的函数
 */
Header HeaderMake(BOOL request, BOOL lock, const UInt8 mac[6], UInt8 length,
                  UInt16 serial, UInt8 company, UInt8 type, UInt16 author) {
    Header header = {PackVersion};
    header.flag = (request ? FlagOfRequest : FlagOfResponse) | (lock ? FlagOfLock : FlagOfUnLock);
    header.length = length;
    header.reserved = 0x00;
    header.serial[0] = ((serial >> 8) & 0xFF), header.serial[1] = (serial & 0xFF);
    header.type = type;
    header.company = company;
    header.author[0] = ((author >> 8) & 0xFF), header.author[1] = (author & 0xFF);
    memcpy(header.mac, mac, 6);
    return header;
}


@implementation Package (Factory)

/**
 * 序列号
 */
static UInt16 serialNumber = 0;
+ (UInt16)serial {
    return serialNumber;
}
+ (UInt16)grow {
    @synchronized(self) {
        serialNumber = (serialNumber + 1) & 0x7FFF;
        return serialNumber;
    }
}

/**
 * 检查包是否合法
 */
+ (BOOL)isSerialOkay:(Package *)package {
    return !(package.code == 0x02);
}
+ (BOOL)isRecieveOkay:(Package *)package {
    UInt8 okay[] = {0x02, CodeOfOnlineUpdate, CodeSubscribeOfConfig};
    for (int i = 0; i < sizeof(okay)/sizeof(UInt8); ++ i) {
        if (package.code == okay[i]) return YES;
    }
    return (package.header.flag & FlagOfResponse);
}

/**
 * resolveWorkServer
 * 0x81 解析工作服务器包
 * 参数 serial 序列号
 * 参数 company 公司码
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成的回调
 */
+ (Package *)resolveWorkServer:(UInt16)serial company:(UInt8)company type:(UInt8)type author:(UInt16)author {
    Header header = HeaderMake(YES, NO, DefaultMacAddress, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfResolve raw:nil];
}
+ (void)resolveWorkServer:(Package *)package completion:(ResolveParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 ip[4] = {0x00}, port[2] = {0x00};
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    
    memcpy(&ip, bytes, sizeof(ip));
    bytes += sizeof(ip);
    memcpy(&port, bytes, sizeof(port));
    UInt16 author = (package.header.author[0] << 8) | package.header.author[1];
    
    completion(mac, [NSString stringWithFormat:@"%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]], (port[0] << 8 | port[1]), author);
}

/**
 * joinWorkServer
 * 0x82 请求接入服务包
 * 参数 serial 序列号
 * 参数 joinCode 接入码
 * 参数 username 用户名
 * 参数 password 密码
 * 参数 package 数据包
 * 参数 completion 解析完成的回调
 */
+ (Package *)joinWorkServer:(UInt16)serial account:(NSString *)account key:(NSString *)key company:(UInt8)company
                       type:(UInt8)type author:(UInt16)author joinCode:(unsigned const char*)joinCode joinSize:(int)jsize {
    // 接入码
    NSData *jdata = [NSData dataWithBytes:joinCode length:jsize];
    NSData *adata = [account dataUsingEncoding:NSUTF8StringEncoding];
    NSData *kdata = [key dataUsingEncoding:NSUTF8StringEncoding];
    UInt8 asize = adata.length, ksize = kdata.length;
    
    NSMutableData *raw = [NSMutableData data];
    [raw appendBytes:&jsize length:sizeof(UInt8)];
    [raw appendData:jdata];
    [raw appendBytes:&asize length:sizeof(UInt8)];
    [raw appendData:adata];
    [raw appendBytes:&ksize length:sizeof(UInt8)];
    [raw appendData:kdata];
    
    Header header = HeaderMake(YES, NO, DefaultMacAddress, (8 + raw.length), serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfAskAccess raw:raw];
}
+ (void)joinWorkServer:(Package *)package completion:(JoinParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 res = ((UInt8 *)[package.raw bytes])[0];
    
    completion(mac, res);
}

/**
 * onlineQuery
 * 0x83 查询设备在线/离线包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 lock 锁定设备
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 completion 解析完成回调
 */
+ (Package *)onlineQuery:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
                  author:(UInt16)author {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    Header header = HeaderMake(YES, NO, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfOnlineQuery raw:nil];
}
+ (void)onlineQuery:(Package *)package completion:(OnlineQueryParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 status = ((UInt8 *)[package.raw bytes])[0];
    
    completion(mac, status);
}

/**
 * onlineUpdate
 * 0x84 设备在线/离线状态更新包
 * 该包仅有服务器发送，客户端只负责接收处理
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 status 设备在离线状态
 * 参数 package 服务器数据包
 * 参数 completion 完成解析时的回调
 */
+ (void)onlineUpdate:(Package *)package completion:(OnlineParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    completion(mac, bytes[0], bytes[1]);
}

/**
 * firmwareVersion
 * 0x85 查询固件最新版本号包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 服务器数据包
 * 参数 compeltion 完成时的回调
 * 参数 version APP版本
 * 参数 urlString 升级地址
 */
+ (Package *)firmwareVersion:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
                      author:(UInt16)author {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    Header header = HeaderMake(YES, NO, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfAskFirVersion raw:nil];
}
+ (void)firmwareVersion:(Package *)package completion:(FirmwareVerParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 vsize = (UInt8)bytes[0]; ++ bytes;
    NSData *vdata = [NSData dataWithBytes:bytes length:vsize];
    
    bytes += vsize;
    UInt8 usize = (UInt8)bytes[0]; ++ bytes;
    NSData *udata = [NSData dataWithBytes:bytes length:usize];
    
    NSString *softVer = [[NSString alloc] initWithData:vdata encoding:NSASCIIStringEncoding];
    NSString *url = [[NSString alloc] initWithData:udata encoding:NSASCIIStringEncoding];
    completion(mac, softVer, url);
}

/**
 * subscribe
 * 0x86 订阅设备事件
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 code 订阅码
 * 参数 param 订阅参数
 * 参数 package 服务器数据包
 * 参数 compeltion 完成时的回调
 */
+ (Package *)subscribe:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
    author:(UInt16)author code:(UInt8)code enable:(BOOL)enable {
    UInt8 other = 0x00, umac[6] = {0x00};
    
    Hex2UInt8s(mac, umac, sizeof(umac));
    UInt8 sub_or_not = YES == enable ? 0x01 : 0x00;
    NSMutableData *raw = [NSMutableData data];
    [raw appendBytes:&sub_or_not length:1];
    [raw appendBytes:&code length:1];
    [raw appendBytes:&other length:1];
    
    Header header = HeaderMake(YES, NO, umac, 8 + raw.length, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfSubscribe raw:raw];
}
+ (Package *)subscribe:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)author code:(UInt8)code enable:(BOOL)enable other:(NSData *)other {
    
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    
    UInt8 sub_or_not = YES == enable ? 0x01 : 0x00;
    NSMutableData *raw = [NSMutableData data];
    [raw appendBytes:&sub_or_not length:1];
    [raw appendBytes:&code length:1];
    if (other) [raw appendData:other];
    
    Header header = HeaderMake(YES, NO, umac, 8 + raw.length, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfSubscribe raw:raw];
}
+ (void)subscribe:(Package *)package completion:(SubscribeParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 status = ((UInt8 *)[package.raw bytes])[0];
    
    completion(mac, status);
}


/**
 * heart
 * 0x61 心跳包 标记上时间的和没有标记上时间的心跳包
 * 心跳解析 解析结果[timeInterval], timeInterval下次心跳间隔
 * 参数 serial 数据包序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 心跳返回数据包
 * 参数 completion 解析完成时回调
 */
+ (Package *)heart:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)author {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, 6);
    Header header = HeaderMake(YES, NO, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfHeart raw:nil];
}
+ (void)heart:(Package *)package completion:(HeartParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 time[2] = {0};
    memcpy(time, [package.raw bytes], sizeof(time));
    UInt16 timeInterval = (((UInt16)time[0]) << 8) | (time[1]);
    
    completion(mac, package.style, timeInterval);
}

/**
 * query
 * 0x62 查询模块信息包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 status 设备状态
 * 参数 hardVersion 硬件版本
 * 参数 softVersion 软件版本
 * 参数 nickName 设备别名
 */
+ (Package *)query:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
            author:(UInt16)author {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    Header header = HeaderMake(YES, NO, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfQuery raw:nil];
}
+ (void)query:(Package *)package completion:(QueryParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 hsize = bytes[0]; ++ bytes;
    NSData *hdata = [NSData dataWithBytes:bytes length:hsize];
    
    bytes += hsize;
    UInt8 ssize = bytes[0]; ++ bytes;
    NSData *sdata = [NSData dataWithBytes:bytes length:ssize];
    
    bytes += ssize;
    UInt8 nsize = bytes[0]; ++ bytes;
    NSData *ndata = [NSData dataWithBytes:bytes length:nsize];
    
    NSString *hardVer = [[NSString alloc] initWithData:hdata encoding:NSASCIIStringEncoding];
    NSString *softVer = [[NSString alloc] initWithData:sdata encoding:NSASCIIStringEncoding];
    NSString *nickName = [[NSString alloc] initWithData:ndata encoding:NSASCIIStringEncoding];
    completion(mac, package.style, hardVer, softVer, nickName);
}

/**
 * rename
 * 0x63 设置模块别名
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 type 设备类型码
 * 参数 author 授权码
 * 参数 name 重命名的名字
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
+ (Package *)rename:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
             author:(UInt16)author name:(NSString *)name {
    UInt8 umac[6] = {0x00};
    
    Hex2UInt8s(mac, umac, sizeof(umac));
    NSData *data = [name dataUsingEncoding:NSASCIIStringEncoding];
    UInt8 size = data.length;
    NSMutableData *raw = [NSMutableData dataWithBytes:&size length:sizeof(UInt8)];
    [raw appendData:data];
    
    Header header = HeaderMake(YES, NO, umac, 8 + raw.length, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfRename raw:raw];
}
+ (void)rename:(Package *)package completion:(RenameParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    
    UInt8 res = ((UInt8 *)[package.raw bytes])[0];
    
    completion(mac, package.style, res);
}

/**
 * firmwareUpdate
 * 0x64 设备固件升级
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 name 重命名的名字
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
+ (Package *)firmwareUpdate:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
                     author:(UInt16)author url:(NSString *)url {
    UInt8 umac[6] = {0x00};
    
    Hex2UInt8s(mac, umac, sizeof(umac));
    NSData *data = [url dataUsingEncoding:NSASCIIStringEncoding];
    UInt8 size = data.length;
    NSMutableData *raw = [NSMutableData dataWithBytes:&size length:sizeof(UInt8)];
    [raw appendData:data];
    
    Header header = HeaderMake(YES, NO, umac, 8 + raw.length, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfFirUpdate raw:raw];
}
+ (void)firmwareUpdate:(Package *)package completion:(FirmwareUpdateParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 res = ((UInt8 *)[package.raw bytes])[0];
    
    completion(mac, package.style, res);
}

/**
 * find
 * 0x23 设备发现包
 * 参数 serial 序列号
 * 参数 type 设备类型码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 ip 设备IP地址,点分十进制表示
 * 参数 mac 设备mac地址，十六进制表示
 * 参数 alarm_type 设备类型
 */
+ (Package *)finder:(UInt16)serial company:(UInt8)company type:(UInt8)type author:(UInt16)author {
    Header header = HeaderMake(YES, NO, DefaultMacAddress, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfFinder raw:nil];
}
+ (Package *)finder:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
             author:(UInt16)author {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    Header header = HeaderMake(YES, NO, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfFinder raw:nil];
}
+ (void)finder:(Package *)package completion:(FinderParser)completion {
    if (!completion) return;
    
    // 解析
    UInt8 umac[6] = {0x00}, ip[4] = {0x00};
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    
    memcpy(ip, bytes, sizeof(ip));
    bytes += sizeof(ip);
    memcpy(umac, bytes, sizeof(umac));
    bytes += sizeof(umac);
    NSInteger size = package.raw.length - (sizeof(ip) + sizeof(umac));
    NSData *obj = size > 0 ? [NSData dataWithBytes:bytes length:size] : nil;
    
    NSString *ipAddress = [NSString stringWithFormat:@"%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]];
    NSString *macAddress = UInt8s2Hex(umac, sizeof(umac));
    UInt8 type = package.header.type;
    UInt8 company = package.header.company;
    UInt16 author = (package.header.author[0] << 8) | package.header.author[1];
    
    completion(macAddress, ipAddress, company, type, author, obj);
}

/**
 * lock
 * 0x24 锁定或解锁设备包
 * 参数 serial 序列号
 * 参数 mac 设备mac地址
 * 参数 device 设备类型
 * 参数 author 授权码
 * 参数 package 服务器返回数据包
 * 参数 completion 解析完成回调
 * 参数 result 结果
 */
+ (Package *)ulock:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type
            author:(UInt16)author lock:(BOOL)lock {
    UInt8 umac[6] = {0x00};
    Hex2UInt8s(mac, umac, sizeof(umac));
    Header header = HeaderMake(YES, lock, umac, 0x08, serial, company, type, author);
    return [[Package alloc] initWithHeader:header code:CodeOfLock raw:nil];
}
+ (void)ulock:(Package *)package completion:(UlockParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 res = ((UInt8 *)[package.raw bytes])[0];
    BOOL lock = 0 == (package.header.flag & FlagOfLock);
    completion(mac, lock, res);
}

@end
