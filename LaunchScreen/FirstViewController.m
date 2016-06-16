//
//  FirstViewController.m
//  LaunchScreen
//
//  Created by ClaudeLi on 16/6/16.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
        self.title = @"第一个";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatButton];
}

- (void)creatButton{
    UIButton* button = [UIButton new];
    button.frame = CGRectMake(100, 100, 100, 50);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"next" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)clickButtonAction{
    [self.navigationController pushViewController:[[BaseViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
