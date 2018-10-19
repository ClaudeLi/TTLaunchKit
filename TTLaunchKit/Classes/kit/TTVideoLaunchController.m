//
//  TTVideoLaunchController.m
//  Tiaooo
//
//  Created by ClaudeLi on 2018/4/24.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTVideoLaunchController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <YYKit/YYKit.h>
#import <CLTools/CLTools.h>

@interface TTVideoLaunchController ()

@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation TTVideoLaunchController

- (void)setMoviePath:(NSString *)moviePath{
    _moviePath = moviePath;
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.shouldRasterize = YES;
        _playerLayer.rasterizationScale = [UIScreen mainScreen].scale;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
        if (IS_IPAD) {
            _playerLayer.top = (865*kScreenWidth/768.0-kScreenWidth)/2.0;
        }else if (ISIPhoneX){
            _playerLayer.top = KSafeTop+kScreenWidth/4.0;
        }else if (kScreenWidth/kScreenHeight > 0.6){
            _playerLayer.top = (kScreenHeight-75.0f-kScreenWidth)/2.0;
        }else{
            _playerLayer.top = kScreenWidth/4.0;
        }
        [self.view.layer addSublayer:_playerLayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinsihed) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _playerLayer;
}

- (void)playFinsihed{
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playFinished();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[self getLaunchImageName]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // AVPlayer
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:_moviePath]];
    _player.volume = 0;
    self.playerLayer.player = _player;
    [self performSelector:@selector(tryToSee) withObject:nil afterDelay:0.2f];
}

- (void)enterForegroundNotification{
    [_player play];
}

- (void)tryToSee{
    [_player play];
}

- (NSString *)getLaunchImageName{
    CGSize viewSize = CGSizeMake(kScreenWidth, kScreenHeight);
    // 竖屏
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{    // 不允许进行旋转
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{    // 返回默认情况
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{    // 返回默认情况
    return UIInterfaceOrientationPortrait;
}


@end
