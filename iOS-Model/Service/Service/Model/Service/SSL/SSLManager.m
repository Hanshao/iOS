//
//  SSLManager.m
//  ProtocolTest
//
//  Created by Shaojun Han on 9/21/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "SSLManager.h"

@implementation SSLManager

/**
 * 生成证书配置
 * 参数 host 主机
 * 参数 params 证书配置中添加的额外参数, 可以为nil
 * 参数 file 证书文件名
 * 参数 pass 证书文件密码
 */
+ (NSDictionary *)sslSettingsWithHost:(NSString *)host
                                 file:(NSString *)file key:(NSString *)key other:(NSDictionary *)other {
    
    NSMutableDictionary *sslSettings = nil;
    
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:nil]];
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    
    CFStringRef password = CFStringCreateWithCString(NULL, [key cStringUsingEncoding:NSASCIIStringEncoding], kCFStringEncodingASCII);
    const void *keys[] = { kSecImportExportPassphrase }, *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    
    // @result errSecSuccess in case of success. errSecDecode means either the blob can't be read or it is malformed. errSecAuthFailed means an incorrect password was passed, or data in the container got damaged.
    NSLog(@"%s : securityError = %d", __FUNCTION__, (int)securityError);
    
    if(securityError == errSecSuccess) {
        NSLog(@"%s : Success opening p12 certificate.", __FUNCTION__);
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef myIdentity = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        SecIdentityRef certArray[1] = { myIdentity };
        CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        
        sslSettings = [[NSMutableDictionary alloc] init];
        [sslSettings setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
        [sslSettings setObject:host forKey:(NSString *)kCFStreamSSLPeerName];
        if (other) [sslSettings addEntriesFromDictionary:other];
        
    } else {
        if (errSecDecode == securityError)
            NSLog(@"%s : Failed to read p12 or its form is bad.", __FUNCTION__);
        else if (errSecAuthFailed == securityError)
            NSLog(@"%s : Password is bad or data in p12 is bad.", __FUNCTION__);
        else
            NSLog(@"%s : Unknow error occurred.", __FUNCTION__);
    }
    // You can not release the object items. If you do that, it will crash immediately. But if you don't it will leaks some memory.
    // CFAutorelease(items);
    CFAutorelease(options);
    CFAutorelease(password);
    CFAutorelease(inPKCS12Data);
    
    return sslSettings;
}

@end
