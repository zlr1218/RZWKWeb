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
- (void)handleTitle:(NSString *)title;
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (void)handleScriptMessage:(WKScriptMessage *)message withWKWebView:(WKWebView *)webView;

@end

@interface RZWKWeb : UIView

/** 代理 */
@property (nonatomic, weak) id <RZWKWebDelegate> delegate;

/** 是否使用进度条 */
@property (nonatomic, assign) BOOL showProgress;
/** 是否使用加载指示器 */
@property (nonatomic, assign) BOOL showHUD;

//+ (instancetype)shareInstance;


/**
 当需要添加与JS交互的方法时调用
 
 @param url 加载链接
 @param mArr JS调用原生方法的数组
 */
- (void)loadDataWithUrl:(NSString *)url WithMethodArr:(NSArray *)mArr;

/** 加载数据 */
- (void)loadDataWithUrl:(NSString *)url;

/** 加载本地网页 */
- (void)loadDataWithHTMLString:(NSString *)html;

/** 后退、前进 */
- (BOOL)back;
- (BOOL)forward;

@end
