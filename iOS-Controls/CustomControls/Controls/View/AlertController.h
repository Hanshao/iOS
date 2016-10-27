//
//  AlertViewController.h
//  BonecoAir
//
//  Created by Shaojun Han on 3/30/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AlertActionType) {
    AlertActionUnkownType = 0,
    AlertActionCloseType = 1,
    AlertActionOkayType = 2,
    AlertActionCancelType = 3
};

typedef void (^AlertActionHandler)(AlertActionType actionType);

@protocol AlertDelegate <NSObject>
@optional
- (void)alertController:(id)controller okayToggle:(id)sender;
- (void)alertController:(id)controller cancelToggle:(id)sender;

@end

@interface AlertController : NSObject
// 附加信息
@property (assign, nonatomic, readonly) NSUInteger accessory;
/**
 * 便利弹框方法
 * 参数 title 大标题
 * 参数 message  内容
 * 参数 okayButtonTitle 蓝色按钮标题
 * 参数 cancelButtonTitle 灰色按钮标题
 * 参数 accessory 辅助信息
 * 参数 handler 回调block
 */
+ (void)alertByTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle handler:(AlertActionHandler)handler;
+ (void)alertByTitle:(NSString *)title message:(id)message okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory handler:(AlertActionHandler)handler;
/**
 * 便利弹框方法
 * 参数 title 大标题
 * 参数 message  内容
 * 参数 delegate 回调代理
 * 参数 okayButtonTitle 蓝色按钮标题
 * 参数 cancelButtonTitle 灰色按钮标题
 * 参数 accessory 辅助信息
 */
+ (void)alertByTitle:(NSString *)title message:(id)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (void)alertByTitle:(NSString *)title message:(id)message delegate:(id)delegate okayButtonTitle:(NSString *)okayButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle accessory:(NSUInteger)accessory;

@end
