//
//  UIView+RZAlert.h
//  RZBaseProject
//
//  Created by 利基 on 2017/11/13.
//  Copyright © 2017年 RZOL. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RZAlertCancleBlock)();
typedef void(^RZAlertSureBlock)();



@class RZAlertStyle;
@interface UIView (RZAlert)

/**
 单键
 仅展示Message、cancleTitle默认是‘我知道了’
 */
- (void)makeAlert:(NSString *)message;

/**
 双键
 展示Title、Message、SureTitle、SureBlock，cancleTitle默认是‘关闭’
 */
- (void)makeAlert:(NSString *)message
            Title:(NSString *)title
        sureTitle:(NSString *)sureTitle
        sureBlock:(RZAlertSureBlock)sureBlock;

/**
 单键
 展示Title、Message、CancleTitle、CancleBlock（cancleTitle不能为空）
 */
- (void)makeAlert:(NSString *)message
            Title:(NSString *)title
      cancleTitle:(NSString *)cancleTitle
      cancleBlock:(RZAlertCancleBlock)cancleBlock;

/**
 自定义单双键、cancleTitle不能为空
 */
- (void)makeAlert:(NSString *)message
            title:(NSString *)title
            style:(RZAlertStyle *)style
      cancleTitle:(NSString *)cancleTitle
      cancleBlock:(RZAlertCancleBlock)cancleBlock
        sureTitle:(NSString *)sureTitle
        sureBlock:(RZAlertSureBlock)sureBlock;

@end

@interface RZAlertStyle: NSObject

/** title color */
@property (nonatomic, strong) UIColor *titleColor;

/** title font */
@property (nonatomic, strong) UIFont *titleFont;

/** title alignment */
@property (nonatomic, assign) NSTextAlignment titleAlignment;


/** message color */
@property (nonatomic, strong) UIColor *messageColor;

/** message fony */
@property (nonatomic, strong) UIFont *messageFont;

/** message alignment */
@property (nonatomic, assign) NSTextAlignment messageAlignment;


/** btnTitleColor */
@property (nonatomic, strong) UIColor *btnTitleColor;

/** btnTitleFont */
@property (nonatomic, strong) UIFont *btnTitleFont;



/** contentViewBGColor */
@property (nonatomic, strong) UIColor *contentViewBGColor;
/** CornerRadius */
@property (nonatomic, assign) CGFloat cornerRadius;



/** isCloseAlert */
@property (nonatomic, copy) NSString *isCloseAlert;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDefaultSytle NS_DESIGNATED_INITIALIZER;

@end

@interface RZAlertManager: NSObject

/**
 setter, getter 方法
 */
+ (void)setSharedStyle:(RZAlertStyle *)sharedStyle;
+ (RZAlertStyle *)sharedStyle;

@end
