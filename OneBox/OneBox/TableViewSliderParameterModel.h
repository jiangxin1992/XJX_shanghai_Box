//
//  TableViewSliderParameterModel.h
//  OneBox
//
//  Created by yyj on 2018/4/19.
//  Copyright © 2018年 谢江新. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewSliderParameterModel : NSObject

@property (nonatomic, strong) NSNumber *isNavShow;//导航栏是否出现 BOOL
@property (nonatomic, assign) NSNumber *isNavAnimation;//导航栏动画是否在进行中 BOOL
@property (nonatomic, strong) NSNumber *isDragging;//表示tableview开始拖动，记录拖动的开始 BOOL
@property (nonatomic, strong) NSNumber *isAppear;//BOOL

@property (nonatomic, strong) NSNumber *bKeyBoardHide;//判断键盘显示状态 BOOL


@property (nonatomic, strong) NSNumber *isCard;//BOOL
@property (nonatomic, strong) NSNumber *m_row;//NSInteger
@property (nonatomic, strong) NSNumber *m_section;//NSInteger

@property (nonatomic, strong) NSNumber *m_row1;//NSInteger
@property (nonatomic, strong) NSNumber *m_section1;//NSInteger

@end
