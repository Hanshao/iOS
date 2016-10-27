//
//  ViewController.m
//  Animator
//
//  Created by Shaojun Han on 7/18/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *animView;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] init];

    [animator addBehavior:[self createGravityBehaviorWithView:self.animView]];
    [animator addBehavior:[self createCollisionBehaviorWithView:self.animView bounds:bounds]];
    [animator addBehavior:[self createBounceBehaviorWithView:self.animView]];
//    [animator addBehavior:[self createAttachmentBehaviorWithView:self.animView]];
    self.animator = animator;
    
    UITapGestureRecognizer *viewTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewHandler:)];
    [self.view addGestureRecognizer:viewTapGesture];
}
- (void)tapViewHandler:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    [self.animator addBehavior:[self createPushBehaviorWithView:self.animView toPoint:location]];
}

- (UIDynamicItemBehavior *)createBounceBehaviorWithView:(UIView *)itemView {
    if (itemView == nil) return nil;
    // 弹性
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[itemView]];
    itemBehavior.elasticity = 0.8; // 改变弹性
    itemBehavior.allowsRotation = YES; // 允许旋转
    [itemBehavior addAngularVelocity:1 forItem:itemView]; // 让物体旋转
    return itemBehavior;
}
- (UICollisionBehavior *)createCollisionBehaviorWithView:(UIView *)itemView bounds:(CGRect)bounds {
    if (itemView == nil) return nil;
    // 碰撞
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[itemView]];
    // 指定 Reference view 的边界为可碰撞边界
    collision.translatesReferenceBoundsIntoBoundary = YES;
    // UICollisionBehaviorModeItems:item 只会和别的 item 发生碰撞；UICollisionBehaviorModeBoundaries：item 只和碰撞边界进行碰撞；UICollisionBehaviorModeEverything:item 和 item 之间会发生碰撞，也会和指定的边界发生碰撞。
    collision.collisionMode = UICollisionBehaviorModeBoundaries;
    CGFloat x = bounds.origin.x, y = bounds.origin.y;
    CGFloat xsize = bounds.size.width, ysize = bounds.size.height;
    [collision addBoundaryWithIdentifier:@"CollisionLeftBoundary" fromPoint:CGPointMake(x, y) toPoint:CGPointMake(x, y + ysize)];
    [collision addBoundaryWithIdentifier:@"CollisionBottomBoundary" fromPoint:CGPointMake(x, y + ysize) toPoint:CGPointMake(x + xsize, y + ysize)];
    [collision addBoundaryWithIdentifier:@"CollisionRightBoundary" fromPoint:CGPointMake(x + xsize, y + ysize) toPoint:CGPointMake(x + xsize, y)];
    [collision addBoundaryWithIdentifier:@"CollisionTopBoundary" fromPoint:CGPointMake(x + xsize, y) toPoint:CGPointMake(x, y)];
    return collision;
}
- (UIGravityBehavior *)createGravityBehaviorWithView:(UIView *)itemView {
    if (itemView == nil) return  nil;
    // 重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[itemView]]; // 创建一个重力行为
    gravity.gravityDirection = CGVectorMake(0, 1); // 在垂直向下方向 1000 点/平方秒 的速度
    return gravity;
}
- (UIAttachmentBehavior *)createAttachmentBehaviorWithView:(UIView *)itemView {
    if (itemView == nil) return nil;
    // 依附
    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:itemView attachedToAnchor:itemView.center];
    attachment.length = 50;
    attachment.damping = 0.5;
    attachment.frequency = 1;
    return attachment;
}
- (UIPushBehavior *)createPushBehaviorWithView:(UIView *)itemView toPoint:(CGPoint)point {
    if (itemView == nil) return nil;
    // 推力
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[itemView] mode:UIPushBehaviorModeInstantaneous];
    CGPoint itemCenter = itemView.center;
    push.pushDirection = CGVectorMake((point.x - itemCenter.x) / 100, (point.y - itemCenter.y) / 100);
    return push;
}
- (UISnapBehavior *)createSnapBehaviorWithView:(UIView *)itemView point:(CGPoint)point {
    if (itemView == nil) return nil;
    // 固定点
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:itemView snapToPoint:point];
    snap.damping = 0.5;
    return snap;
}

@end
