//
//  TTJumpButton.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/10/10.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTJumpButton.h"

#define degreesToRadians(x) ((x) * M_PI / 180.0)

UIColor *defaultTrackColor(void){
    return [UIColor colorWithRed:86/255.0 green:248/255.0 blue:0 alpha:1];
}

@interface TTJumpButton ()<CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIBezierPath *bezierPath;

@end

@implementation TTJumpButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.trackLayer];
        [self addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setLineWidth:(CGFloat)lineWidth{
    _lineWidth = lineWidth;
}

- (UIBezierPath *)bezierPath
{
    if (!_bezierPath) {
//        CGFloat width = CGRectGetWidth(self.frame)/2.0f;
//        CGFloat height = CGRectGetHeight(self.frame)/2.0f;
//        CGPoint centerPoint = CGPointMake(width, height);
        float radius = CGRectGetWidth(self.frame)/2.0;
        
        _bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
        //        _bezierPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
        //                                                     radius:radius
        //                                                 startAngle:degreesToRadians(-90)
        //                                                   endAngle:degreesToRadians(270)
        //                                                  clockwise:YES];
    }
    return _bezierPath;
}

- (CAShapeLayer *)trackLayer
{
    if (!_trackLayer) {
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = self.bounds;
        _trackLayer.fillColor = self.fillColor.CGColor ? self.fillColor.CGColor : [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor ;
        _trackLayer.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
        _trackLayer.strokeColor = self.trackColor.CGColor ? self.trackColor.CGColor : defaultTrackColor().CGColor ;
        _trackLayer.strokeStart = 0.f;
        _trackLayer.strokeEnd = 1.f;
        _trackLayer.path = self.bezierPath.CGPath;
    }
    return _trackLayer;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = self.lineWidth ? self.lineWidth : 2.f;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeColor = self.progressColor.CGColor ? self.progressColor.CGColor  : [UIColor lightGrayColor].CGColor;
        _progressLayer.strokeStart = 0.f;
        if (self.animationDuration <= 0) {
            _progressLayer.strokeEnd = 1.f;
        }else{
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = self.animationDuration;
            pathAnimation.fromValue = @(0.0);
            pathAnimation.toValue = @(1.0);
            pathAnimation.removedOnCompletion = YES;
            pathAnimation.delegate = self;
            [_progressLayer addAnimation:pathAnimation forKey:nil];
        }
        _progressLayer.path = _bezierPath.CGPath;
    }
    return _progressLayer;
}

#pragma mark -- CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationDuration <= 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(clickAction) withObject:nil afterDelay:0.2];
    });
}

#pragma mark ---
- (void)startAnimationDuration:(CGFloat)duration{
    if (_progressLayer) {
        [_progressLayer removeAllAnimations];
        [_progressLayer removeFromSuperlayer];
        _progressLayer = nil;
    }
    _isClick = NO;
    self.animationDuration = duration;
    if (duration > 0) {
        [self performSelector:@selector(startLayerAnimation) withObject:nil afterDelay:0.1];
    }else{
        [self.layer addSublayer:self.progressLayer];
    }
}

- (void)startLayerAnimation{
    [self.layer addSublayer:self.progressLayer];
}

- (void)clickAction{
    if (_isClick) {
        return;
    }
    _isClick = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clickAction) object:nil];
    if (self.didFinishedBlock) {
        self.didFinishedBlock();
    }
}

@end
