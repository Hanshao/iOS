//
//  HSPickerView.m
//  YiMaoAgent
//
//  Created by Shaojun Han on 1/26/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import "HSPickerView.h"

/**
 * 视图类
 */
@interface HSPickerScrollView : UICollectionView

@end

@implementation HSPickerScrollView

@end


/**
 * 布局类
 */
@interface HSPickerScrollLayout : UICollectionViewFlowLayout

@end

static CGFloat ACTIVE_DISTANCE = 200.0;

@implementation HSPickerScrollLayout

// attributes for rectangle
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    
    CGRect rectOfVisible = CGRectZero;
    rectOfVisible.origin = self.collectionView.contentOffset;
    rectOfVisible.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attribute in array) {
        UICollectionViewLayoutAttributes *copyOfAttribute = [attribute copy];
        [result addObject:copyOfAttribute];
        if (!CGRectIntersectsRect(copyOfAttribute.frame, rect)) continue;
        
        // 距离显示中心的距离
        CGFloat distance = CGRectGetMidY(rectOfVisible) - copyOfAttribute.center.y;
        if (ABS(distance) > ACTIVE_DISTANCE) continue;
        
        // 归一化的距离
        CGFloat scale = (ACTIVE_DISTANCE - ABS(distance)) / ACTIVE_DISTANCE;
        
        // 设置属性
        copyOfAttribute.transform = CGAffineTransformMakeScale(scale, scale);
        copyOfAttribute.zIndex = 1;
    }
    
    return result;
}
// target point
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)propose {
    CGSize size = self.collectionView.bounds.size;
    // proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGRect targetRectangle = CGRectMake(0.0, propose.y, size.width, size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRectangle];
    
    CGFloat offsetAdjustment = MAXFLOAT;
    // 理论上应cell停下来的中心点
    CGFloat ycenter = propose.y + size.height/2.0;
    
    // 对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat icenter = layoutAttributes.center.y;
        NSLog(@"icenter = %.2f, height = %.2f", icenter, layoutAttributes.size.height);
        if (ABS(icenter - ycenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = icenter - ycenter;
        }
    }
    NSLog(@"height = %.2f, ycenter = %.2f, propose.y = %.2f, offset = %.2f", size.height, ycenter, propose.y, offsetAdjustment);
    NSLog(@"target contentOffset = %@", NSStringFromCGPoint(CGPointMake(propose.x,  MAX(0, propose.y + offsetAdjustment))));
    return CGPointMake(propose.x, MAX(0, propose.y + offsetAdjustment));
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)propose withScrollingVelocity:(CGPoint)velocity {
    NSLog(@"%s", __FUNCTION__);
    return [self targetContentOffsetForProposedContentOffset:propose];
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end


/**
 * 最终的视图类
 */
@class  HSPickerScrollView, HSPickerScrollLayout;
@interface HSPickerView ()
<
    UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>
@property (strong, nonatomic) NSMutableArray *pickerArray;
@property (strong, nonatomic) NSMutableArray *layerArray;
@property (strong, nonatomic) NSMutableArray *rowArray;

@property (strong, nonatomic) UIColor *circleColor;   // 默认圆环颜色
@property (strong, nonatomic) UIColor *itemColor;   // 默认每列背景色
@property (assign, nonatomic) CGFloat rowHeight;    // 默认行高

@end

// 重用ID，和UICollectionViewCell上的子视图label的tag值
static NSString *CellReuseIdentifier = @"ReuseID";
static NSInteger CellSubViewIndicator = 1200;

@implementation HSPickerView

/**
 * 刷新视图
 */
- (void)reloadAllComponents {
    [self recreateAllComponents];
    for (HSPickerScrollView *scrollView in self.pickerArray) {
        [scrollView reloadData];
    }
}
- (void)reloadComponent:(NSInteger)component {
    if (component >= 0 && component < self.pickerArray.count) {
        HSPickerScrollView *scrollView = [self.pickerArray objectAtIndex:component];
        [scrollView reloadData];
    }
}

// 行数
- (NSInteger)numberOfRowsOfComponent:(NSInteger)component {
    if (!(component >= 0 && component < self.pickerArray.count)) return 0;
    HSPickerScrollView *scrollView = [self.pickerArray objectAtIndex:component];
    return [scrollView numberOfItemsInSection:0];
}
- (CGSize)rowSizeOfComponent:(NSInteger)component {
    if (!(component >= 0 && component < self.pickerArray.count)) return CGSizeZero;
    HSPickerScrollView *scrollView = [self.pickerArray objectAtIndex:component];
    return [(HSPickerScrollLayout *)(scrollView.collectionViewLayout) itemSize];
}
// 滚动到选中
- (void)selectRow:(NSInteger)row ofComponent:(NSInteger)component animated:(BOOL)animated {
    if (!(component >= 0 && component < self.pickerArray.count)) return;
    if (row < 0 || row >= [self numberOfRowsOfComponent:component]) return;
    
    if (nil == self || self.hidden || nil == self.superview) animated = NO;
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) animated = NO;
    
    [self.rowArray replaceObjectAtIndex:component withObject:@(row)];
    HSPickerScrollView *scrollView = [self.pickerArray objectAtIndex:component];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [scrollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    HSPickerScrollLayout *layout = (HSPickerScrollLayout *)scrollView.collectionViewLayout;
    [layout invalidateLayout];
}
// 当前选中
- (NSInteger)selectedRowOfComponent:(NSInteger)component {
    if (!(component >= 0 && component < self.pickerArray.count)) return -1;
    return [[self.rowArray objectAtIndex:component] integerValue];
}

/**
 * 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return self;
    [self initialize];
    return self;
}
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}
- (void)initialize {
    self.rowArray = [NSMutableArray array];
    self.layerArray = [NSMutableArray array];
    self.pickerArray = [NSMutableArray array];
    // 初始颜色值
    self.circleColor = [UIColor colorWithRed:29/255.0 green:174/255.0 blue:236/255.0 alpha:1.0];
    self.normalTitleColor = [UIColor blackColor];
    self.itemColor = [UIColor whiteColor];
    self.rowHeight = 44.0f;
}

- (void)recreateAllComponents {
    NSInteger numberOfComponents = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfComponentsOfPickerView:)])
         numberOfComponents = [self.delegate numberOfComponentsOfPickerView:self];
    
    for (int i = (int)self.pickerArray.count - 1; i >= numberOfComponents; -- i) {
        HSPickerScrollView *collectionView = [self.pickerArray objectAtIndex:i];
        [collectionView removeFromSuperview];

        CAShapeLayer *layer = [self.layerArray objectAtIndex:i];
        [layer removeFromSuperlayer];
        
        [self.pickerArray removeObjectAtIndex:i];
        [self.layerArray removeObjectAtIndex:i];
        [self.rowArray removeObjectAtIndex:i];
    }
    
    if (numberOfComponents < 1) return;
    
    CGSize size = self.bounds.size;
    CGFloat unit = size.width / numberOfComponents, total = 0;
    for (int i = (int)self.pickerArray.count; i < numberOfComponents; ++ i, total += unit) {
        HSPickerScrollLayout *layout = [[HSPickerScrollLayout alloc] init]; layout.minimumLineSpacing = 20.0;
        HSPickerScrollView *pickerScrollView = [[HSPickerScrollView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        pickerScrollView.showsHorizontalScrollIndicator = NO;
        pickerScrollView.showsVerticalScrollIndicator = NO;
        if ([self.delegate respondsToSelector:@selector(pickerView:backgroundColorOfComponent:)]) {
            pickerScrollView.backgroundColor = [self.delegate pickerView:self backgroundColorOfComponent:i];
        } else {
            pickerScrollView.backgroundColor = self.itemColor;
        }
        
        [pickerScrollView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:CellReuseIdentifier];
        pickerScrollView.dataSource = self;
        pickerScrollView.delegate = self;
        
        [self addSubview:pickerScrollView];
        [self.pickerArray addObject:pickerScrollView];
        [self.rowArray addObject:@(0)];
        
        // 添加layer层
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.masksToBounds = YES; layer.borderWidth = 1.2;
        if ([self.delegate respondsToSelector:@selector(pickerView:colorOfComponent:)]) {
            layer.borderColor = [self.delegate pickerView:self colorOfComponent:i].CGColor;
        } else {    // 默认颜色
            layer.borderColor = self.circleColor.CGColor;
        }
        
        [self.layer addSublayer:layer];
        [self.layerArray addObject:layer];
    }
}

/**
 * 布局
 */
- (void)layoutSubviews {
    NSInteger numberOfComponents = self.pickerArray.count;
    if (numberOfComponents < 1) return;
    
    CGSize size = self.bounds.size;
    NSLog(@"layout height = %.2f", size.height);
    CGFloat unit = size.width / numberOfComponents, total = 0;
    for (int i = 0; i < numberOfComponents; ++ i, total += unit) {
        
        HSPickerScrollView *pickerScrollView = [self.pickerArray objectAtIndex:i];
        pickerScrollView.frame = CGRectMake(total, 0, unit, size.height);
        
        // contentInset
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        HSPickerScrollLayout *layout = (HSPickerScrollLayout *)pickerScrollView.collectionViewLayout;
        
        CGFloat itemHeight = [self collectionView:pickerScrollView layout:layout sizeForItemAtIndexPath:indexPath].height;
        CGFloat distance = (size.height - itemHeight) / 2.0;
        layout.sectionInset = UIEdgeInsetsMake(0.25 + distance, 0.0, 0.25 + distance, 0.0);
        
        NSLog(@"layout item height = %.2f", itemHeight);
        NSLog(@"layout distance = %.2f", distance);
        
        // circle layer
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CAShapeLayer *layer = [self.layerArray objectAtIndex:i];
        CGFloat height = unit - 16 > size.height/2.0 ? size.height/2.0 : unit - 16;
        layer.frame = CGRectMake(total + (unit - height)/2, (size.height - height)/2, height, height);
        layer.cornerRadius = height / 2.0;
        [CATransaction commit];
     }
    
    for (int i = 0; i < self.pickerArray.count; ++ i) {
        HSPickerScrollView *scrollView = [self.pickerArray objectAtIndex:i];
        [scrollView reloadData];
    }
    
    for (int i = 0; i < self.rowArray.count; ++ i) {
        NSInteger row = [[self.rowArray objectAtIndex:i] integerValue];
        [self selectRow:row ofComponent:i animated:YES];
    }
}

/**
 * collection view 代理
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger number = 0;
    NSInteger component = [self.pickerArray indexOfObject:collectionView];
    if (component < 0 || component >= self.pickerArray.count) return number;
    
    if([self.delegate respondsToSelector:@selector(pickerView:numberOfRowsOfComponent:)]) {
        number = [self.delegate pickerView:self numberOfRowsOfComponent:component];
    }
    
    if (number > 0 && number <= [[self.rowArray objectAtIndex:component] integerValue]) {
        [self.rowArray replaceObjectAtIndex:component withObject:@(number - 1)];
        [self selectRow:(number - 1) ofComponent:component animated:NO];
    }
    return number;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    NSInteger component = [self.pickerArray indexOfObject:collectionView], row = indexPath.row;
    if (component < 0 || component >= self.pickerArray.count) return cell;
    
    if(![cell viewWithTag:CellSubViewIndicator]) {
        UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
        label.textAlignment = NSTextAlignmentCenter; label.font = [UIFont systemFontOfSize:24.0];
        [cell.contentView addSubview:label]; label.tag = CellSubViewIndicator;
    }
    // 测试
    cell.backgroundColor = [UIColor orangeColor];
    
    UILabel *label = [cell viewWithTag:CellSubViewIndicator];
    label.text = nil; [label setFrame:cell.bounds];
    if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleOfRow:ofComponent:)]) {
        [label setAttributedText:[self.delegate pickerView:self attributedTitleOfRow:row ofComponent:component]];
    } else if ([self.delegate respondsToSelector:@selector(pickerView:titleOfRow:ofComponent:)]) {
        label.text = [self.delegate pickerView:self titleOfRow:row ofComponent:component];
    }
    // 是否选中
    NSInteger index = [[self.rowArray objectAtIndex:component] integerValue];
    if (!(row == index)) {
        label.textColor = self.normalTitleColor;
    } else if ([self.delegate respondsToSelector:@selector(pickerView:colorOfComponent:)]) {
        label.textColor = [self.delegate pickerView:self colorOfComponent:component];
    } else {
        label.textColor = self.circleColor;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = self.rowHeight;
    CGFloat weight = collectionView.bounds.size.width;
    NSInteger component = [self.pickerArray indexOfObject:collectionView];
    
    if (component < 0 || component >= self.pickerArray.count)
        return CGSizeMake(weight, rowHeight);
    
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightOfComponent:)]) {
        rowHeight = [self.delegate pickerView:self rowHeightOfComponent:component];
    }
    return CGSizeMake(collectionView.bounds.size.width , rowHeight);
}

/**
 * scroll view 代理
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger component = [self.pickerArray indexOfObject:collectionView];
    if (component < 0 || component >= self.pickerArray.count) return;
    
    CGSize size = collectionView.bounds.size;
    CGPoint offset = collectionView.contentOffset;
    CGPoint center = CGPointMake(size.width/2.0, offset.y + size.height/2);
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:center];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSInteger row = [[self.rowArray objectAtIndex:component] integerValue];
    [self clearWithColloectionView:collectionView row:row component:component];
    [self.rowArray replaceObjectAtIndex:component withObject:@(indexPath.row)];
    
    if ([cell viewWithTag:CellSubViewIndicator]) {
        UILabel *label = [cell viewWithTag:CellSubViewIndicator];
        if ([self.delegate respondsToSelector:@selector(pickerView:colorOfComponent:)]) {
            label.textColor = [self.delegate pickerView:self colorOfComponent:component];
        } else {
            label.textColor = self.circleColor;
        }
    }
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:ofComponent:)]) {
        [self.delegate pickerView:self didSelectRow:indexPath.row ofComponent:component];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}
- (void)clearWithColloectionView:(UICollectionView *)collectionView row:(NSInteger)row component:(NSInteger)component {
    if (!(0 <= component && component < self.pickerArray.count)) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell viewWithTag:CellSubViewIndicator]) {
        UILabel *label = [cell viewWithTag:CellSubViewIndicator];
        label.textColor = self.normalTitleColor;
    }
}
@end