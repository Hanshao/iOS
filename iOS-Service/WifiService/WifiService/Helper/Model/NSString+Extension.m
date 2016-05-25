//
//  NSString+Extension.m
//  Helper
//
//  Created by Shaojun Han on 3/7/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Extension.h"

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
/**
 * 中文转换成拼音
 */
- (NSString *)pinyin {
    NSMutableString *mutable = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutable, NULL, kCFStringTransformToLatin, false);
    mutable = (NSMutableString *)[mutable stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [mutable stringByReplacingOccurrencesOfString:@"'" withString:@""];
}
/**
 * MD5加密
 * 说明 MD5是消息摘要算法
 * 返回 16位字符串类型的 MD5 hash值, 大写
 */
- (NSString *)MD5 {
    const char *cStr = self.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    NSMutableString *hash = [NSMutableString string];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; ++ i){
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash uppercaseString];
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
    NSString *chandRegex = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *mobileAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    NSPredicate *cmobileAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cmobileRegex];
    NSPredicate *cunicomAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cunicomRegex];
    NSPredicate *ctelecomAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ctelecomRegex];
    NSPredicate *chandAssert = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chandRegex];
    
    return ([mobileAssert evaluateWithObject:self] || [chandAssert evaluateWithObject:self] || [cmobileAssert evaluateWithObject:self]
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
