//
//  RZWKWeb.m
//  gold
//
//  Created by 利基 on 2017/5/26.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "RZWKWeb.h"
#import "MBProgressHUD.h"

// 系统版本号
#define kRZWKSystemVersion [[UIDevice currentDevice].systemVersion floatValue]
#define kRZWKScreeWith [UIScreen mainScreen].bounds.size.width
#define kRZWKScreeHeight [UIScreen mainScreen].bounds.size.height


@interface RZWKWeb ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, NSURLConnectionDelegate>
{
    NSURLConnection *theConnection;
}

/** wkwebview and progress */
@property (nonatomic, strong) WKWebView *WKWeb;
@property (nonatomic, strong) UIProgressView *progressView;

/** js调用native的方法名 数组 */
@property (nonatomic, strong) NSArray *nativeMethodArr;
@end

@implementation RZWKWeb

- (instancetype)init {
    if (self = [super init]) {
        [self setupMainView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
    }
    return self;
}

+ (instancetype)rzwk_WebWithFrame:(CGRect)frame delegate:(id<RZWKWebDelegate>)delegate {
    RZWKWeb *rzwk_WebView = [[self alloc] initWithFrame:frame];
    rzwk_WebView.delegate = delegate;
    rzwk_WebView.showProgress = YES;
    
    return rzwk_WebView;
}

- (void)setupMainView {
    // 创建配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 允许与网页交互，选择视图
    config.selectionGranularity = YES;
    // 创建UserContentController（提供JavaScript向WKWeb发送消息的方法）
    WKUserContentController *userContent = [[WKUserContentController alloc] init];
    // 将UserConttentController设置到配置文件
    config.userContentController = userContent;
    // 高端的自定义配置创建WKWebView
    WKWebView *wkweb = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    [self addSubview:wkweb];
    // 设置代理
    wkweb.navigationDelegate = self;
    wkweb.UIDelegate = self;
    // 开启手势触摸
    wkweb.allowsBackForwardNavigationGestures = NO;
    // 自适应
    [wkweb sizeToFit];
    // 给self.WKWeb 赋值
    self.WKWeb = wkweb;
    // 添加KVO
    [self addObserverAction];
}


#pragma mark - KVO监听progress、title、URL的变化

- (void)addObserverAction {
    [self.WKWeb addObserver:self
                 forKeyPath:@"estimatedProgress"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
    [self.WKWeb addObserver:self
                 forKeyPath:@"title"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
    [self.WKWeb addObserver:self
                 forKeyPath:@"URL"
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.WKWeb) {
        [self estimatedProgressChange];
    }else if ([keyPath isEqual:@"title"] && object == self.WKWeb) {
        [self titleChange];
    }else if ([keyPath isEqual:@"URL"] && object == self.WKWeb) {
        [self URLChange];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)estimatedProgressChange {
    if ([self.delegate respondsToSelector:@selector(handleProgress:)]) {
        [self.delegate handleProgress:self.WKWeb.estimatedProgress];
    }
    
    if (self.showProgress) {
        [self.progressView setAlpha:1.f];
        [self.progressView setProgress:self.WKWeb.estimatedProgress animated:YES];
        if (self.WKWeb.estimatedProgress >= 1.f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0 animated:NO];
            }];
        }
    }
}

- (void)titleChange {
    if ([self.delegate respondsToSelector:@selector(handleTitle:)]) {
        [self.delegate handleTitle:self.WKWeb.title];
    }
}

- (void)URLChange {
    if ([self.delegate respondsToSelector:@selector(handleCurrentURL:)]) {
        [self.delegate handleCurrentURL:self.WKWeb.URL];
    }
}

#pragma mark - Public Method

- (void)rzwk_loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:[self strUTF8Encoding:URLString]];
    [self rzwk_loadURL:URL];
}
- (void)rzwk_loadURL:(NSURL *)URL {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self rzwk_loadRequest:request];
}
- (void)rzwk_loadRequest:(NSURLRequest *)request {
    [self.WKWeb loadRequest:request];
    if (theConnection) {
        [theConnection cancel];
    }
    theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


/**
 加载本地网页
 */
- (void)rzwk_loadHTMLFileName:(NSString *)htmlName {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.html", htmlName] ofType:nil];
    
    if (htmlPath)
    {
        if (kRZWKSystemVersion >= 9.0)
        {
            NSURL *fileURL = [NSURL fileURLWithPath:htmlPath];
            [self.WKWeb loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        } else {
            NSURL *fileURL = [self ba_fileURLForBuggyWKWebView8:[NSURL fileURLWithPath:htmlPath]];
            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
            [self rzwk_loadRequest:request];
        }
    }
}

/**
 加载本地 htmlString
 */
- (void)rzwk_loadHTMLString:(NSString *)htmlString {
    /*! 一定要记得这一步，要不然本地的图片加载不出来 */
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    
    [self.WKWeb loadHTMLString:htmlString baseURL:baseURL];
}

/**
 添加JS调用OC的方法数组
 */
- (void)rzwk_addScriptMessageNameArray:(NSArray *)nameArray {
    if (nameArray.count > 0 && [nameArray isKindOfClass:[NSArray class]]) {
        for (NSString *name in nameArray) {
            [self.WKWeb.configuration.userContentController addScriptMessageHandler:self name:name];
        }
    }
}

- (void)rzwk_goBack {
    if ([self.WKWeb canGoBack]) {
        [self.WKWeb goBack];
    }
}

- (void)rzwk_goForward {
    if ([self.WKWeb canGoForward]) {
        [self.WKWeb goForward];
    }
}

- (void)rzwk_reload {
    [self.WKWeb reload];
}

#pragma mark - connectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // 错误描述
    NSLog(@"%@", error.localizedDescription);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    // 预留备用
}

#pragma mark - scriptHandle

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(handleScriptMessage: withWKWebView:)]) {
        [self.delegate handleScriptMessage:message withWKWebView:self.WKWeb];
    }
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

#pragma mark - Navigation Delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView: didStartProvisionalNavigation:)]) {
        [self.delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView: didCommitNavigation:)]) {
        [self.delegate webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView: didFinishNavigation:)]) {
        [self.delegate webView:webView didFinishNavigation:navigation];
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *url_scheme = url.scheme;
    
    if ([url_scheme isEqualToString:self.RZWK_urlScheme]) {
        if ([self.delegate respondsToSelector:@selector(webView:decidePolicyForURL:)]) {
            [self.delegate webView:webView decidePolicyForURL:url_scheme];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // APPStore
    if ([url.absoluteString containsString:@"itunes.apple.com"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 调用电话
    if ([url.scheme isEqualToString:@"tel"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - setter getter 方法

- (BOOL)RZWK_canGoBack {
    return self.WKWeb.canGoBack;
}

- (BOOL)RZWK_canGoForward {
    return self.WKWeb.canGoForward;
}

- (void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    
    if (showProgress) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(0, 0, kRZWKScreeWith, 2.f);
        self.progressView.tintColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0];
        [self.progressView setAlpha:0.f];
        [self addSubview:self.progressView];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.WKWeb.frame = frame;
}

#pragma mark - private Method

// 将文件copy到tmp目录
- (NSURL *)ba_fileURLForBuggyWKWebView8:(NSURL *)fileURL
{
    NSError *error = nil;
    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return nil;
    }
    // Create "/temp/www" directory
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
    // Now copy given file to the temp directory
    [fileManager removeItemAtURL:dstURL error:&error];
    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
    // Files in "/temp/www" load flawlesly :)
    return dstURL;
}

- (NSString *)strUTF8Encoding:(NSString *)str
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)str,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
}

#pragma mark - 移除观察者

- (void)dealloc {
    [self.WKWeb removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.WKWeb removeObserver:self forKeyPath:@"title"];
    [self.WKWeb removeObserver:self forKeyPath:@"URL"];
    
    [self.WKWeb setNavigationDelegate:nil];
    [self.WKWeb setUIDelegate:nil];
    [self.WKWeb removeFromSuperview];
    [self removeFromSuperview];
}

@end
