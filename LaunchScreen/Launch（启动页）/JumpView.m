//
//  JumpView.m
//  tiaooo
//
//  Created by ClaudeLi on 16/4/6.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "JumpView.h"

@interface JumpView (){
    NSInteger _i;
    NSTimer *timer;
}
@property(nonatomic, strong) UILabel *timeLabel;
@end
@implementation JumpView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        UILabel *jumpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 38, frame.size.height)];
        jumpLabel.text = @"跳过";
        jumpLabel.textColor = [UIColor whiteColor];
        jumpLabel.font = [UIFont systemFontOfSize:14];
        jumpLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:jumpLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(jumpLabel.frame)+2, 0, 20, frame.size.height)];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)setIndex:(NSInteger)index{
    _i = index;
    self.timeLabel.text = [NSString stringWithFormat:@"%ld", (long)_i];
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerDiminishing) userInfo:nil repeats:YES];
    }
}

- (void)timerDiminishing{
    _i--;
    if (_i < 0) {
        [self tapAction];
        self.timeLabel.text = @"0";
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"%ld", (long)_i];
    }
}

- (void)tapAction{
    [self timerNil];
    if (self.clickViewBlock) {
        self.clickViewBlock();
    }
}

- (void)timerNil{
    [timer invalidate];
    timer = nil;
}

@end
