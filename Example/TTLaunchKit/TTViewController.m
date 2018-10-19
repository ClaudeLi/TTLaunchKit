//
//  TTViewController.m
//  TTLaunchKit
//
//  Created by claudeli@yeah.net on 10/18/2018.
//  Copyright (c) 2018 claudeli@yeah.net. All rights reserved.
//

#import "TTViewController.h"
#import <TTLaunchKit/TTLaunchKit.h>

@interface TTViewController (){
    UILabel *_label;
}

@end

@implementation TTViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _label = [UILabel new];
    _label.frame = CGRectMake(0, 0, 100, 50);
    _label.center = self.view.center;
    _label.text = @"这是主页";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor redColor];
    [self.view addSubview:_label];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickAds:) name:TTNotificationClickLaunchAds object:nil];
}

- (void)clickAds:(NSNotification *)notification{
    NSLog(@"点击广告 -> %@", notification.object);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTNotificationClickLaunchAds object:nil];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _label.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
