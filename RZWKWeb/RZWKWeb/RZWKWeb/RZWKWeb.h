//
//  RZWKWeb.h
//  gold
//
//  Created by 利基 on 2017/5/26.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@protocol RZWKWebDelegate <NSObject>

@optional
// 获取当前Web的title
- (void)handleTitle:(NSString *)title;

// 获取当前Web的加载进度
- (void)handleProgress:(CGFloat)progress;

// 获取当前Web请求的URL
- (void)handleCurrentURL:(NSURL *)URL;

// 当Web内容开始在Web视图中加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;

// Web视图开始接收Web内容时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

// Web视图加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

// 从网页收到脚本消息时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
- (void)handleScriptMessage:(WKScriptMessage *)message withWKWebView:(WKWebView *)webView;

@end

@interface RZWKWeb : UIView

/** 代理 */
@property (nonatomic, weak) id <RZWKWebDelegate> delegate;

/**
 是否可以返回上级页面
 */
@property (nonatomic, readonly) BOOL RZWK_canGoBack;

/**
 是否可以进入下级页面
 */
@property (nonatomic, readonly) BOOL RZWK_canGoForward;

/**
 需要拦截的 urlScheme，先设置此项，再 调用 ba_web_decidePolicyForNavigationActionBlock 来处理，详见 demo
 */
@property(nonatomic, strong) NSString *RZWK_urlScheme;

/**
 是否需要自动设定高度
 */
@property (nonatomic, assign) BOOL RZWK_isAutoHeight;

/** 是否使用进度条 */
@property (nonatomic, assign) BOOL showProgress;


+ (instancetype)rzwk_WebWithFrame:(CGRect)frame delegate:(id<RZWKWebDelegate>)delegate;


- (void)rzwk_loadRequest:(NSURLRequest *)request;

- (void)rzwk_loadURL:(NSURL *)URL;

- (void)rzwk_loadURLString:(NSString *)URLString;

/**
 加载本地网页
 */
- (void)rzwk_loadHTMLFileName:(NSString *)htmlName;

/**
 加载本地 htmlString
 */
- (void)rzwk_loadHTMLString:(NSString *)htmlString;

/**
 添加JS调用OC的方法数组
 */
- (void)rzwk_addScriptMessageNameArray:(NSArray *)nameArray;

/**
 返回上一级页面
 */
- (void)rzwk_goBack;

/**
 进入下一级页面
 */
- (void)rzwk_goForward;

/**
 刷新当前web
 */
- (void)rzwk_reload;

@end
