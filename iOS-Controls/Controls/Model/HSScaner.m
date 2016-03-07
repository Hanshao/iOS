//
//  HSCamera.m
//  CustomCameraDemo
//
//  Created by Shaojun Han on 10/12/15.
//  Copyright © 2015 HadLinks. All rights reserved.
//

#import "HSScaner.h"

@interface HSScaner () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession              *session;           // 会话
@property (strong, nonatomic) AVCaptureDevice               *device;            // 设备
@property (strong, nonatomic) AVCaptureDeviceInput          *input;             // 输入
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    *previewLayer;      // 预览层
@property (strong, nonatomic) AVCaptureMetadataOutput       *output;            // 输出
@property (weak, nonatomic) id<HSScanerDelegate>            delegate;           // 代理

@end

@implementation HSScaner

/**
 * 初始化器
 * 默认条码和二维码都扫描
 */
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate {
    return [self initWithDelegate:delegate
                            queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                        codeTypes:@[AVMetadataObjectTypeQRCode]];
}
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate codeTypes:(NSArray *)types {
    return [self initWithDelegate:delegate
                            queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) codeTypes:types];
}
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate queue:(dispatch_queue_t)queue {
    return [self initWithDelegate:delegate queue:queue codeTypes:@[AVMetadataObjectTypeQRCode]];
}
- (instancetype)initWithDelegate:(id<HSScanerDelegate>)delegate queue:(dispatch_queue_t)queue codeTypes:(NSArray *)types {
    if (self = [super init]) {
        self.delegate = delegate;
        [self setupQueue:queue codeTypes:types];
    }
    return self;
}

/**
 * 启动
 */
- (void)startRunning {
    [self.session startRunning];
}

/**
 * 停止
 */
- (void)stopRunning {
    [self.session stopRunning];
}

/**
 * 初始化
 * delegate 扫码代理
 * types 扫码类型
 */
- (void)setupQueue:(dispatch_queue_t)queue codeTypes:(NSArray *)codeTypes {
    // setup device 设备配置
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_device) return;
    if ([_device lockForConfiguration:nil]) {
        if (_device.autoFocusRangeRestrictionSupported)
            _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        if (_device.smoothAutoFocusSupported) _device.smoothAutoFocusEnabled = YES;   // 平滑自动聚焦
        _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;  // 自动聚焦
        _device.exposureMode = AVCaptureExposureModeAutoExpose;
        [_device unlockForConfiguration];
    }
    // add device input to session 设备输入
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:queue];
    // create session
    _session = [AVCaptureSession new];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:_input];
    [_session addOutput:_output];
    
    [_output setMetadataObjectTypes:codeTypes];
    AVCaptureConnection *outputConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    outputConnection.videoOrientation = [HSScaner videoOrientationFromCurrentDeviceOrientation];
}

/**
 * 重新设置扫描区域
 */
- (void)setActiveRectangle:(CGRect)rectangle {
    [_output setRectOfInterest:rectangle];
}

/**
 * 插入预览
 * 输出层
 */
- (void)insertPrelayer:(UIView *)prelayer {
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResize;
    _previewLayer.frame = prelayer.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [prelayer.layer insertSublayer:_previewLayer atIndex:0];
}

#pragma mark
#pragma mark 代理
/**
 * 扫描回调代理
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([metadataObjects count] > 0 && [self.delegate respondsToSelector:@selector(scanner:didCapture:)]) {
        AVMetadataMachineReadableCodeObject *metaCodeObject = [metadataObjects firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate scanner:self didCapture:[metaCodeObject stringValue]];
        });
    }
}

+ (AVCaptureVideoOrientation)videoOrientationFromCurrentDeviceOrientation {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        NSLog(@"UIInterfaceOrientationPortrait");
        return AVCaptureVideoOrientationPortrait;
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        NSLog(@"AVCaptureVideoOrientationLandscapeLeft");
        return AVCaptureVideoOrientationLandscapeLeft;
        
    } else if (orientation == UIInterfaceOrientationLandscapeRight){
        NSLog(@"UIInterfaceOrientationLandscapeRight");
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    return AVCaptureVideoOrientationPortrait;
}
@end
