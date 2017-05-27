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
    RZWKWeb *wkWeb = [[RZWKWeb alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) withNativeMethodArr:arr];
    [self.view addSubview:wkWeb];
    
    [wkWeb loadHTMLString:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
    wkWeb.delegate = self;
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
