//
//  webViewController.h
//  OneBox
//
//  Created by 谢江新 on 15/7/7.
//  Copyright (c) 2015年 谢江新. All rights reserved.
//
typedef  void(^bl)();
#import <UIKit/UIKit.h>

@interface webViewController : UIViewController
@property (nonatomic,copy)bl block;
@property(nonatomic,copy)NSDictionary *dict;
@end
