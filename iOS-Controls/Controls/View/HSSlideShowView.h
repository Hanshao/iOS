//
//  HSSlideShowView.h
//  Controls
//
//  Created by Shaojun Han on 3/23/16.
//  Copyright © 2016 oubuy·luo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSSlideShowView : UIView

- (instancetype)initWithWebArray:(NSArray *)webArray placeHolder:(UIImage *)placeHolder;
- (instancetype)initWithImageArray:(NSArray *)imageArray placeHolder:(UIImage *)placeHolder;
- (instancetype)initWithBundleArray:(NSArray *)bundleArray placeHolder:(UIImage *)placeHolder;

- (void)setWebArray:(NSArray *)webArray placeHolder:(UIImage *)placeHolder;
- (void)setImageArray:(NSArray *)imageArray placeHolder:(UIImage *)placeHolder;
- (void)setBundleArray:(NSArray *)bundleArray placeHolder:(UIImage *)placeHolder;

- (void)reloadAllSlides;

@end
