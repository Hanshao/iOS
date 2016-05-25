//
//  HSSlideShowView.m
//  Controls
//
//  Created by Shaojun Han on 3/23/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSSlideShowView.h"
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, HSSlideSliceType) {
    HSSlideSliceWebType = 1,     // 网络图片
    HSSlideSliceBundleType = 2, // 本地图片
    HSSlideSliceImageType = 3   // 内存图片
};

@interface HSSlideSlice : NSObject
<
    NSURLConnectionDelegate
>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic, readonly) id attachment;    // 对应类型web, bundle, image分别是NSString, NSString, UIImage
@property (strong, nonatomic, readonly) UIImage *placeHolder;
@property (assign, nonatomic, readonly) HSSlideSliceType sliceType;

+ (instancetype)sliceWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType;
+ (instancetype)sliceWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType placeHolder:(UIImage *)placeHolder;

- (instancetype)initWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType;
- (instancetype)initWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType placeHolder:(UIImage *)placeHolder;

@end


@implementation HSSlideSlice

+ (instancetype)sliceWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType {
    return [self sliceWithAttachment:attachment sliceType:sliceType placeHolder:nil];
}
+ (instancetype)sliceWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType placeHolder:(UIImage *)placeHolder {
    return [[HSSlideSlice alloc] initWithAttachment:attachment sliceType:sliceType placeHolder:placeHolder];
}

- (instancetype)initWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType {
    return [self initWithAttachment:attachment sliceType:sliceType placeHolder:nil];
}
- (instancetype)initWithAttachment:(id)attachment sliceType:(HSSlideSliceType)sliceType placeHolder:(UIImage *)placeHolder {
    if (!(self = [super init])) return self;
    
    _attachment = attachment;
    _sliceType = sliceType;
    _placeHolder = placeHolder;
    
    [self reloadSliceImage];
    return self;
}
- (void)reloadSliceImage {
    switch (self.sliceType) {
        case HSSlideSliceWebType: {
        } break;
        case HSSlideSliceImageType: {
            _image = self.attachment;
        } break;
        case HSSlideSliceBundleType: {
            NSString *imageName = self.attachment;
            _image = [UIImage imageNamed:imageName];
        } break;
    }
}
@end


/**
 * HSSlideShowView 轮播图试图类
 */
@interface HSSlideShowView ()
<
    UIScrollViewDelegate
>
@end

@interface HSSlideShowView ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *imageViewArray;
@end

@interface HSSlideShowView ()
@property (strong, nonatomic) NSArray *attachArray;
@end

@interface HSSlideShowView ()
@property (strong, nonatomic) NSTimer *slideTimer;
@property (assign, nonatomic) BOOL pauseByExternal;
@end

@implementation HSSlideShowView

#pragma mark
#pragma mark Initialize
- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithWebArray:(NSArray *)webArray placeHolder:(UIImage *)placeHolder{
    if (self = [super init]) {
        [self initialize];
        [self setWebArray:webArray placeHolder:placeHolder];
    }
    return self;
}
- (instancetype)initWithImageArray:(NSArray *)imageArray placeHolder:(UIImage *)placeHolder{
    if (self = [super init]) {
        [self initialize];
        [self setImageArray:imageArray placeHolder:placeHolder];
    }
    return self;
}
- (instancetype)initWithBundleArray:(NSArray *)bundleArray placeHolder:(UIImage *)placeHolder{
    if (self = [super init]) {
        [self initialize];
        [self setBundleArray:bundleArray placeHolder:placeHolder];
    }
    return self;
}
- (void)setWebArray:(NSArray *)webArray placeHolder:(UIImage *)placeHolder{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:webArray.count];
    for (NSString *webUrl in webArray) {
        HSSlideSlice *slide = [HSSlideSlice sliceWithAttachment:webUrl sliceType:HSSlideSliceWebType
                                                    placeHolder:placeHolder];
        [mutableArray addObject:slide];
    }
    self.attachArray = [NSArray arrayWithArray:mutableArray];
}
- (void)setImageArray:(NSArray *)imageArray placeHolder:(UIImage *)placeHolder{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:imageArray.count];
    for (UIImage *image in imageArray) {
        HSSlideSlice *slide = [HSSlideSlice sliceWithAttachment:image sliceType:HSSlideSliceImageType
                                                    placeHolder:placeHolder];
        [mutableArray addObject:slide];
    }
    self.attachArray = [NSArray arrayWithArray:mutableArray];
}
- (void)setBundleArray:(NSArray *)bundleArray placeHolder:(UIImage *)placeHolder{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:bundleArray.count];
    for (NSString *bundleUrl in bundleArray) {
        HSSlideSlice *slide = [HSSlideSlice sliceWithAttachment:bundleUrl sliceType:HSSlideSliceBundleType
                                                    placeHolder:placeHolder];
        [mutableArray addObject:slide];
    }
    self.attachArray = [NSArray arrayWithArray:mutableArray];
}
- (void)initialize {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:scrollView];
    self.scrollView = scrollView;

    self.imageViewArray = [NSMutableArray array];
}
- (void)layoutSubviews {
    self.scrollView.frame = self.bounds;
    [self layoutAllSlides];
}
- (void)layoutAllSlides {
    NSMutableArray *array = self.imageViewArray;
    CGSize size = self.scrollView.bounds.size;
    CGFloat weight = size.width, height = size.height, itWeight = 0.0f;
    for (int i = 0; i < array.count; ++ i, itWeight += weight) {
        UIImageView *imageView = [array objectAtIndex:i];
        imageView.frame = CGRectMake(itWeight, 0, weight, height);
    }
    weight = size.width * array.count;
    self.scrollView.contentSize = CGSizeMake(weight, size.height);
}

#pragma mark
#pragma mark 刷新
- (void)reloadAllSlides {
    NSInteger number = self.attachArray.count;
    NSMutableArray *array = self.imageViewArray;
    
    NSInteger imageNumber = number > 1 ? number + 1 : number;
    for (int i = (int)array.count - 1; i >= imageNumber; -- i) {
        UIImageView *imageView = [array objectAtIndex:i];
        [imageView removeFromSuperview];
        [array removeObject:imageView];
    }
    
    UIScrollView *scrollView = self.scrollView;
    for (int i = (int)array.count; i < imageNumber; ++ i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [scrollView addSubview:imageView];
        [array addObject:imageView];
    }
    
    NSArray *attachArray = self.attachArray;
    CGSize size = self.scrollView.bounds.size;
    CGFloat weight = size.width, height = size.height, itWeight = 0.0f;
    for (int i = 0, j = 0; i < imageNumber; ++ i, itWeight += weight, ++ j) {
        UIImageView *imageView = [array objectAtIndex:i];
        imageView.frame = CGRectMake(itWeight, 0, weight, height);
        
        if (j >= number) j = 0;
        HSSlideSlice *slide = [attachArray objectAtIndex:j];
        [self reloadImageView:imageView slide:slide];
    }
    weight = size.width * array.count;
    scrollView.contentSize = CGSizeMake(weight, size.height);
}
- (void)reloadImageView:(UIImageView *)imageView slide:(HSSlideSlice *)slide {
    switch (slide.sliceType) {
        case HSSlideSliceWebType: {
            if (slide.image) {
                imageView.image = slide.image;
            } else {
                NSURL *url = [NSURL URLWithString:slide.attachment];
                [imageView sd_setImageWithURL:url placeholderImage:slide.placeHolder
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    slide.image = image;
                }];
            }
        } break;
        case HSSlideSliceImageType: {
            imageView.image = slide.image;
        } break;
        case HSSlideSliceBundleType: {
            if (slide.image) {
                imageView.image = slide.image;
            } else {
                imageView.image = slide.placeHolder;
            }
        } break;
        default: { } break;
    }
}

#pragma mark
#pragma mark UIScorllViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { // any offset changes
    
}
// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {      // called when scroll view grinds to a halt
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView { // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
}

@end
