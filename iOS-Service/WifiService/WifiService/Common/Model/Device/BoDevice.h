//
//  BoDevice.h
//  BonecoAirCleaner
//
//  Created by Shaojun Han on 3/2/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import "WifiDevice.h"

@interface BoDevice : WifiDevice

@property (strong, nonatomic) NSString  *deviceName;    // 设备别名
// 设备代码（字符串类型）
@property (strong, nonatomic) NSString  *companyCode;   // 公司码，十六进制字符串形式
@property (strong, nonatomic) NSString  *deviceType;    // 设备类型码，十六进制字符串形式
@property (strong, nonatomic) NSString  *authCode;      // 授权码，十六进制字符串形式
// 版本
@property (strong, nonatomic) NSString  *hardVer;       // 硬件版本号
@property (strong, nonatomic) NSString  *softVer;       // 软件版本号
// 同步信息
@property (assign, nonatomic) NSInteger synchronize;    // 同步信息, 0 未同步, 非0 已同步
// 定位信息
@property (strong, nonatomic) NSString  *city;          // 设备定位城市
// 产品专属信息
@property (strong, nonatomic) NSString  *model;         // 产品型号
@property (assign, nonatomic) long      airQuality;     // 空气质量
@property (assign, nonatomic) UInt8     running;        // 是否运行
@property (assign, nonatomic) UInt8     mode;           // 模式
@property (assign, nonatomic) UInt8     wind;           // 风速

////////////////////////////// 专属状态数据 /////////////////////////////////
// 下一组状态数据
- (UInt8)nextMode;
- (UInt8)nextWind;
- (UInt8)nextRunning;
///////////////////////////////////////////////////////////////////////////

////////////////////////////// HTTP服务器接口字段 ///////////////////////////
// 公司码
- (void)setCompany:(UInt8)code;
- (void)setCompanyCode:(NSString *)companyCode;
// 设备类型码
- (void)setType:(UInt8)code;
- (void)setDeviceType:(NSString *)deviceType;
// 授权码
- (void)setAuthor:(UInt16)code;
- (void)setAuthCode:(NSString *)authCode;
///////////////////////////////////////////////////////////////////////////

@end
