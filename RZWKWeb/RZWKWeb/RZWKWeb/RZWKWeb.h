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
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (void)handleScriptMessage:(WKScriptMessage *)message withWKWebView:(WKWebView *)webView;
- (void)setTitle:(NSString *)title;

@end

@interface RZWKWeb : UIView

/** 代理 */
@property (nonatomic, weak) id <RZWKWebDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame withNativeMethodArr:(NSArray *)arr;
- (void)loadRequestWithUrlString:(NSString *)urlstring;
- (void)loadHTMLString:(NSString *)html;
- (BOOL)back;
- (BOOL)forward;

@end
