//
//  Package+UART.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/4/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "Package+UART.h"

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
 */
+ (Package *)windWithDevice:(WifiDevice *)device serial:(UInt16)serial wind:(UInt8)wind {
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA4, 0x30, 0x05, wind, 0x00, 0x55, 0x55};
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
+ (Package *)clockWithDevice:(WifiDevice *)device serial:(UInt16)serial clockType:(UInt8)clockType time:(NSTimeInterval)time {
    unsigned long interval = time;
    UInt8 second = interval % 60; interval /= 60;
    UInt8 minute = interval % 60; interval /= 60;
    UInt8 hour = interval % 24; interval /= 24;
    UInt8 lday = interval % 256; interval /= 256;
    UInt8 hday = interval;
    UInt8 type = (clockType == 0x01) ? 0x51 : 0xA1;
    lday = 0x00 | (lday & 0x3F);
    hday = 0x00 | (hday & 0x3F);
    hour = 0x40 | (hour & 0x3F);
    minute = 0x80 | (minute & 0x3F);
    second = 0xC0 | (second & 0x3F);
    
    UInt8 bytes[] = {0xAA, 0xAA, 0x0C, 0xA5, type, 0x00, hour, minute, second, 0x00, 0x55, 0x55};
    bytes[9] = CheckSum(bytes + 2, 7);
    
    UInt8 mac[6] = {0x00};
    Hex2UInt8s(device.mac, mac, 6);
    
    Header header = HeaderMake(YES, NO, mac, 0x08 + sizeof(bytes), serial, device.company, device.type, device.author);
    NSData *raw = [NSData dataWithBytes:bytes length:sizeof(bytes)/sizeof(UInt8)];
    return [[Package alloc] initWithHeader:header code:CodeControlToDevice raw:raw];
}

/**
 * 开关机、风量、定时、模式的响应
 */
+ (void)control:(Package *)package completion:(ControlParser)completion {
    if (!completion) return;
    
    NSString *mac = UInt8s2Hex(package.header.mac, 6);
    UInt8 *bytes = (UInt8 *)[package.raw bytes];
    UInt8 result = bytes[0];
    completion(mac, result);
}

+ (void)run:(Package *)package completion:(SubmitRunParser)completion {
    if (!completion) return;
    
    NSString *imac = UInt8s2Hex(package.header.mac, 6);
    NSInteger style = package.style;
    UInt8 *bytes = (UInt8 *)[package.raw bytes]; bytes += 4;
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
    UInt8 clockType = bytes[0]; ++ bytes;
    if(clockType == 0x00) { // 无定时
        completion(imac, style, clockType, 0, 0);
    } else if (clockType == 0xA1) { // 开机
        clockType = 0x10;
    } else if (clockType == 0x51) { // 关机
        clockType = 0x01;
    }
    
    UInt8 day = bytes[0] & 0x3F; ++ bytes;
    UInt8 hour = bytes[0] & 0x3F; ++ bytes;
    UInt8 minute = bytes[0] & 0x3F; ++ bytes;
    UInt8 second = bytes[0] & 0x3F; ++ bytes;

    ++ bytes;
    UInt8 rDay = bytes[0] & 0x3F; ++ bytes;
    UInt8 rHour = bytes[0] & 0x3F; ++ bytes;
    UInt8 rMinute = bytes[0] & 0x3F; ++ bytes;
    UInt8 rSecond = bytes[0] & 0x3F; ++ bytes;
    
    NSTimeInterval time = (((day *  24 + hour) * 60) + minute) * 60 + second;
    NSTimeInterval restTime = (((rDay * 24 + rHour) * 60) + rMinute) * 60 + rSecond;
    completion(imac, style, clockType, time, restTime);
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

/**
 * 上报
 */
+ (Package *)submitSubscribeWithDevice:(WifiDevice *)device serial:(UInt16)serial enable:(BOOL)enable {
    return [Package subscribe:serial mac:device.mac company:device.company type:device.type author:device.author code:CodeControlByDevice enable:enable];
}
+ (void)submit:(Package *)package completion:(SubmitParser)completion {
    if (!completion) return;
    
    Header header = package.header;
    UInt8 code = package.code;
    NSInteger style = package.style;
    NSString *remark = package.mark;
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
        package.style = style; package.mark = remark;
        [list addObject:package];
    }
    
    for (Package *package in list) {
        UInt8 *bytes = (UInt8 *)[package.raw bytes];
        UInt8 submitTyle = bytes[3];
        switch (submitTyle) {
            case 0x53: case 0xD3:
                submitTyle = CodeSubmitOfRunning; break;
            case 0x54: case 0xD4:
                submitTyle = CodeSubmitOfMode; break;
            case 0x55: case 0xD5:
                submitTyle = CodeSubmitOfClock; break;
            case 0x58: case 0xD8:
                submitTyle = CodeSubmitOfCondition; break;
            case 0x52: case 0xD2:
                submitTyle = CodeSubmitOfModel; break;
            default:
                break;
        }
        completion(package, submitTyle);
    }
}


@end
