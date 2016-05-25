//
//  BoDevice.m
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/2/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "BoDevice.h"
#import "ServiceDriver+UART.h"

@implementation BoDevice

////////////////////////////// 专属状态数据 /////////////////////////////////
- (UInt8)nextMode {
    switch (self.mode) {
        case 0x00: return 0x01; break;
        case 0x01: return 0x02; break;
        default: return 0x01; break;
    }
}
- (UInt8)nextWind {
    switch (self.wind) {
        case 0x00: return 0x01; break;
        case 0x01: return 0x02; break;
        case 0x02: return 0x03; break;
        case 0x03: return 0x04; break;
        case 0x04: return 0x05; break;
        default: return 0x01; break;
    }
}
- (UInt8)nextRunning {
    switch (self.running) {
        case 0x00: return 0x01; break;
        default: return 0x00; break;
    }
}
///////////////////////////////////////////////////////////////////////////


////////////////////////////// HTTP服务器接口字段 ///////////////////////////
/**
 * 公司码
 */
- (void)setCompany:(UInt8)code {
    static UInt8 tables[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    UInt8 high = (code >> 4 & 0x0F), low = (code & 0x0F);
    _company = code;
    _companyCode = [NSString stringWithFormat:@"%c%c", tables[high], tables[low]];
}
- (void)setCompanyCode:(NSString *)companyCode {
    if (companyCode.length < 2) return;
    NSString *upperCompanyCode = [companyCode uppercaseString];
    UInt8 *bytes = (UInt8 *)[[upperCompanyCode dataUsingEncoding:NSASCIIStringEncoding] bytes];
    bytes[0] = bytes[0] >= 'A' ? bytes[0] - 'A' + 10: bytes[0] - '0';
    bytes[1] = bytes[1] >= 'A' ? bytes[1] - 'A' + 10: bytes[1] - '0';
    _companyCode = upperCompanyCode;
    _company = (bytes[0] << 4) | (bytes[1]);
}

/**
 * 设备类型码
 */
- (void)setType:(UInt8)code {
    static UInt8 tables[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    UInt8 high = (code >> 4 & 0x0F), low = (code & 0x0F);
    _type = code;
    _deviceType = [NSString stringWithFormat:@"%c%c", tables[high], tables[low]];
}
- (void)setDeviceType:(NSString *)deviceType {
    if (deviceType.length < 2) return;
    NSString *upperDeviceType = [deviceType uppercaseString];
    UInt8 *bytes = (UInt8 *)[[upperDeviceType dataUsingEncoding:NSASCIIStringEncoding] bytes];
    bytes[0] = bytes[0] >= 'A' ? bytes[0] - 'A' + 10: bytes[0] - '0';
    bytes[1] = bytes[1] >= 'A' ? bytes[1] - 'A' + 10: bytes[1] - '0';
    _deviceType = upperDeviceType;
    _type = (bytes[0] << 4) | (bytes[1]);
}

/**
 * 授权码
 */
- (void)setAuthor:(UInt16)code {
    static UInt8 tables[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    UInt8 high_h = ((code >> 12) & 0x0F), high_l = ((code >> 8) & 0x0F), low_h = ((code >> 4) & 0x0F), low_l = (code & 0x0F);
    _author = code;
    _authCode = [NSString stringWithFormat:@"%c%c%c%c", tables[high_h], tables[high_l], tables[low_h], tables[low_l]];
}
- (void)setAuthCode:(NSString *)authCode {
    if (authCode.length < 4) return;
    NSString *upperAuthCode = [authCode uppercaseString];
    UInt8 *bytes = (UInt8 *)[[upperAuthCode dataUsingEncoding:NSASCIIStringEncoding] bytes];
    bytes[0] = bytes[0] >= 'A' ? bytes[0] - 'A' + 10 : bytes[0] - '0';
    bytes[1] = bytes[1] >= 'A' ? bytes[1] - 'A' + 10 : bytes[1] - '0';
    bytes[2] = bytes[2] >= 'A' ? bytes[2] - 'A' + 10 : bytes[2] - '0';
    bytes[3] = bytes[3] >= 'A' ? bytes[3] - 'A' + 10 : bytes[3] - '0';
    _authCode = upperAuthCode;
    _author = (bytes[0] << 12) | (bytes[1] << 8) | (bytes[2] << 4) | (bytes[3]);
}

- (void)setMacAddress:(NSString *)macAddress {
    if (_mac == macAddress) return;
    _mac = macAddress;
}
- (void)setDeviceCode:(NSString *)deviceCode {
    [self setModel:deviceCode];
}
///////////////////////////////////////////////////////////////////////////

@end
