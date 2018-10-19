//
//  TTJumpButton.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/10/10.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTJumpButton : UIButton

//set track color
@property (nonatomic,strong)UIColor    *trackColor;

//set progress color
@property (nonatomic,strong)UIColor    *progressColor;

//set track background color
@property (nonatomic,strong)UIColor    *fillColor;

//set progress line width , default: 2.0f
@property (nonatomic,assign)CGFloat    lineWidth;

//set progress duration
@property (nonatomic,assign)CGFloat    animationDuration;

@property (nonatomic, copy) void(^didFinishedBlock)(void);

@property (nonatomic, assign) BOOL isClick;

/**
 *  start Animation
 *
 *  @param duration  time
 */
- (void)startAnimationDuration:(CGFloat)duration;

@end
