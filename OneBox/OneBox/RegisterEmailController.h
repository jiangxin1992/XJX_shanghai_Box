//
//  RegisterController.h
//  OneBox
//
//  Created by 谢江新 on 15-2-5.
//  Copyright (c) 2015年 谢江新. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^bl)(void);

@interface RegisterEmailController : UIViewController
{
    void(^disblock)(void);
}

@property (nonatomic,copy)bl block2;
@property (nonatomic,copy)bl block;
@property (nonatomic,copy)NSString *type;

@end
