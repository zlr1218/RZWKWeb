//
//  RZWebVC.h
//  RZWKWeb
//
//  Created by 利基 on 2017/5/27.
//  Copyright © 2017年 RZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZWKWeb.h"

@interface RZWebVC : UIViewController<RZWKWebDelegate>

/** url */
@property (nonatomic, copy) NSString *path;

/** 参数 */
@property (nonatomic, strong) NSMutableDictionary *dict;

/** web */
@property (nonatomic, strong) RZWKWeb *web;

/**
 返回方法（可重写）
 */
- (void)back;

@end
