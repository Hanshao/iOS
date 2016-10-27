//
//  NSString+Helper.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Helper.h"

@implementation NSString (URL)

- (NSString *)URLEncodedString {
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[] "), kCFStringEncodingUTF8));
    return result;
}
- (NSString*)URLDecodedString {
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    return result;
}


@end


@implementation NSString (Encryptor)
// 构造
+ (instancetype)stringFromBytes:(unsigned char *)bytes size:(int)size {
    NSMutableString *result = @"".mutableCopy;
    for (int i = 0; i < size; ++ i) {
        [result appendFormat:@"%02X", bytes[i]];
    }
    return [NSString stringWithString:result];
}
- (NSString *)SHA1 {
    const char *cString = self.UTF8String;
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cString, (unsigned int)strlen(cString), bytes);
    return [NSString stringFromBytes:bytes size:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)SHA256 {
    const char *cString = self.UTF8String;
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cString, (unsigned int)strlen(cString), bytes);
    return [NSString stringFromBytes:bytes size:CC_SHA256_DIGEST_LENGTH];
}
- (NSString *)SHA512 {
    const char *cString = self.UTF8String;
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(cString, (unsigned int)strlen(cString), bytes);
    return [NSString stringFromBytes:bytes size:CC_SHA512_DIGEST_LENGTH];
}
/**
 * MD5加密
 * 说明 MD5是消息摘要算法
 * 返回 16位字符串类型的 MD5 hash值, 大写
 */
- (NSString *)MD5 {
    const char *cString = self.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (unsigned int)strlen(cString), bytes);
    return [NSString stringFromBytes:bytes size:CC_MD5_DIGEST_LENGTH];
}
/**
 * 中文转换成拼音
 */
- (NSString *)pinyin {
    NSMutableString *mutable = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutable, NULL, kCFStringTransformToLatin, false);
    mutable = (NSMutableString *)[mutable stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [mutable stringByReplacingOccurrencesOfString:@"'" withString:@""];
}

@end


@implementation NSString (Validator)

// 邮箱
- (BOOL)isEmailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailAssert evaluateWithObject:self];
}
// 手机号码验证
- (BOOL)isMobileNumber {
    NSString *mobileRegex = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSPredicate *mobileAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobileAssert evaluateWithObject:self];
}
// 电话号码验证
- (BOOL)isPhoneNumber {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString *mobileRegex = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString *cmobileRegex = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString *cunicomRegex = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString *ctelecomRegex = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString *chlineRegex = @"^0(10|2[0-5789]|([3-9]\\d{2}))\\d{7,8}$";
    
    NSPredicate *mobileAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    NSPredicate *cmobileAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cmobileRegex];
    NSPredicate *cunicomAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cunicomRegex];
    NSPredicate *ctelecomAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ctelecomRegex];
    NSPredicate *chlineAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chlineRegex];
    
    return ([mobileAssert evaluateWithObject:self] || [chlineAssert evaluateWithObject:self] || [cmobileAssert evaluateWithObject:self]
            || [cunicomAssert evaluateWithObject:self] || [ctelecomAssert evaluateWithObject:self]);
}
// 车牌号验证
- (BOOL)isCarNumber {
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carAssert evaluateWithObject:self];
}
// 车型
- (BOOL)isCarType {
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carAssert evaluateWithObject:self];
}
// 用户名
- (BOOL)isAccount {
    NSString *accountRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *accountAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", accountRegex];
    return [accountAssert evaluateWithObject:self];
}
// 密码验证 密码验证数字与字母组合, 默认6-12位
- (BOOL)isKey {
    NSString *keyRegex = @"^[a-zA-Z0-9]{6,12}+$";
    NSPredicate *keyAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyRegex];
    return [keyAssert evaluateWithObject:self];
}
// 身份证号
- (BOOL)isIdentityNumber {
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityAssert evaluateWithObject:self];
}
// 验证码  纯数字验证码, 默认5位
- (BOOL)isVerifyCode {
    NSString *verifyCodeRegex = @"^[0-9]{5}$";
    NSPredicate *verifyAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",verifyCodeRegex];
    return [verifyAssert evaluateWithObject:self];
}
@end


@implementation NSString (Trimmer)
// 过滤首尾的空格和换行
- (NSString *)trimWhiteAndNewline {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
// 过滤首尾的空格
- (NSString *)trimWhite {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

// 过滤所有的空格和换行
- (NSString *)trimAllWhiteAndNewline {
    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
// 过滤所有的空格
- (NSString *)trimAllWhite {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}
@end

@implementation NSString (Constructor)

+ (instancetype)stringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    return [formatter stringFromDate:date];
}
+ (instancetype)jsonWithArray:(NSArray *)array {
    NSMutableString *json = @"[".mutableCopy;
    if (array.count > 0) {
        id value = array[0];
        [json appendString:@"\n"];
        [self json:json appendValue:value];
    }
    for (int i = 1; i < array.count; ++ i) {
        id value = array[i];
        
        [json appendString:@",\n"];
        [self json:json appendValue:value];
    }
    // 闭合
    [json appendString:@"\n]"];
    return [NSString stringWithString:json];
}
+ (void)json:(NSMutableString *)json appendValue:(id)value {
    if ([value isKindOfClass:NSNumber.class]) {
        // 基本类型
        [json appendFormat:@"%@", value];
    } else if ([value isKindOfClass:NSString.class]) {
        // 字符串类型
        [json appendFormat:@"\"%@\"", value];
    } else if ([value isKindOfClass:NSArray.class]) {
        // 数组
        [json appendFormat:@"%@", [self jsonWithArray:value]];
    } else if ([value isKindOfClass:NSDictionary.class]) {
        // 字典
        [json appendFormat:@"%@", [self jsonWithDictionary:value]];
    } else {
        @throw [NSException exceptionWithName:@"JSON string constructor error" reason:@"There exists something are not number/string/array/dictionary datatype." userInfo:nil];
    }
}
+ (instancetype)jsonWithDictionary:(NSDictionary *)dictionary {
    NSMutableString *json = @"{".mutableCopy;
    
    NSArray *keys = [dictionary allKeys];
    if (keys.count > 0) {
        NSString *key = keys[0];
        id value = dictionary[key];
        
        [json appendString:@"\n"];
        [self json:json appendKey:key value:value];
    }
    
    for (int i = 1; i < keys.count; ++ i) {
        NSString *key = keys[i];
        id object = [dictionary objectForKey:key];
        
        [json appendString:@",\n"];
        [self json:json appendKey:key value:object];
    }
    // 闭合
    [json appendString:@"\n}"];
    return [NSString stringWithString:json];
}
+ (void)json:(NSMutableString *)json appendKey:(NSString *)key value:(id)value {
    if ([value isKindOfClass:NSNumber.class]) {
        // 基本类型
        [json appendFormat:@"\"%@\":%@", key, value];
    } else if ([value isKindOfClass:NSString.class]) {
        // 字符串类型
        [json appendFormat:@"\"%@\":\"%@\"", key, value];
    } else if ([value isKindOfClass:NSArray.class]) {
        // 数组
        NSString *jsonForArray = [self jsonWithArray:value];
        [json appendFormat:@"\"%@\":%@", key, jsonForArray];
    } else if ([value isKindOfClass:NSDictionary.class]) {
        // 字典
        NSString *jsonForDictionary = [self jsonWithDictionary:value];
        [json appendFormat:@"\"%@\":%@", key, jsonForDictionary];
    } else {
        @throw [NSException exceptionWithName:@"JSON string constructor error" reason:@"There exists something are not number/string/array/dictionary datatype." userInfo:nil];
    }
}
@end

@implementation NSString (ASCII)
// 换算成ascii码的长度
- (NSUInteger)ascii_size {
    NSUInteger nsize = self.length;
    NSUInteger size = 0;
    
    for (int i = 0; i < nsize; ++ i) {
        unichar c = [self characterAtIndex:i]; // 按顺序取出单个字符
        if (isblank(c) || isascii(c)) {
            ++ size;
        } else {
            size += 2;
        }
    }
    
    return size;
}
@end