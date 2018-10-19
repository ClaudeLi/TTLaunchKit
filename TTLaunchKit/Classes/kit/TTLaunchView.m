//
//  TTLaunchView.m
//  Tiaooo
//
//  Created by ClaudeLi on 2018/3/21.
//  Copyright © 2018年 ClaudeLi. All rights reserved.
//

#import "TTLaunchView.h"
#import "TTJumpButton.h"
#import "TTLaunchManager.h"
#import "TTLaunchAdItem.h"
#import <AVKit/AVKit.h>
#import <YYKit/YYKit.h>
#import <CLTools/CLTools.h>

NSString * const TTNotificationClickLaunchAds   = @"TTNotificationClickLaunchAds";
NSString * const TTNotificationHideLaunchAds    = @"TTNotificationHideLaunchAds";

static CGFloat launch_bottomHeight = 100.0f;
static CGFloat jump_Time = 4.0f;

@interface TTLaunchView ()

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIView        *playerView;
@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIImageView   *adImageView;
@property (nonatomic, strong) TTJumpButton  *jumpProgressBtn;

@property (nonatomic, assign) CGFloat       adHeight;
@property (nonatomic, assign) CGFloat       fixScale;

@property (nonatomic, strong) UIImage       *img;

@end

static TTLaunchView *manager;
@implementation TTLaunchView

+ (TTLaunchView *)defaultShared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTLaunchView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    });
    return manager;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.image = [UIImage imageNamed:[self getLaunchImageName]];
        self.hidden = YES;
        self.alpha = 0;
        if (IS_IPAD) {
            _adHeight = 865*kScreenWidth/768.0;
        }else if (ISIPhoneX){
            _adHeight = kScreenHeight-2*KSafeTop-launch_bottomHeight;
        }else if (kScreenWidth/kScreenHeight > 0.6){
            _adHeight = kScreenHeight-75.0f;
        }else{
            _adHeight = kScreenWidth/2.0*3;
        }
        self.contentView.hidden = NO;
        self.fixScale = self.contentView.width/_adHeight;
        self.adImageView.hidden = YES;
        self.playerView.hidden = YES;
    }
    return self;
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


- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, KSafeTop, self.width, _adHeight)];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.shouldRasterize = YES;
        _playerLayer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return _playerLayer;
}

- (UIView *)playerView{
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
        _playerView.backgroundColor = [UIColor whiteColor];
        _playerView.clipsToBounds = YES;
        _playerView.frame = CGRectMake(0, 0, kScreenWidth, _adHeight);
        @weakify(self);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weak_self clickAdImgAction:sender];
        }];
        [_playerView addGestureRecognizer:tap];
        [self.contentView addSubview:_playerView];
        [_playerView.layer addSublayer:self.playerLayer];
        _playerLayer.frame = _playerView.bounds;
    }
    return _playerView;
}

- (UIImageView *)adImageView{
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _adHeight)];
        _adImageView.backgroundColor = [UIColor whiteColor];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adImageView.clipsToBounds = YES;
        _adImageView.userInteractionEnabled = YES;
        @weakify(self);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weak_self clickAdImgAction:sender];
        }];
        [_adImageView addGestureRecognizer:tap];
        [self.contentView addSubview:_adImageView];
    }
    return _adImageView;
}

- (TTJumpButton *)jumpProgressBtn{
    if (!_jumpProgressBtn) {
        _jumpProgressBtn = [[TTJumpButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, ISIPhoneX?10:(KStateHeight+10), 60, 26)];
        [_jumpProgressBtn setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
        [_jumpProgressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _jumpProgressBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _jumpProgressBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _jumpProgressBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_jumpProgressBtn];
        @weakify(self);
        [_jumpProgressBtn setDidFinishedBlock:^{
            [weak_self hideWithAnimation:YES];
        }];
        UIButton *btn = [UIButton new];
        btn.frame = CGRectMake(kScreenWidth - 90, ISIPhoneX?0:KStateHeight, 80, 46);
        [btn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
    }
    return _jumpProgressBtn;
}

- (void)clickRightBtn{
    [self hideWithAnimation:YES];
}

- (void)setCloseTitle:(NSString *)closeTitle{
    _closeTitle = closeTitle;
    [_jumpProgressBtn setTitle:closeTitle forState:UIControlStateNormal];
}

- (void)setModel:(TTLaunchAdItem *)model{
    _model = model;
    if (_model.style_type == 1) {
        _playerView.hidden = YES;
        _playerLayer.hidden = YES;
        self.adImageView.hidden = NO;
        _img = [UIImage imageGIFWithData:[NSData dataWithContentsOfFile:[TTLaunchManager pathWithModel:model]]];
        self.adImageView.image = _img;
        CGFloat scale = _img.size.width/_img.size.height;
        if (scale < _fixScale) {
            self.adImageView.height = self.adImageView.width/scale;
        }
    }else if (_model.style_type == 2){
        _adImageView.hidden = YES;
        NSURL *videoURL = [NSURL fileURLWithPath:[TTLaunchManager pathWithModel:model]];
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
            _player = nil;
            return;
        }
        self.player = [AVPlayer playerWithURL:videoURL];
        self.playerLayer.player = _player;
        _player.volume = 0;
        self.playerView.hidden = NO;
        _playerLayer.hidden = NO;
        if (_playerView.layer != self.playerLayer.superlayer) {
            [_playerView.layer addSublayer:_playerLayer];
            _playerLayer.frame = _playerView.bounds;
        }
        AVAssetTrack *asetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGFloat scale = asetTrack.naturalSize.width/asetTrack.naturalSize.height;
        // 判断视频方向
        BOOL isVideoAssetPortrait_ = NO;
        CGAffineTransform videoTransform = asetTrack.preferredTransform;
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait_ = YES;
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait_ = YES;
        }
        if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        }
        if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        }
        if(isVideoAssetPortrait_){
            scale = asetTrack.naturalSize.height/asetTrack.naturalSize.width;
        }
        if (scale < _fixScale) {
            _playerLayer.height = _playerLayer.width/scale;
        }
        [_player play];
    }
}

- (void)showWithMode:(TTLaunchViewShowMode)mode{
    _showMode = mode;
    self.alpha = 1;
    self.hidden = NO;
    self.userInteractionEnabled = YES;
    self.showing = YES;
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    switch (_showMode) {
        case TTLaunchViewShowModeEnterForeground:
        {
            [self.jumpProgressBtn startAnimationDuration:jump_Time];
        }
            break;
        case TTLaunchViewShowModeLateralSpreads:
        {
            
        }
            break;
        case TTLaunchViewShowModeLaunchScreen:
        {
            [self.jumpProgressBtn startAnimationDuration:jump_Time];
        }
            break;
        default:
            break;
    }
}

- (void)clickAdImgAction:(UITapGestureRecognizer *)tap{
    if (_model.id) {
        self.userInteractionEnabled = NO;
        _jumpProgressBtn.isClick = YES;
        [self hideWithAnimation:NO];
        if (self.didClickAdsBlock) {
            self.didClickAdsBlock(_model);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TTNotificationClickLaunchAds object:_model userInfo:nil];
    }else{
        [self hideWithAnimation:NO];
    }
}

- (void)hideWithAnimation:(BOOL)animation{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weak_self.hidden == YES) {
            return;
        }
        [UIView animateWithDuration:0.25 animations:^{
            weak_self.alpha = 0;
        } completion:^(BOOL finished) {
            if (weak_self.player) {
                [weak_self.player pause];
            }
            weak_self.userInteractionEnabled = YES;
            weak_self.hidden = YES;
            if (weak_self.showMode == TTLaunchViewShowModeLaunchScreen) {
                if (weak_self.didHideViewBlock) {
                    weak_self.didHideViewBlock();
                }
                if (weak_self.showing) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TTNotificationHideLaunchAds object:nil userInfo:nil];
                }
            }
            weak_self.showing = NO;
        }];
    });
}

@end
