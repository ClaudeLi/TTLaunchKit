//
//  LaunchView.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/6/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "LaunchView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JumpView.h"
#import "LaunchManager.h"

@interface LaunchView ()<UIScrollViewDelegate>
{
    MPMoviePlayerController *_mp; // 视频控制器
}

@property (nonatomic, strong) UIPageControl *pageControl;

@end

static LaunchView *launch;
@implementation LaunchView

+ (LaunchView *)launchView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        launch = [[LaunchView alloc] init];
    });
    return launch;
}

- (instancetype)initWithType:(StartupScreenType)type{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        if (type == StartupScreenTypeVideo) {
            [self showLaunchVideo];
        }else{
            [self showLaunchImage];
        }
    }
    return self;
}


- (void)setStartupType:(StartupScreenType)type{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor blackColor];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        if (type == StartupScreenTypeVideo) {
            [self showLaunchVideo];
        }else if (type == StartupScreenTypeScrollView){
            [self showLaunchScrollView];
        }else{
            [self showLaunchImage];
        }
    }
}

- (void)showLaunchScrollView{
    NSArray *imageArr = @[[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"], [UIImage imageNamed:@"3.jpg"], [UIImage imageNamed:@"4.jpg"]];
    UIScrollView *launchScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    launchScroll.bounces = NO;
    launchScroll.showsHorizontalScrollIndicator = NO;
    launchScroll.showsVerticalScrollIndicator = NO;
    launchScroll.pagingEnabled = YES;
    launchScroll.delegate = self;
    launchScroll.contentSize = CGSizeMake(4*KScreenWidth, KScreenHeight);
    [self addSubview:launchScroll];
    for (int i = 0; i < imageArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth*i, 0, KScreenWidth, KScreenHeight)];
        imageView.image = imageArr[i];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [launchScroll addSubview:imageView];
        if (i == imageArr.count-1) {
            imageView.userInteractionEnabled = YES;
            UIButton *jumpBtn = [[UIButton alloc]initWithFrame:CGRectMake(KScreenWidth /2-50, KScreenHeight - 85, 100, 30)];
            jumpBtn.backgroundColor = [UIColor redColor];
            [jumpBtn setTitle:@"Next" forState:UIControlStateNormal];
            [jumpBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:jumpBtn];
        }
    }
    self.pageControl = [[UIPageControl alloc] init];
    _pageControl.frame = CGRectMake(0, KScreenHeight - 50, KScreenWidth, 20);
    self.pageControl.numberOfPages = imageArr.count;
    [self addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = (scrollView.contentOffset.x / KScreenWidth);
}


- (void)showLaunchVideo{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"launchVideo" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    _mp = [[MPMoviePlayerController alloc] initWithContentURL:url];
    _mp.view.frame = self.bounds;
    [self addSubview:_mp.view];
    //mp.repeatMode = MPMovieRepeatModeOne;
    [_mp play];
    _mp.controlStyle = MPMovieControlStyleNone;
    _mp.movieSourceType = MPMovieSourceTypeFile;
    [self jumpControl];
}

- (void)jumpControl{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(KScreenWidth / 2 - 65, KScreenHeight - 80, 130, 35);
    [button addTarget:self action:@selector(jumpClike) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [_mp.view addSubview:button];
    [self performSelector:@selector(jumpClike) withObject:@(0) afterDelay: 25.f];
}

- (void)jumpClike{
    [_mp pause];
    [UIView animateWithDuration:2.f animations:^{
        _mp.view.alpha = 0;
    }];
    [self performSelector:@selector(hide) withObject:@(0) afterDelay: .5f];
}

- (void)showLaunchImage{
    UIImageView *launchImageView= [[UIImageView alloc] initWithFrame:self.bounds];
    launchImageView.image = [UIImage imageWithContentsOfFile:LaunchImagePath];
    launchImageView.contentMode = UIViewContentModeScaleAspectFill;
    launchImageView.clipsToBounds = YES;
    launchImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [launchImageView addGestureRecognizer:tap];
    [self addSubview:launchImageView];
    
    JumpView *jumpView = [[JumpView alloc] initWithFrame:CGRectMake(KScreenWidth - 70, 10, 60, 27)];
    [jumpView setClickViewBlock:^{
        [self hide];
    }];
    jumpView.index = 3;
    [self addSubview:jumpView];
}

- (void)tapAction{

    if ([NSString isNilOrEmptyString:[LaunchDefaults objectForKey:Launch_Key]]) {
        [self hide];
        NSDictionary *userInfo = @{Launch_Key:[LaunchDefaults objectForKey:Launch_Key]};
        [[NSNotificationCenter defaultCenter] postNotificationName:LaunchGotoAdvert object:nil userInfo:userInfo];
    }else{
        NSLog(@"没有广告链接");
    }
}

- (void)show{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)hide{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
