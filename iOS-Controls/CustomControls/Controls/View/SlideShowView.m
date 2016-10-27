//
//  HomeScrollCell.m
//  Yofoto
//
//  Created by Shaojun Han on 8/17/15.
//  Copyright (c) 2015 HadLinks. All rights reserved.
//

#import "SlideShowView.h"

@interface SlideShowView ()
<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>
@property (strong, nonatomic) NSTimer                       *slideTimer;                    // 定时器
@property (strong, nonatomic) UICollectionView              *collectionView;                // 轮播视图
@property (strong, nonatomic) UICollectionViewFlowLayout    *flowLayout;                    // 布局
@property (strong, nonatomic) UIPageControl                 *pageControl;                   // page control
@property (assign, nonatomic) NSInteger                     numberOfPages;                  // 页码数
@property (assign, nonatomic) NSInteger                     currentPage;                    // 当前页
@property (assign, nonatomic) BOOL                          shouldHiddenPageIndicator;      // 是否隐藏指示器
@property (assign, nonatomic) BOOL                          isPauseByInternal;              // 是否由内部暂停的计时器，默认为YES
@end

#define HSSlideShowImageViewTarget 1024

static NSString *SlideShowCellReuseIdentifier = @"SlideShowCellReuseIdentifier";

@implementation SlideShowView

// 视图销毁的时候，停止计时器
- (void)dealloc {
    [self.slideTimer invalidate];
}
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    // 滚动图
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0.0f; flowLayout.minimumLineSpacing = 0.0f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;    // 水平滚动
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsHorizontalScrollIndicator = NO; collectionView.showsVerticalScrollIndicator = NO;
    collectionView.pagingEnabled = YES; collectionView.bounces = YES;
    collectionView.dataSource = self; collectionView.delegate = self;
    // 注册CELL
    [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:SlideShowCellReuseIdentifier];
    // page 指示器
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.numberOfPages = 0;
    // 添加子视图
    [self addSubview:collectionView];
    [self addSubview:pageControl];
    // retain
    self.collectionView = collectionView;
    self.pageControl = pageControl;
    self.flowLayout = flowLayout;
    // 初始化参数
    self.numberOfPages = 0; self.currentPage = 0;
    self.autoSlideTimeInterval = 4.5f;      // 默认4.0秒
    self.isPauseByInternal = YES;           // 默认内部
    [self fireByInternal];                  // 启动
}
- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    self.flowLayout.itemSize = size;
    self.pageControl.frame = CGRectMake(0, size.height - 36, size.width, 36);
    self.collectionView.frame = CGRectMake(0, 0, size.width, size.height);
    // 处理偏移量
    NSInteger currentPage = self.currentPage;
    CGFloat weight = size.width;
    [self.collectionView setContentOffset:CGPointMake(currentPage * weight, 0)];
}
// 数据设置，加载
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfSlides = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfSlides)])
        numberOfSlides = [self.delegate numberOfSlides];
    // 不能小于0
    if (numberOfSlides < 0) numberOfSlides = 0;
    // 保存数据，
    self.pageControl.numberOfPages = numberOfSlides;
    self.numberOfPages = numberOfSlides;
    self.shouldHiddenPageIndicator = (numberOfSlides < 2);
    // 返回item数
    return numberOfSlides < 2 ? numberOfSlides : numberOfSlides + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SlideShowCellReuseIdentifier forIndexPath:indexPath];
    UIImageView *reuseImageView = (UIImageView *)[cell viewWithTag:HSSlideShowImageViewTarget];
    if (!reuseImageView) [self cellInitialize:cell];
    // 数据
    reuseImageView = (UIImageView *)[cell viewWithTag:HSSlideShowImageViewTarget];
    reuseImageView.contentMode = self.cotentDisplayMode;

    NSInteger index = indexPath.row >= self.numberOfPages ? 0 : indexPath.row;
    if ([self.delegate respondsToSelector:@selector(slideShowView:imageViewOfSlide:reuseImageView:)]) {
        UIImageView *imageView = [self.delegate slideShowView:self imageViewOfSlide:index reuseImageView:reuseImageView];
        imageView.contentMode = self.cotentDisplayMode;
        
        if (reuseImageView == imageView) return cell;
        
        [reuseImageView removeFromSuperview];
        [self cellInitialize:cell imageView:imageView];
    } else if ([self.delegate respondsToSelector:@selector(slideShowView:imageOfSlide:)]) {
        UIImage *image = [self.delegate slideShowView:self imageOfSlide:index];
        reuseImageView.image = image;
    }
    return cell;
}
// 选中时，通知代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(slideShowView:didSelectedSlide:)])
        [self.delegate slideShowView:self didSelectedSlide:indexPath.row];
}
- (void)cellInitialize:(UICollectionViewCell *)cell imageView:(UIImageView *)imageView {
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.tag = HSSlideShowImageViewTarget;
    imageView.userInteractionEnabled = YES;
    [cell.contentView addSubview:imageView];
    // 约束，使填充cell
    NSLayoutConstraint *widthLayout     = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *heightLayout    = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSLayoutConstraint *centerXLayout   = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerYLayout   = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [cell.contentView addConstraint:widthLayout];
    [cell.contentView addConstraint:heightLayout];
    [cell.contentView addConstraint:centerXLayout];
    [cell.contentView addConstraint:centerYLayout];
}
- (void)cellInitialize:(UICollectionViewCell *)cell {
    // cell中添加ImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self cellInitialize:cell imageView:imageView];
}
// 数据加载
- (void)reloadAllSlides {
    [self pauseByInternal];
    [self.collectionView reloadData];
    [self fireByInternal];
}

#pragma mark
#pragma mark UIScollViewDelegate
// 手势开始，停止计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseByInternal];
}
// 手势结束，此时滚动有可能还未结束：启动计时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self fireByInternal];
}
// 手势滚动停止时
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger numberOfPages = self.numberOfPages;
    if (numberOfPages < 2) return;
    
    CGFloat weight = scrollView.bounds.size.width;
    if (scrollView.contentOffset.x == (numberOfPages * weight)) { // 滑动到最后一页了
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}
// 滚动处理：手动自动都会调用此方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger numberOfPages = self.numberOfPages;
    if (numberOfPages < 2) return;
    // 处理page和滚动
    CGFloat weight = scrollView.bounds.size.width;
    CGFloat x = scrollView.contentOffset.x;
    // 处理滚动
    if (x < 0)  {  // 从第0页向左滚动
        [scrollView setContentOffset:CGPointMake(numberOfPages * weight, 0)];
    } else if (x > (numberOfPages * weight)) { // 滑动到最后一页了
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    // 处理page
    if (0 == weight)  return;            // 除数不能为0
    NSInteger page = (x + weight / 2 ) / weight;
    if (page == numberOfPages) page = 0;
    self.pageControl.currentPage = page;
    self.currentPage = page;
}
// 自动滚动临界处理
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.numberOfPages < 2) return;
    CGFloat weight = scrollView.bounds.size.width;
    if (0 == weight) return;    // 避免除0异常
    if (scrollView.contentOffset.x == (self.numberOfPages * weight)) {   // 是最后一页则跳转到第一页
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}
// 定时器的触发事件处理
- (void)timerHandle:(NSTimer *)timer {
    NSInteger numberOfPages = self.numberOfPages;
    NSInteger currentPage = self.currentPage;
    if (numberOfPages < 2) return;
    
    NSInteger toPage = (currentPage + 1) % numberOfPages;
    NSInteger toScrollPage = toPage == 0 ? numberOfPages : toPage; // 判断是不是最后一页
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toScrollPage inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    self.pageControl.currentPage = toPage;
    self.currentPage = toPage;
}

#pragma mark
#pragma mark 计时器
// 计时器控制，计时器的控制分外部和内部，外部有更高的优先级
- (void)fire {
    [self resetTimer];
    self.isPauseByInternal = YES;
}
// 暂停计时器
- (void)pause {
    [self.slideTimer invalidate];
    self.isPauseByInternal = NO;
}
// 停止计时器
- (void)stop {
    [self.slideTimer invalidate];
    self.isPauseByInternal = NO;
}
// 启动定时(内部)
- (void)fireByInternal {
    if (!self.isPauseByInternal) return; // 非内部进行了暂停或停止
    [self resetTimer];
}
// 暂停计时器（内部）
- (void)pauseByInternal {
    [self.slideTimer invalidate];
}
// 时间间隔设置
- (void)setAutoSlideTimeInterval:(CGFloat)autoSlideTimeInterval {
    if (_autoSlideTimeInterval == autoSlideTimeInterval) return;
    _autoSlideTimeInterval = autoSlideTimeInterval;
    if (!self.isPauseByInternal) return;
    [self resetTimer];
}
// 重置计时器
- (void)resetTimer {
    [self.slideTimer invalidate];
    NSTimeInterval interval = self.autoSlideTimeInterval;
    self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
}
/**
 * 显示相关
 */
// 显示模式设置
- (void)setContentDisplayMode:(UIViewContentMode)displayMode {
    if (_cotentDisplayMode == displayMode) return;
    _cotentDisplayMode = displayMode;
    [self reloadAllSlides];      // 会关闭计时器，在重新加载数据，之后重新启动计时器
}
- (void)setShouldHiddenPageIndicator:(BOOL)shouldHiddenPageIndicator {
    if (_shouldHiddenPageIndicator == shouldHiddenPageIndicator) return;
    _shouldHiddenPageIndicator = shouldHiddenPageIndicator;
    self.pageControl.hidden = _shouldHiddenPageIndicator;
}

@end
