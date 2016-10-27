//
//  ViewController.m
//  SHVideoHelper
//
//  Created by Shaojun Han on 7/6/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"
#import "VideoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()
<
    VideoHelperDelegate
>
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) VideoHelper *videoHelper;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playItem;
@property (strong, nonatomic) AVPlayerLayer *playLayer;
@property (strong, nonatomic) NSMutableArray *pathArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pathArray = @[].mutableCopy;

    self.videoHelper = [[VideoHelper alloc] initWithDelegate:self];
    [self.videoHelper insertVideoPreviewLayerWithParentLayer:self.view.layer];
    self.view.layer.masksToBounds = YES;
    [self.view bringSubviewToFront:self.container];
    [self.videoHelper startPreviewing];
    [self.videoHelper startRecordingWithDuration:12.0];
}

- (void)videoStartRecording:(VideoHelper *)vhelper {
    NSLog(@"%s", __FUNCTION__);
}
- (void)videoFinishRecording:(VideoHelper *)vhelper filePath:(NSString *)path {
    CGFloat size = [VideoHelper getfileSize:path];
    NSLog (@"origion file size: %f M", size);
    [self.pathArray addObject:path];
    [self.videoHelper stopPreviewing];
    [self mergeAndExportAndPlay:self.pathArray];
}
- (void)mergeAndExportAndPlay:(NSArray *)pathArray {
    
    __weak typeof(self) wself = self;
    NSString *path = [pathArray firstObject];
//    [VideoHelper mergeAndExportVideosAtFilePaths:pathArray completion:^(VideoExportStatus status, NSString *path, NSError *error) {
//        NSLog(@"error = %@", error);
        [VideoHelper saveVideoAtPath:path toAlbum:@"VideoHelper" completion:nil];
        CGFloat size = [VideoHelper getfileSize:path];
        NSLog (@"merge file size: %f M", size);
        [VideoHelper compressAndExportVideoAtPath:path completion:^(VideoExportStatus status, NSString *path, NSError *error) {
            CGFloat size = [VideoHelper getfileSize:path];
            NSLog (@"compress file size: %f M", size);
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
            AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:movieAsset];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playItem];
            
            AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:player];
            playLayer.frame = wself.container.bounds;
            [wself.container.layer addSublayer:playLayer];
            wself.playLayer = playLayer;
            wself.playItem = playItem;
            wself.player = player;
            [player play];
        }];
//    }];
}

@end
