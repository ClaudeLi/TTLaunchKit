//
//  CLTabBarController.m
//  LaunchScreen
//
//  Created by ClaudeLi on 16/6/16.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLTabBarController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface CLTabBarController (){
    NSArray *_controllers;
    NSArray *_titleArray;
}

@end

@implementation CLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _controllers = @[@"FirstViewController", @"SecondViewController", @"ThirdViewController"];
    _titleArray = @[@"首页", @"中间", @"我的"];
    
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
    NSDictionary *dicSel = @{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
    
    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i = 0; i < _controllers.count; i++) {
        Class class = NSClassFromString(_controllers[i]);
        BaseViewController *vc = [[class alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:_titleArray[i] image:nil selectedImage:nil];
        [item setTitleTextAttributes:dic forState:UIControlStateNormal];
        [item setTitleTextAttributes:dicSel forState:UIControlStateSelected];
        nav.tabBarItem = item;
        [viewArr addObject:nav];
    }
    self.viewControllers = viewArr;
    
    [self.tabBar setShadowImage:[UIImage new]];// 取消tabbar上的最顶部细线变成透明
    [self.tabBar setBackgroundImage:[UIImage new]];// tabber背景替换成一张透明图片
    self.tabBar.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoAdvert:) name:LaunchGotoAdvert object:nil];
}

- (void)gotoAdvert:(NSNotification *)noti{
    NSLog(@"跳转到H5,传地址：%@", [noti.userInfo objectForKey:Launch_Key]);
    [self.navigationController pushViewController:[[BaseViewController alloc] init] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
