//
//  RZWebVC.m
//  RZWKWeb
//
//  Created by 利基 on 2017/5/27.
//  Copyright © 2017年 RZ. All rights reserved.
//

#import "RZWebVC.h"
#import "RZWKWeb.h"

@interface RZWebVC ()<RZWKWebDelegate>

@end

@implementation RZWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *arr = @[@"Share",
                     @"getLocation",
                     @"Pay",
                     @"ScanAction",
                     @"Color"];
    
    RZWKWeb *wkWeb = [RZWKWeb rzwk_WebWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) delegate:self];
    [self.view addSubview:wkWeb];
    wkWeb.showProgress = YES;
    [wkWeb rzwk_addScriptMessageNameArray:arr];
//    [wkWeb rzwk_loadHTMLFileName:@"index"];
    [wkWeb rzwk_loadURLString:@"https://www.baidu.com"];
    
//    [wkWeb loadDataWithHTMLString:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
//    [wkWeb loadDataWithUrl:@"http://192.168.1.5:8089/m/debt/6478/member/debtDetail.jhtml?appMark=1&flag=0&token=JeAS3wgODhsV6qreWi7byeB131kiR5m8fhzWz9WUN1g="];
//    wkWeb.delegate = self;
}

- (void)handleProgress:(CGFloat)progress {
    NSLog(@"%f", progress);
}

- (void)handleScriptMessage:(WKScriptMessage *)message withWKWebView:(WKWebView *)webView {
    if ([message.name isEqualToString:@"ScanAction"]) {
        NSLog(@"扫一扫");
    }
    
    if ([message.name isEqualToString:@"Share"]) {
        NSLog(@"%@", message.body);
    }
    
    if ([message.name isEqualToString:@"getLocation"]) {
        NSString *str = [NSString stringWithFormat:@"setLocation('%@')", @"1234"];
        [webView evaluateJavaScript:str completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            NSLog(@"%@", ret);
        }];
    }
}

@end
