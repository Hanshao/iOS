//
//  ViewHelper.h
//  SHVideoHelper
//
//  Created by Shaojun Han on 7/6/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* These export options can be used to produce movie files with video size appropriate to the device.
 The export will not scale the video up from a smaller size. The video will be compressed using
 H.264 and the audio will be compressed using AAC.  */
extern NSString *const AVAssetExportPresetLowQuality        NS_AVAILABLE(10_11, 4_0);
extern NSString *const AVAssetExportPresetMediumQuality     NS_AVAILABLE(10_11, 4_0);
extern NSString *const AVAssetExportPresetHighestQuality    NS_AVAILABLE(10_11, 4_0);

/* These export options can be used to produce movie files with the specified video size.
 The export will not scale the video up from a smaller size. The video will be compressed using
 H.264 and the audio will be compressed using AAC.  Some devices cannot support some sizes. */
extern NSString *const AVAssetExportPreset640x480 NS_AVAILABLE(10_7, 4_0);
extern NSString *const AVAssetExportPreset960x540 NS_AVAILABLE(10_7, 4_0);
extern NSString *const AVAssetExportPreset1280x720 NS_AVAILABLE(10_7, 4_0);
extern NSString *const AVAssetExportPreset1920x1080 NS_AVAILABLE(10_7, 5_0);
extern NSString *const AVAssetExportPreset3840x2160 NS_AVAILABLE(10_10, 9_0);

typedef NS_ENUM(NSInteger, VideoExportStatus) {
    VideoExportStatusUnknown,
    VideoExportStatusWaiting,
    VideoExportStatusExporting,
    VideoExportStatusCompleted,
    VideoExportStatusFailed,
    VideoExportStatusCancelled
};

@class VideoHelper;

/**
 * 视频录制代理
 * @param vhelper VideoHelper对象
 * @param filePath 录制结束后保存路径, 此路径为临时储存路径
 */
@protocol VideoHelperDelegate <NSObject>
@optional
- (void)videoStartRecording:(VideoHelper *)vhelper;
- (void)videoFinishRecording:(VideoHelper *)vhelper filePath:(NSString *)filePath;

@end

@interface VideoHelper : NSObject

@property (weak, nonatomic) id<VideoHelperDelegate> delegate;

/**
 * 初始化方法
 */
- (instancetype)initWithDelegate:(id<VideoHelperDelegate>)delegate;

/**
 * 插入预览
 * @param parentLayer 预览层的父层
 */
- (void)insertVideoPreviewLayerWithParentLayer:(CALayer *)parentLayer;

/**
 * 启动预览
 */
- (void)startPreviewing;

/**
 * 停止预览
 */
- (void)stopPreviewing;

/**
 * 启动录制
 * @param duration 录制时间, 超过时间后录制自动停止
 */
- (void)startRecordingWithDuration:(double)duration;

/**
 * 启动录制, 此方法将取消录制时间限制
 */
- (void)startRecording;

/**
 * 停止录制
 */
- (void)stopRecording;

/**
 * 获取视频大小
 * @param savedPath 文件路径
 * @return 返回文件大小, M单位
 */
+ (CGFloat)getfileSize:(NSString *)savedPath;

/**
 * 压缩完成时回调
 * @param status 压缩状态回调
 * @param path 压缩后保存路径
 * @param error status为VideoExportStatusFailed时, 错误原因
 */
typedef void (^VideoExportHandler)(VideoExportStatus status, NSString *path, NSError *error);

/**
 * 压缩视频文件
 * @param savedPath 视频原始路径
 * @param completion 压缩后的回调
 */
+ (void)compressAndExportVideoAtPath:(NSString *)savedPath completion:(VideoExportHandler)completion;

///** 该方法存在bug, 不提供使用
// * 多个短视频合并为单个长视频
// * @param fileURLArray 文件URL
// * @param completion 合并完成时回调
// */
//+ (void)mergeAndExportVideosAtFilePaths:(NSArray *)filePathArray completion:(VideoExportHandler)completion;

/**
 * 视频保存完成时回调
 * @param error 错误信息
 */
typedef void (^VideoSaveHandler)(NSError *error);

/**
 * 将视频文件保存到默认相册
 * @param savedPath 视频保存的路径
 * @param completion 完成时回调
 */
+ (void)saveVideoAtPath:(NSString *)savedPath completion:(VideoSaveHandler)completion;

/**
 * 将视频文件保存到指定相册
 * @param savedPath 视频保存的路径
 * @param album 相册
 * @param completion 完成时回调
 */
+ (void)saveVideoAtPath:(NSString *)savedPath toAlbum:(NSString *)album completion:(VideoSaveHandler)completion;


@end
