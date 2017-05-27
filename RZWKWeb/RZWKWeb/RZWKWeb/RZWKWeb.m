//
//  RZWKWeb.m
//  gold
//
//  Created by 利基 on 2017/5/26.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "RZWKWeb.h"


@interface RZWKWeb ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
/** wkwebview and progress */
@property (nonatomic, strong) WKWebView *WKWeb;
@property (nonatomic, strong) UIProgressView *progressView;
/** js调用native的方法名 数组 */
@property (nonatomic, strong) NSArray *nativeMethodArr;
@end

@implementation RZWKWeb

- (instancetype)initWithFrame:(CGRect)frame withNativeMethodArr:(NSArray *)arr {
    if (self = [super initWithFrame:frame]) {
        _nativeMethodArr = arr;
        [self settingWKWeb];
    }
    return self;
}

#pragma mark - 加载数据
- (void)loadRequestWithUrlString:(NSString *)urlstring {
    [_WKWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSURL URLWithString:urlstring] ? urlstring : [self strUTF8Encoding:urlstring]]]];
}
- (NSString *)strUTF8Encoding:(NSString *)str
{
    if (kSystemVersion >= 9.0) {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    } else {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

- (BOOL)back {
    if ([self.WKWeb canGoBack]) {
        [self.WKWeb goBack];
        return YES;
    }
    return NO;
}

- (BOOL)forward {
    if ([self.WKWeb canGoForward]) {
        [self.WKWeb goForward];
        return YES;
    }
    return NO;
}

#pragma mark - 处理JS调用nativeMethod
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate handleScriptMessage:message withWKWebView:self.WKWeb];
}

#pragma mark - 捕捉链接
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
    RZLog(@"%@", strRequest);
}

#pragma mark - 1、懒加载

- (WKWebView *)WKWeb {
    if (!_WKWeb) {
        /*
         // 简单使用
         _WKWeb = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreeWith, kScreeHeight-64)];
         [_WKWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://developer.apple.com/reference/webkit"]]];
         [self.view addSubview:_WKWeb];
         */
        
        // 创建配置
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建UserContentController（提供JavaScript向WKWeb发送消息的方法）
        WKUserContentController *userContent = [[WKUserContentController alloc] init];
        // 添加消息处理 注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        if (self.nativeMethodArr.count > 0) {
            for (NSString *string in _nativeMethodArr) {
                [userContent addScriptMessageHandler:self name:string];
            }
        }
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent;
        // 高端的自定义配置创建WKWebView
        _WKWeb = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreeWith, kScreeHeight-64) configuration:config];
        [self addSubview:_WKWeb];
        
        // 进度条
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(0, 0, kScreeWith, 2.f);
        self.progressView.tintColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0];
        [self addSubview:self.progressView];
    }
    return _WKWeb;
}

#pragma mark - 2、设置WKWebView

- (void)settingWKWeb {
    // 设置代理
    self.WKWeb.navigationDelegate = self;
    self.WKWeb.UIDelegate = self;
    
    // 允许视频播放
    self.WKWeb.configuration.allowsAirPlayForMediaPlayback = YES;
    // 允许在线播放
    self.WKWeb.configuration.allowsInlineMediaPlayback = YES;
    // 允许与网页交互，选择视图
    self.WKWeb.configuration.selectionGranularity = YES;
    
    // 使用KVO添加进度条
    [self.WKWeb addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // 使用KVO获取title
    [self.WKWeb addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    // 开启手势触摸
    self.WKWeb.allowsBackForwardNavigationGestures = YES;
    
    // 自适应
    [self.WKWeb sizeToFit];
}

#pragma mark - 3、KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"estimatedProgress"] && object == _WKWeb)
    {
        [self.progressView setAlpha:1.f];
        [self.progressView setProgress:_WKWeb.estimatedProgress animated:YES];
        if (_WKWeb.estimatedProgress >= 1.f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0 animated:NO];
            }];
        }
    }else if ([keyPath isEqual:@"title"] && object == _WKWeb) {
        [self.delegate setTitle:self.WKWeb.title];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 4、移除观察者

- (void)dealloc {
    [self.WKWeb removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.WKWeb removeObserver:self forKeyPath:@"title"];
    
    [self.WKWeb setNavigationDelegate:nil];
    [self.WKWeb setUIDelegate:nil];
}

@end
