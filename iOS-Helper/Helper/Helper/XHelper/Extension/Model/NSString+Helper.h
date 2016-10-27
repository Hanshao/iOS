//
//  NSString+Helper.h
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
 * 4. 构造
 */
@interface NSString (URL)
// URL编码(对URL中的中文进行转码)
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
@end

@interface NSString (Encryptor)
/**
 * SHA1, SHA256, SHA512信息摘要算法
 * 返回 16进制形式的摘要字符串, 大写
 */
- (NSString *)SHA1;
- (NSString *)SHA256;
- (NSString *)SHA512;
/**
 * MD5信息摘要算法
 * 返回 16进制形式的摘要字符串, 大写
 */
- (NSString *)MD5;
/**
 * 中文转换成拼音
 */
- (NSString *)pinyin;
@end


@interface NSString (Validator)
// 邮箱
- (BOOL)isEmailAddress;
// 手机号码验证
- (BOOL)isMobileNumber;
// 电话号码验证
- (BOOL)isPhoneNumber;
// 车牌号验证
- (BOOL)isCarNumber;
// 车型
- (BOOL)isCarType;
// 用户名
- (BOOL)isAccount;
// 密码验证 密码验证数字与字母组合, 默认6-12位
- (BOOL)isKey;
// 身份证号
- (BOOL)isIdentityNumber;
// 验证码  纯数字验证码, 默认5位
- (BOOL)isVerifyCode;
@end

@interface NSString (Trimmer)
// 过滤首尾的空格和换行
- (NSString *)trimWhiteAndNewline;
// 过滤首尾的空格
- (NSString *)trimWhite;
// 过滤所有的空格和换行
- (NSString *)trimAllWhiteAndNewline;
// 过滤所有的空格
- (NSString *)trimAllWhite;
@end

@interface NSString (Constructor)
// 根据日期创建字符串
+ (instancetype)stringFromDate:(NSDate *)date;
+ (instancetype)jsonWithArray:(NSArray *)array;
+ (instancetype)jsonWithDictionary:(NSDictionary *)dict;
@end

@interface NSString (ASCII)
// 换算成ascii码的长度
- (NSUInteger)ascii_size;
@end
