//
//  RZWebVC.m
//  RZWKWeb
//
//  Created by 利基 on 2017/5/27.
//  Copyright © 2017年 RZ. All rights reserved.
//

#import "RZWebVC.h"
#import "RZWKWeb.h"
#import "UIView+RZAlert.h"
#import "UIView+Toast.h"


#define kAdjustmentBehavior(VC, view) if (@available(iOS 11.0, *)) {                \
view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;  \
} else {                                                                            \
VC.automaticallyAdjustsScrollViewInsets = NO;                                   \
}


#define kRZ_iPhoneX (kScreeHeight == 812.f && kScreeWith == 375.f ? YES : NO)

#define kRZStatusBarHeight (kRZ_iPhoneX ? 44 : 20)
#define kRZBottomHeight (kRZ_iPhoneX ? 34 : 0)

#define kScreeWith [UIScreen mainScreen].bounds.size.width
#define kScreeHeight [UIScreen mainScreen].bounds.size.height

@interface RZWebVC ()<RZWKWebDelegate>

@end

@implementation RZWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self createleftBarButtonItem];
    [self createUI];
    [self loadData];
}

- (void)createleftBarButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[[UIImage imageNamed:@"fanhuiicon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 70, 30);
    // 按钮内部的所有内容 左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}
- (void)back {
    self.web.RZWK_canGoBack ? [self.web rzwk_goBack] : [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI {
    RZWKWeb *wkweb = [RZWKWeb rzwk_WebWithFrame:CGRectZero delegate:self];
    wkweb.frame = CGRectMake(0, 44, kScreeWith, kScreeHeight-kRZStatusBarHeight-44-kRZBottomHeight);
    [self.view addSubview:wkweb];
    [wkweb rzwk_addScriptMessageNameArray:@[@"Share",
                                            @"getLocation",
                                            @"Pay",
                                            @"ScanAction",
                                            @"Color"]];
    self.web = wkweb;
}

- (void)loadData {
    [self.web rzwk_loadHTMLFileName:@"index"];
}

- (void)handleProgress:(CGFloat)progress {
    NSLog(@"%f", progress);
}

- (void)handleTitle:(NSString *)title {
    NSLog(@"%@", title);
}

- (void)handleCurrentURL:(NSURL *)URL {
    NSLog(@"%@", URL);
}

- (void)handleScriptMessage:(WKScriptMessage *)message withWKWebView:(WKWebView *)webView {
    if ([message.name isEqualToString:@"ScanAction"]) {
        NSLog(@"扫一扫");
    }
    
    if ([message.name isEqualToString:@"Share"]) {
        NSLog(@"%@", message.body);
        [self.view makeLJToast:message.body[@"title"]];
    }
    
    if ([message.name isEqualToString:@"getLocation"]) {
        NSString *str = [NSString stringWithFormat:@"setLocation('%@')", @"1234"];
        [webView evaluateJavaScript:str completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            NSLog(@"%@", ret);
        }];
    }
}

@end
