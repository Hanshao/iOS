//
//  NSString+Extension.h
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 拓展(NSString)
 * 1. URL编码
 * 2. 重用加密
 * 3. 验证
 */
@interface NSString (URL)

// URL编码(对URL中的中文进行转码)
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end

@interface NSString (Encryptor)

/**
 * MD5加密
 * 说明 MD5是消息摘要算法
 * 返回 16位字符串类型的 MD5 hash值, 大写
 */
- (NSString *)MD5;

@end


@interface NSString (Validator)

// 邮箱
- (BOOL)validateEmail;

// 手机号码验证
- (BOOL)validateMobile;

// 车牌号验证
- (BOOL)validateCarNo;

// 车型
- (BOOL)validateCarType;

// 用户名
- (BOOL)validateUsername;

/**
 * 密码
 * 说明 密码验证数字与字母组合, 默认6-12位
 * 参数 min, 最少位
 * 参数 max, 最大位
 */
- (BOOL)validatePassword;
- (BOOL)validatePasswordWithMin:(unsigned int)min max:(unsigned int)max;

/**
 * 昵称
 * 说明 以中文开头, 默认4-8位
 * 参数 min, 最少位
 * 参数 max, 最大位
 */
- (BOOL)validateNickname;
- (BOOL)validateNicknameWithMin:(unsigned int)min max:(unsigned int)max;

// 身份证号
- (BOOL) validateIdentityCard;

/**
 * 验证码
 * 说明 纯数字验证码, 默认5位
 * 参数 size, 位数
 */
- (BOOL)validateVerifyCode;
- (BOOL)validateVerifyCodeWithSize:(unsigned int)size;

@end