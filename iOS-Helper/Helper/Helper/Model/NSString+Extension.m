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

//邮箱
- (BOOL)validateEmail {
    if (self.length <= 0) return NO;

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

//手机号码验证
- (BOOL)validateMobile {
    if (self.length <= 0) return NO;

    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

//车牌号验证
- (BOOL)validateCarNo {
    if (self.length <= 0) return NO;

    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:self];
}

//车型
- (BOOL)validateCarType {
    if (self.length <= 0) return NO;

    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carTest evaluateWithObject:self];
}

//用户名
- (BOOL)validateAccount {
    if (self.length <= 0) return NO;

    NSString *accountRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *accountPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", accountRegex];
    BOOL B = [accountPredicate evaluateWithObject:self];
    return B;
}
// 密码验证 密码验证数字与字母组合, 默认6-12位
- (BOOL)validateKey {
    if (self.length <= 0) return NO;

    NSString *keyRegex = @"^[a-zA-Z0-9]{6,12}+$";
    NSPredicate *keyPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyRegex];
    return [keyPredicate evaluateWithObject:self];
}
//身份证号
- (BOOL)validateIdentityCard {
    if (self.length <= 0) return NO;
    
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:self];
}

/**
 * 验证码
 * 说明 纯数字验证码, 默认5位
 * 参数 size, 位数
 */
- (BOOL)validateVerifyCode {
    if (self.length <= 0) return NO;

    NSString *verifyCodeRegex = @"^[0-9]{5}$";
    NSPredicate *verifyPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",verifyCodeRegex];
    return [verifyPredicate evaluateWithObject:self];
}
- (BOOL)validateVerifyCodeWithSize:(unsigned int)size {
    NSString *verifyCodeRegex = [NSString stringWithFormat:@"^[0-9]{%d}$", size];
    NSPredicate *verifyPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",verifyCodeRegex];
    return [verifyPredicate evaluateWithObject:self];
}

@end
