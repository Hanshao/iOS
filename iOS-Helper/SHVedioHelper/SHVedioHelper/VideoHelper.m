//
//  ViewHelper.m
//  SHVideoHelper
//
//  Created by Shaojun Han on 7/6/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "VideoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (VideoHelper)

@end

@implementation ALAssetsLibrary (VideoHelper)
// 保存图片
- (void)writeVideoAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completionHandler:(void (^)(NSError *error))completionHandler {
    if ([self videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]) {
        [self writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                if (completionHandler) completionHandler(error);
            } else {
                // 创建相册, 如果已经存在则将图片保存到相册
                [self addAssetURL:assetURL toAlbum:album completionHandler:^(NSError *error) {
                    if (completionHandler) completionHandler(error);
                }];
            }
        }];
    }
}
- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)album completionHandler:(ALAssetsLibraryAccessFailureBlock)completionHandler {
    void (^assetForURLBlock)(NSURL *, ALAssetsGroup *) = ^(NSURL *URL, ALAssetsGroup *group) {
        [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [group addAsset:asset];
            completionHandler(nil);
        } failureBlock:^(NSError *error) { completionHandler(error); }];
    };
    __block ALAssetsGroup *mygroup;
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([album isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]) {
            mygroup = group; // 已经存在
        }
        if (group) return; // 循环结束
        
        if (mygroup) {
            assetForURLBlock(assetURL, mygroup);
        } else {
            [self addAssetsGroupAlbumWithName:album resultBlock:^(ALAssetsGroup *group) {
                assetForURLBlock(assetURL, group);
            } failureBlock:completionHandler];
        }
        
    } failureBlock:completionHandler];
}
@end

@interface VideoHelper ()
<
AVCaptureFileOutputRecordingDelegate
>
@property (strong, nonatomic) AVCaptureSession *session;        // 会话层
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput; // 视频输入层
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput; // 音频输入层
@property (strong, nonatomic) AVCaptureMovieFileOutput *videoFileOutput; // 文件输出层
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;  // 预览层
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;  // 后台任务标识
@property (strong, nonatomic) NSMutableDictionary *filePaths;   // 路径
@end

@implementation VideoHelper

- (instancetype)init {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<VideoHelperDelegate>)delegate {
    if (self = [super init]) {
        [self initialize];
        self.delegate = delegate;
        self.filePaths = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initialize {
    _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        // 设置会话的 sessionPreset 属性, 这个属性影响视频的分辨率
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    // 获取摄像头输入设备， 创建 AVCaptureDeviceInput 对象
    // 在获取摄像头的时候，摄像头分为前后摄像头，我们创建了一个方法通过用摄像头的位置来获取摄像头
    AVCaptureDevice *videoDevice = [self cameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!videoDevice) {
        NSLog(@"---- 取得后置摄像头时出现问题---- ");
        return;
    }
    // 视频输入对象
    // 根据输入设备初始化输入对象，用户获取输入数据
    NSError *error = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"---- 取得设备输入对象时出错 ------ %@",error);
        return;
    }
    
    // 添加一个音频输入设备
    // 直接可以拿数组中的数组中的第一个
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    // 音频输入对象
    // 根据输入设备初始化设备输入对象，用于获得输入数据
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错 ------ %@",error);
        return;
    }
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _videoFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if (!_videoFileOutput) {
        NSLog(@"创建设备输出对象时出错 ------ ");
        return;
    }
    
    {   // 配置视频输出对象
        _videoFileOutput.minFreeDiskSpaceLimit = 1024 * 1024; // set min free space in bytes for recording to continue on a volume
    }
    
    // 将视频输入对象添加到会话 (AVCaptureSession) 中
    if ([_session canAddInput:_videoInput]) {
        [_session addInput:_videoInput];
    }
    // 将音频输入对象添加到会话 (AVCaptureSession) 中
    if ([_session canAddInput:_audioInput]) {
        [_session addInput:_audioInput];
    }
    if ([_session canAddOutput:_videoFileOutput]) {
        [_session addOutput:_videoFileOutput];
    }
    AVCaptureConnection *connection = [_videoFileOutput connectionWithMediaType:AVMediaTypeVideo];
    // 标识视频录入时稳定音频流的接受，我们这里设置为自动
    if ([connection isVideoStabilizationSupported]) {
        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
}

/**
 *  取得指定位置的摄像头
 *  @param position 摄像头位置
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

/**
 * 插入预览
 * @param parentLayer 预览层的父层
 */
- (void)insertVideoPreviewLayerWithParentLayer:(CALayer *)parentLayer {
    if (!parentLayer) return;   // 无效的calayer
    // 懒加载
    if (!_previewLayer) {
        // 通过会话 (AVCaptureSession) 创建预览层
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        _previewLayer.masksToBounds = true;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    }
    // frame
    _previewLayer.frame = parentLayer.bounds;
    [parentLayer addSublayer:_previewLayer];
}

/**
 * 启动预览
 */
- (void)startPreviewing {
    [self.session startRunning];
}

/**
 * 停止预览
 */
- (void)stopPreviewing {
    [self.session stopRunning];
}

/**
 * 启动录制
 */
- (void)startRecordingWithDuration:(double)duration {
    // [self stopRecording];
    
    {   // 配置输出参数
        Float64 totalSeconds = duration; // total seconds
        int32_t preferredTimeScale = 30; // frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(totalSeconds, preferredTimeScale); // set mac duration
        self.videoFileOutput.maxRecordedDuration = maxDuration;
        self.videoFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    }

    [self startRecordingAndOutputToTmpFile];
}
- (void)startRecording {
    // [self stopRecording];
    
    {   // 配置输出参数
        self.videoFileOutput.maxRecordedDuration = kCMTimeInvalid;
        self.videoFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    }
    
    [self startRecordingAndOutputToTmpFile];
}
- (void)startRecordingAndOutputToTmpFile {
    // 设置视频输出的文件路径，这里设置为 temp 文件
    NSString *outputFilePath = [self.class getVideoFilePathString];
    // 路径转换成 URL 要用这个方法，用 NSBundle 方法转换成 URL 的话可能会出现读取不到路径的错误
    NSURL *fileURL = [NSURL fileURLWithPath:outputFilePath];
    [self.filePaths setObject:outputFilePath forKey:fileURL];
    [self startRecording:fileURL];
}
- (void)startRecording:(NSURL *)fileURL {
    AVCaptureConnection *connection = [self.videoFileOutput connectionWithMediaType:AVMediaTypeVideo];
    // 开启视频防抖模式
    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    if ([self.videoInput.device.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
        [connection setPreferredVideoStabilizationMode:stabilizationMode];
    }
    
    // 如果支持多任务则则开始多任务
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    }
    // 预览图层和视频方向保持一致,这个属性设置很重要，如果不设置，那么出来的视频图像可以是倒向左边的。
    connection.videoOrientation = [self.previewLayer connection].videoOrientation;
    // 往路径的 URL 开始写入录像 Buffer , 边录边写
    [self.videoFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}
/**
 * 停止录制
 */
- (void)stopRecording {
    // 取消视频拍摄
    [self.videoFileOutput stopRecording];
}

#pragma mark
#pragma mark 代理方法
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"---- 开始录制 at url = %@", fileURL);
    if ([self.delegate respondsToSelector:@selector(videoStartRecording:)]) {
        [self.delegate videoStartRecording:self];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"---- 录制结束 at url = %@, current thread = %@, isRecording = %d",
          fileURL, [NSThread currentThread], captureOutput.isRecording);
    if (self.backgroundTaskIdentifier) {
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        }
        self.backgroundTaskIdentifier = 0;
    }    
    
    if ([self.delegate respondsToSelector:@selector(videoFinishRecording:filePath:)]) {
        NSString *filePath = [self.filePaths objectForKey:fileURL];
        [self.delegate videoFinishRecording:self filePath:filePath];
        [self.filePaths removeObjectForKey:fileURL];
    }
}

///**
// * 多个短视频合并为单个长视频
// * @param fileURLArray 文件URL
// * @param completion 合并完成时回调
// */
//+ (void)mergeAndExportVideosAtFilePaths:(NSArray *)filePathArray completion:(VideoExportHandler)completion {
//    NSError *error = nil;
//    CGSize renderSize = CGSizeMake(0, 0);
//    
//    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
//    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
//    
//    CMTime totalDuration = kCMTimeZero;
//    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
//    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
//    for (NSString *filePath in filePathArray) {
//        
//        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//        AVAsset *asset = [AVAsset assetWithURL:fileURL];
//        NSArray *tmpArray = [asset tracksWithMediaType:AVMediaTypeVideo];
//        
//        if (tmpArray.count > 0) {
//            AVAssetTrack *assetTrack = [tmpArray firstObject];
//            [assetTrackArray addObject:assetTrack];
//            [assetArray addObject:asset];
//            
//            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.width);
//            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.height);
//        }
//    }
//    
////    CGFloat renderWidth = MIN(renderSize.width, renderSize.height);
//    for (int i = 0; i < assetArray.count && i < assetTrackArray.count; ++ i) {
//        
//        AVAsset *asset = [assetArray objectAtIndex:i];
//        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
//        
//        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//        NSArray *dataSourceArray = [asset tracksWithMediaType:AVMediaTypeAudio];
//        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                            ofTrack:([dataSourceArray count] > 0) ? [dataSourceArray firstObject] : nil
//                             atTime:totalDuration
//                              error:nil];
//        
//        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                            ofTrack:assetTrack
//                             atTime:totalDuration
//                              error:&error];
//        
//        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//        
//        totalDuration = CMTimeAdd(totalDuration, asset.duration);
////        CGFloat rate = renderWidth / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
//        
////        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
//        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx, assetTrack.preferredTransform.ty);
//        // layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, - (assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0 + preLayerHWRate * (preLayerHeight - preLayerWidth) / 2));
//        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, - (assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));
////        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
//        
//        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
//        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
//        
//        [layerInstructionArray addObject:layerInstruciton];
//    }
//    
//    AVMutableVideoCompositionInstruction *instruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    instruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
//    instruciton.layerInstructions = layerInstructionArray;
//    AVMutableVideoComposition *compositionInst = [AVMutableVideoComposition videoComposition];
//    compositionInst.instructions = @[instruciton];
//    compositionInst.frameDuration = CMTimeMake(1, 100);
////    compositionInst.renderSize = CGSizeMake(renderWidth, renderWidth);
//    compositionInst.renderSize = renderSize;
//    // compositionInst.renderSize = CGSizeMake(renderWidth, renderWidth * preLayerHWRate);
//    
//    NSString *mergeFilePath = [self getVideoMergeFilePathString];
//    [self exportVideoWithAsset:composition quality:AVAssetExportPresetMediumQuality constructor:^(AVAssetExportSession *exporter) {
//        NSURL *mergeFileURL = [NSURL fileURLWithPath:mergeFilePath];
//        exporter.videoComposition = compositionInst;
//        exporter.outputURL = mergeFileURL;
//    } completion:^(AVAssetExportSession *exporter) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 视频合并结果
//            if (completion) {
//                completion((VideoExportStatus)[exporter status], mergeFilePath, [exporter error]);
//            }
//        });
//    }];
//}
/**
 * 创建字符串
 * @return 返回yyyyMMddHHmmss格式的NSDateFormatter
 */
+ (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter = nil;
    if (formatter) return formatter;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return formatter;
}

/**
 * 创建视频文件路径
 * @return 视屏文件路径
 */
+ (NSString *)getVideoFilePathString {
    NSString *nowTimeStr = [[self formatter] stringFromDate:[NSDate date]];
    nowTimeStr = [nowTimeStr stringByAppendingString:@".mp4"];
    
    return [NSTemporaryDirectory() stringByAppendingPathComponent:nowTimeStr];
}

/**
 * 获取合并的视频文件的路径
 * @return 合并的视频文件的路径
 */
+ (NSString *)getVideoMergeFilePathString {
    NSString *nowTimeStr = [[self formatter] stringFromDate:[NSDate date]];
    nowTimeStr = [nowTimeStr stringByAppendingString:@"M.mp4"];
    
    return [NSTemporaryDirectory() stringByAppendingPathComponent:nowTimeStr];
}

/**
 * 压缩视频文件
 * @param savedPath 视频原始路径
 * @param completion 压缩后的回调
 */
+ (void)compressAndExportVideoAtPath:(NSString *)savedPath completion:(VideoExportHandler)completion {
    // 通过文件的 url 获取到这个文件的资源
    NSURL *savedURL = [NSURL fileURLWithPath:savedPath];
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:savedURL options:nil];
    // 用 AVAssetExportSession 这个类来导出资源中的属性
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    // 压缩视频
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) { // 导出属性是否包含低分辨率
        // 通过资源（AVURLAsset）来定义 AVAssetExportSession，得到资源属性来重新打包资源 （AVURLAsset, 将某一些属性重新定义
        NSString *outputPath = [self getVideoFilePathString];
        [self exportVideoWithAsset:avAsset quality:AVAssetExportPresetLowQuality constructor:^(AVAssetExportSession *exporter) {
            // 设置导出文件的存放路径
            exporter.outputURL = [NSURL fileURLWithPath:outputPath];
        } completion:^(AVAssetExportSession *exporter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion((VideoExportStatus)[exporter status], outputPath, [exporter error]);
                }
                if (exporter.status == AVAssetExportSessionStatusFailed) {
                    NSLog(@"export error = %@", [exporter error]);
                }
            });
        }];
    }
}

/**
 * 导出视频
 * @param avAsset 需要保存的视频数据
 * @param quality 保存后的视频质量
 * @param constructor 构造block
 * @param completion 完成时回调
 */
+ (void)exportVideoWithAsset:(AVAsset *)avAsset quality:(NSString *)quality constructor:(void (^)(AVAssetExportSession *exporter))constructor completion:(void (^)(AVAssetExportSession *exporter))completion {
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:quality];
    // 处理前的操作
    if (constructor) constructor(exporter);
    // 是否对网络进行优化
    exporter.shouldOptimizeForNetworkUse = true;
    // 转换成MP4格式
    exporter.outputFileType = AVFileTypeMPEG4;
    // 开始导出,导出后执行完成的block
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (completion) completion(exporter);
    }];
}

/**
 * 将视频文件保存到默认相册
 * @param savedPath 视频保存的路径
 * @param completion 保存完成时回调
 */
+ (void)saveVideoAtPath:(NSString *)savedPath completion:(VideoSaveHandler)completion {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:savedPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (completion) completion(error);
                                }];
}

/**
 * 将视频文件保存到指定相册
 * @param savedPath 视频保存的路径
 * @param album 相册
 * @param completion 完成时回调
 */
+ (void)saveVideoAtPath:(NSString *)savedPath toAlbum:(NSString *)album completion:(VideoSaveHandler)completion {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPath:[NSURL fileURLWithPath:savedPath] toAlbum:album completionHandler:^(NSError *error) {
        if (completion) completion(error);
    }];
}

/**
 * 获取文件大小
 * @param savedPath 文件路径
 * @return 返回文件大小, M单位
 */
+ (CGFloat)getfileSize:(NSString *)savedPath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:savedPath error:nil];
    return (CGFloat)[fileAttributes fileSize] / 1024.00 / 1024.00;
}

@end
