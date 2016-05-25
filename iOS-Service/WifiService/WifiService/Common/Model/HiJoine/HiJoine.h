//
//  LSDHiJoine.h
//  LSDHiJoine
//
//  Created by lsd on 15/4/3.
//  Copyright (c) 2015年 LSD_SUBU(DCN(传宁)). All rights reserved.
//

#import <Foundation/Foundation.h>

#define  HiJoinWiFiSucceed  @"HiJoineWiFiSucceed"

@protocol HiJoineDelegate <NSObject>
/**
 *  HiJoine 成功的代理
 *
 *  @param sucess 返回的mac
 */
- (void)HiJoineWiFiSucceed:(NSString *)succeed;
/**
 *  HiJoine 失败的代理
 *
 *  @param error 返回失败参数
 */
- (void)HiJoineWiFiError:(NSString *)error;

/**
 *  超时回调
 *
 */
- (void)HiJoineWiFiTimeOut;

@end

@interface HiJoine : NSObject

@property (nonatomic, weak) id<HiJoineDelegate>delegate;

/**
 *  获取手机 ssid
 *
 *  @return 返回手机ssid
 */
- (id)fetchSSIDInfo;

/**
 *  发送数据
 *
 *  @param pwd      Wi-Fi密码
 *  @param complete 回调block －1 超时  －2  ssid 空   1 成功，message 为mac地址
 */
- (void)setBoardDataWithPassword:(NSString *)pwd withBackBlock:(void(^)(NSInteger result,NSString * message))complete;
@end
