//
//  ViewController.m
//  RZWKWeb
//
//  Created by 利基 on 2017/5/27.
//  Copyright © 2017年 RZ. All rights reserved.
//

#import "ViewController.h"

#import "RZWebVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (IBAction)pushToWKWebVC:(id)sender {
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:[RZWebVC new]];
    [self presentViewController:navigationVC animated:YES completion:nil];
}

@end
