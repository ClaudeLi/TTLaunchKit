//
//  JumpView.h
//  tiaooo
//
//  Created by ClaudeLi on 16/4/6.
//  Copyright © 2016年 dali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JumpView : UIView

// 提示时间
@property (nonatomic, assign) NSInteger index;

// 点击跳过Block
@property (nonatomic, copy) void(^clickViewBlock)();

@end
