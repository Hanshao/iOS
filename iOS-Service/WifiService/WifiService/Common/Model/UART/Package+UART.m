//
//  Package+UART.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "Package+UART.h"

/**
 * 长定时协议
 */
@implementation Package (Clock)

// 0x03 设置定时协议
+ (Package *)clockSettingWithDevice:(WifiDevice *)device serial:(UInt16)serial clockNumber:(UInt8)number closeType:(BOOL)closeType recurWeekDay:(UInt8)recurWeekDay timeInterval:(unsigned long)timeInterval {
    // 定时序号
    NSMutableData *bytes = [NSMutableData dataWithBytes:&number length:sizeof(UInt8)];
    UInt8 flag = recurWeekDay | 0x80;
    [bytes appendBytes:&flag length:sizeof(UInt8)];
    // 网络字节序转换
    UInt8 clockBytes[4] = {0};
    clockBytes[0] = (timeInterval >> 24) & 0xFF, clockBytes[1] = (timeInterval >> 16) & 0xFF;
    clockBytes[2] = (timeInterval >> 8) & 0xFF, clockBytes[3] = (timeInterval >> 0) & 0xFF;
    [bytes appendBytes:clockBytes length:sizeof(clockBytes)];
    // 开关机
    UInt8 runByte = closeType ? 0xC8 : 0xF9;
    UInt8 dataBytes[] = {0xAA, 0xAA, 0x0C, 0xA3, runByte, 0x00, 0x55, 0x55};
    dataBytes[5] = CheckSum(dataBytes + 2, 3);
    [bytes appendBytes:dataBytes length:sizeof(dataBytes)];
    // 数据包
    UInt8 mac[6] = {0}; Hex2UInt8s(device.mac, mac, 6);
    Header header = HeaderMake(YES, NO, mac, 0x08 + bytes.length, serial, device.company, device.type, device.author);
    return [[Package alloc] initWithHeader:header code:CodeClockSetting raw:bytes];
}
+ (void)clockSetting:(Package *)package completion:(ClockControlParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 result = bytes[0];
    
    completion(mac, result);
}

// 0x05 删除定时协议
+ (Package *)clockClearWithDevice:(WifiDevice *)device serial:(UInt16)serial clockNumber:(UInt8)number {
    NSData *bytes = [NSData dataWithBytes:&number length:sizeof(UInt8)];
    
    UInt8 mac[6] = {0}; Hex2UInt8s(device.mac, mac, 6);
    Header header = HeaderMake(YES, NO, mac, 0x08 + bytes.length, serial, device.company, device.type, device.author);
    return [[Package alloc] initWithHeader:header code:CodeClockClear raw:bytes];
}
+ (void)clockClear:(Package *)package completion:(ClockControlParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 result = bytes[0];
    
    completion(mac, (result == 0x00));}

// 0x04 定时查询协议
+ (Package *)clockQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial {
    UInt8 number = 0;
    NSData *bytes = [NSData dataWithBytes:&number length:sizeof(UInt8)];
    
    UInt8 mac[6] = {0}; Hex2UInt8s(device.mac, mac, 6);
    Header header = HeaderMake(YES, NO, mac, 0x08 + bytes.length, serial, device.company, device.type, device.author);
    return [[Package alloc] initWithHeader:header code:CodeClockQuery raw:bytes];
}
+ (Package *)clockQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial numbers:(NSArray *)numbers {
    NSMutableData *bytes = [NSMutableData data];
    for (NSNumber *it in numbers) {
        UInt8 number = [it intValue];
        [bytes appendBytes:&number length:sizeof(UInt8)];
    }
    
    UInt8 mac[6] = {0}; Hex2UInt8s(device.mac, mac, 6);
    Header header = HeaderMake(YES, NO, mac, 0x08 + bytes.length, serial, device.company, device.type, device.author);
    return [[Package alloc] initWithHeader:header code:CodeClockQuery raw:bytes];
}
+ (void)clockQuery:(Package *)package completion:(ClockQueryParser)completion {
    if (!completion) return;
    // 1 + 4 + 9为 1 组定时
    UInt8 unit = 1 + 4 + 9;
    UInt8 count = package.raw.length / unit;

    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i < count; ++ i, bytes += unit) {
        UInt8 *pointer = bytes;
        UInt8 number = pointer[0], flag = pointer[1];
        if (!(flag & 0x80)) continue;   // 未激活
        UInt8 recurWeekDay = flag & 0x7F;

        pointer += 2;
        unsigned long timeInterval = (pointer[0] << 24) | (pointer[1] << 16) | (pointer[2] << 8) | (pointer[3] << 0);
        pointer += 4;
        UInt8 runByte = pointer[4]; // 定时完成时的指令
        BOOL closeType = (runByte & 0x01) ? NO : YES;
        [list addObject:@[@(number), @(closeType), @(recurWeekDay), @(timeInterval)]];
    }
    completion(mac, list);
}

@end


/**
 * 配置协议
 */
@implementation Package (Configer)
/**
 * 配置命令
 */
+ (Package *)configSubscribe:(UInt16)serial mac:(NSString *)mac company:(UInt8)company type:(UInt8)type author:(UInt16)autho ssid:(NSString *)ssid enable:(BOOL)enable {
    return [Package subscribe:serial mac:mac company:company type:type author:autho code:CodeSubscribeOfConfig enable:enable other:[ssid dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (void)config:(Package *)package completion:(ConfigParser)completion {
    if (completion) {
        UInt8 *bytes = (UInt8 *)[package.raw bytes];
        NSInteger size = bytes[0]; ++ bytes;
        NSString *ssid = [[NSString alloc] initWithData:[NSData dataWithBytes:bytes length:size] encoding:NSUTF8StringEncoding];
        bytes += size; size = package.raw.length - 1 - size;
        NSData *obj = size > 0 ? [NSData dataWithBytes:bytes length:size] : nil;
        
        Header header = package.header;
        NSString *mac = UInt8s2Hex(header.mac, 6);
        UInt16 author = (((UInt16)header.author[0]) << 8 | header.author[1]);
        
        completion(mac, ssid, header.company, header.type, author, obj);
    }
}
@end

/**
 * 串口协议
 */
@implementation Package (UART)
/**
 * 开关机
 */
+ (Package *)runWithDevice:(WifiDevice *)device serial:(UInt16)serial running:(BOOL)running {
    UInt8 byte = running ? 0xF9 : 0xC8;
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA3, byte, 0x00, 0x55, 0x55};
    bytes[5] = CheckSum(bytes + 2, 3);

    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);
    
    Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
    NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
    return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
}

/**
 * 风量
 * 当前为测试，依据旧协议进行实现，请在固件更新后，修改此部分实现
 */
+ (Package *)windWithDevice:(WifiDevice *)device serial:(UInt16)serial wind:(UInt8)wind {
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA4, 0x30, wind, 0x05, 0x00, 0x55, 0x55};
    bytes[7] = CheckSum(bytes + 2, 5);
    
    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);
    
    Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
    NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
    return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
}

/**
 * 模式
 */
+ (Package *)modeWithDevice:(WifiDevice *)device serial:(UInt16)serial mode:(UInt8)mode wind:(UInt8)wind {
    mode = 0x30 | (mode & 0x0F);
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA4, mode, 0x01, wind, 0x00, 0x55, 0x55};
    bytes[7] = CheckSum(bytes + 2, 5);
    
    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);
    
    Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
    NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
    return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
}

/**
 * 定时
 */
+ (Package *)clockWithDevice:(WifiDevice *)device serial:(UInt16)serial closeType:(BOOL)closeType hour:(UInt8)hour minute:(UInt8)minute {
    
    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);

    if (hour == 0 && minute == 0) { // 取消定时指令
        UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA5, 0x00, 0x00, 0x55, 0x55};
        bytes[5] = CheckSum(bytes + 2, 3);
        
        Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
        NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
        return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
    } else {
        UInt8 clockType = closeType ? 0x51 : 0xA1;
        hour = 0x40 | (hour & 0x3F); minute = 0x80 | (minute & 0x3F);
    
        UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA5, clockType, 0x00, hour, minute, 0xC0, 0x00, 0x55, 0x55};
        bytes[9] = CheckSum(bytes + 2, 7);
        
        Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
        NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
        return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
    }
}
// 查询设备状态
+ (Package *)infoQueryWithDevice:(WifiDevice *)device serial:(UInt16)serial {
    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);
    
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA9, 0x00, 0x55, 0x55};
    Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
    bytes[4] = CheckSum(bytes + 2, 2);
    NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
}

+ (void)run:(Package *)package completion:(SubmitRunParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 5;
    UInt8 running = bytes[0] & 0x01;
    
    completion(imac, style, running);
}
+ (void)mode:(Package *)package completion:(SubmitModeParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 4;
    UInt8 mode = bytes[0] & 0x0F; ++ bytes;
    UInt8 max = bytes[0]; ++ bytes;
    UInt8 level = bytes[0];
    completion(imac, style, mode, max, level);
}
+ (void)clock:(Package *)package completion:(SubmitClockParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 4;
    UInt8 clockType = (bytes[0] >> 6) & 0x03;
    if(clockType == 0x00) { // 无定时
        completion(imac, style, NO, NO, 0, 0, 0); return;
    }
    
    bytes += 5; bytes += 2;
    UInt8 hour = bytes[0] & 0x3F; ++ bytes;
    UInt8 minute = bytes[0] & 0x3F; ++ bytes;
    UInt8 sec = bytes[0] & 0x3F;
    // 分钟的显示处理, 秒不为0, 则分钟+1, 秒永远为0
    if (sec > 0) minute += 1;   // 这里面的处理逻辑很差(因为固件的问题)
    else if (minute != 0 || hour != 0) minute += 1;
    
    completion(imac, style, YES, clockType == 0x01, hour, minute, sec);
}
+ (void)model:(Package *)package completion:(SubmitModelParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    NSInteger size = package.raw.length;
    UInt8 *bytes = (UInt8 *)[package.raw bytes];;
    
    NSString *model = nil;
    UInt8 *point = bytes + 4, *start = bytes + 4;
    UInt8 *last = bytes + size, *end = bytes + 4;
    for (; point < last; ++ point) {
        while (point < last - 1) {
            if (*point == 0x55) break;
            ++ point;
        }
        
    n0x55:
        if (point >= last - 1) break;
        ++ point;
        if (!(*point == 0x55))
            continue;
        
        end = point;
        UInt8 sum = *(end - 2);// the continuous 0x55, do chechsum
        UInt8 csum = CheckSum(start - 2, end - start);
        if (!(sum == csum))
            goto n0x55;
        
        NSData *raw = [NSData dataWithBytes:start length:end - start - 2];
        model = [[NSString alloc] initWithData:raw encoding:NSASCIIStringEncoding];
        break;
    }
    
    completion(imac, style, model);
}
+ (void)condition:(Package *)package completion:(SubmitConditionParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 5;
    UInt8 condition = bytes[0];
    completion(imac, style, condition);
}

+ (void)complex:(Package *)package completion:(ComplexParser)completion {
    if (completion) {
        NSString *imac = UInt8s2Hex(package.header.mac, 6);
        NSInteger style = package.style;
        UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 4;
        UInt8 condition = bytes[0];
        completion(imac, style, condition);
    }
}

/**
 * 上报
 */
+ (Package *)submitSubscribeWithDevice:(WifiDevice *)device serial:(UInt16)serial enable:(BOOL)enable {
    return [Package subscribe:serial mac:device.mac company:device.company type:device.type author:device.author code:CodeControlByDevice enable:enable];
}
+ (void)submit:(Package *)package completion:(SubmitParser)completion {
    if (!completion) return;
    
    Header header = package.header; UInt8 code = package.code;
    NSInteger style = package.style; id accessory = package.accessory;
    NSMutableArray *list = [NSMutableArray array];
    
    NSInteger size = package.raw.length;
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 *point = bytes, *last = bytes + size;
    UInt8 *start = point, *end = point;
    
    for (; point < last; ++ point) {
        while (point < (last - 1)) {
            if (*point == 0xAA) break;
            ++ point;
        }
        
        if (point >= last - 1)
            break;  // end
        
        start = point; ++ point;
        if (!(0xAA == *point))   // no continuous 0xAA
            break;
        
    u0x55:
        ++ point;
        while (point < (last - 1)) {
            if (*point == 0x55) break;
            ++ point;
        }
        
    n0x55:
        if (point >= last - 1)
            break;  // end
        
        end = point; ++ point;
        if (!(0x55 == *point)) // no continuous 0x55
            goto u0x55;
        
        end = point;
        UInt8 sum = *(end - 2);// the continuous 0x55, do chechsum
        UInt8 csum = CheckSum(start + 2, end - start - 4);
        if (!(sum == csum))
            goto n0x55;
        
        NSData *raw = [NSData dataWithBytes:start length:end - start + 1];
        Package *package = [[Package alloc] initWithHeader:header code:code raw:raw];
        package.style = style; package.accessory = accessory;
        [list addObject:package];
    }
    
    for (Package *package in list) {
        UInt8 *bytes = (UInt8 *)[package.raw bytes];
        UInt8 submitTyle = bytes[3];
        UInt8 tables[][2] = {
            {0x52, CodeSubmitOfModel}, {0xD2, CodeSubmitOfModel},
            {0x53, CodeSubmitOfRunning}, {0xD3, CodeSubmitOfRunning},
            {0x54, CodeSubmitOfMode}, {0xD4, CodeSubmitOfMode},
            {0x55, CodeSubmitOfClock}, {0xD5, CodeSubmitOfClock},
            {0x58, CodeSubmitOfCondition}, {0xD8, CodeSubmitOfCondition},
            {0x59, CodeSubmitOfRuntime}, {0xD9, CodeSubmitOfRuntime},
            {0x5B, CodeSubmitOfComplex}};
        for (int i = 0; i < sizeof(tables); ++ i) {
            if (submitTyle == tables[i][0]) {
                submitTyle = tables[i][1]; break;
            }
        }
        completion(package, submitTyle);
    }
}

@end
