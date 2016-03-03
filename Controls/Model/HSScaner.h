//
//  HSCamera.h
//  CustomCameraDemo
//
//  Created by Shaojun Han on 10/12/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/**
 * 扫码类型
 */
extern NSString *const AVMetadataObjectTypeQRCode;      // 二维码
extern NSString *const AVMetadataObjectTypeEAN13Code;   // 13位数字条码
extern NSString *const AVMetadataObjectTypeEAN8Code;    // 8位数字条码
extern NSString *const AVMetadataObjectTypeCode128Code; // ASCII条码

@class HSScaner;

/**
 * 扫码代理类
 * 扫描完条码或者二维码之后回调
 */
@protocol HSScanerDelegate <NSObject>

@optional
- (void)scanner:(HSScaner *)scanner didCapture:(NSString *)codeString;

@end

/**
 * 条码/QR扫描类
 */
@interface HSScaner : NSObject

// 初始化器
// 默认条码和二维码都扫描
// delegate 扫描完成时回调代理
// queue 代理队列
// types 扫描类型，上面个列出的4种的任意组合
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate codeTypes:(NSArray *)types;
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate queue:(dispatch_queue_t)queue;
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate queue:(dispatch_queue_t)queue codeTypes:(NSArray *)types;

// 重新设置扫描区域
- (void)setActiveRectangle:(CGRect)rectangle;
// 插入预览
- (void)insertPrelayer:(UIView *)prelayer;

// 启动
- (void)startRunning;
// 停止
- (void)stopRunning;

@end
