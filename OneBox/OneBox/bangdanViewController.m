//
//  bangdanViewController.m
//  OneBox
//
//  Created by 谢江新 on 15/6/9.
//  Copyright (c) 2015年 谢江新. All rights reserved.
//

#import "bangdanViewController.h"

#import "SchoolDetailViewController.h"
#import "CustomTabbarController.h"

#import "bangdanCell.h"
#import "FoundModel.h"

#define foundCellHeight 200*_Scale

@interface bangdanViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation bangdanViewController
{
    UIView *banbenview;
    UIView *footview;
    UITableView *_tableView;

    NSArray *titleArr;
    NSMutableArray *_arrayList;
}
#pragma mark - Route 路由方法



#pragma mark - LifeCycle 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=_define_backview_color;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"bangdanViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"bangdanViewController"];

    [[CustomTabbarController sharedManager] tabbarHide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Delegate (确切到某个delegate UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_arrayList.count==indexPath.section)
    {
        return foundCellHeight;
    }
    return foundCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger num=indexPath.row;
    FoundModel *model=_arrayList[num];
    NSDictionary *pushdict=[[NSDictionary alloc] initWithObjectsAndKeys:model.cn_name,@"schoolName",model.sid,@"schoolID",[NSNumber numberWithInteger:model.is_order_school],@"is_order_school",nil];

    if(_type==5||_type==6)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bangdanpush_detail" object:pushdict];

    }else
    {
        SchoolDetailViewController *schoolView=[[SchoolDetailViewController alloc] init];

        schoolView.data_dict=pushdict;
        [self.navigationController pushViewController:schoolView animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_arrayList.count==section) {
        return 0;
    }
    return _arrayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_arrayList.count==indexPath.section)
    {
        static NSString *cellid=@"cellid";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }

    static NSString *cellid=@"cell";
    bangdanCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid ];
    if (!cell) {
        cell=[[bangdanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSInteger num=indexPath.row;
    FoundModel *model=_arrayList[num];
    cell.model =model;
    return cell;
}

#pragma mark - Event handler (响应事件处理 button gesture)
- (void)popviewAction {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - private method (handler data method)
- (void)createTableView {
    CGRect _rect;
    if(_type>4)
    {
        _rect=CGRectMake(0, 0, ScreenWidth, ScreenHeight-100*_Scale-64);
    }else
    {
        _rect=CGRectMake(0, 0, ScreenWidth, ScreenHeight+49);

    }
    _tableView=[[UITableView alloc] initWithFrame:_rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.showsVerticalScrollIndicator=YES;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.sectionIndexColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1];
    [self.view addSubview:_tableView];
    footview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 100)];
    _tableView.tableFooterView=footview;
    [self createVersionView];
    _tableView.backgroundColor=[UIColor clearColor];
}

- (void)createVersionView {
    banbenview=[[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_tableView.frame)-100*_Scale)/2.0f,50*_Scale, 100*_Scale, 100*_Scale)];
    banbenview.backgroundColor=[UIColor clearColor];
    [footview addSubview:banbenview];
    UIImageView *banbenimg=[[UIImageView alloc] initWithFrame:CGRectMake(25*_Scale, 0, 50*_Scale, 50*_Scale)];
    banbenimg.image=[UIImage imageNamed:@"版本_v1.0"];
    [banbenview addSubview:banbenimg];

    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(banbenimg.frame), CGRectGetWidth(banbenview.frame), CGRectGetHeight(banbenview.frame)-CGRectGetMaxY(banbenimg.frame))];
    label.textAlignment=1;
    label.textColor=[UIColor colorWithRed:193.0f/255.0f green:193.0f/255.0f blue:193.0f/255.0f alpha:1];
    label.font=[regular get_en_Font:11.0f];
    [banbenview addSubview:label];
    banbenview.hidden=YES;
}

- (void)setTitleStyle {
    if(_type<=4)
    {
        CGFloat _Default_font=16.0;
        CGFloat _Default_Spacing=3.0f;
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];

        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
        titleLabel.font=[UIFont fontWithName:@"Skia" size:_Default_font];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        [titleLabel setAttributedText:[regular createAttributeString:titleArr[_type-1] andFloat:@(_Default_Spacing)]];
        [view addSubview:titleLabel];
        [titleLabel sizeToFit];
        BOOL _isfit;
        if(CGRectGetWidth(titleLabel.frame)<=230)
        {
            _isfit=NO;
        }else
        {
            for (int i=_Default_font*2;i>0;i--) {


                if(_Default_Spacing<=0)
                {
                    _Default_font-=0.5f;

                }else
                {
                    _Default_Spacing-=0.5f;
                }

                titleLabel.font=[UIFont fontWithName:@"Skia" size:_Default_font];

                [titleLabel setAttributedText:[ToolManager createAttributeString:titleArr[_type-1] andFloat:@(_Default_Spacing)]];
                [titleLabel sizeToFit];
                if(CGRectGetWidth(titleLabel.frame)<=230||_Default_font<=13.0f)
                {
                    break;
                }
            }
        }
        JXLOG(@"Spacing=%f  font=%f",_Default_Spacing,_Default_font);
        if(CGRectGetWidth(titleLabel.frame)>230&&_Default_font==13.0f)
        {
            titleLabel.frame=CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame));
        }else
        {
            titleLabel.frame=CGRectMake((CGRectGetWidth(view.frame)-CGRectGetWidth(titleLabel.frame))/2.0f, (CGRectGetHeight(view.frame)-CGRectGetHeight(titleLabel.frame))/2.0f, CGRectGetWidth(titleLabel.frame), CGRectGetHeight(titleLabel.frame));
        }
        self.navigationItem.titleView=view;
    }

}

- (void)setdata:(NSDictionary *)_dict {
    if(((NSArray *)[_dict objectForKey:@"data"]).count==0)
    {
        [_tableView reloadData];
    }else
    {
        [_arrayList removeAllObjects];
        [_arrayList addObjectsFromArray:[FoundModel parsingData:_dict]];
        banbenview.hidden=NO;
        footview.backgroundColor=_define_backview_color;
        JXLOG(@"%@",_arrayList);
        [_tableView reloadData];
    }
}

- (void)prepareData {
    UIBarButtonItem *_btn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回箭头"] style:UIBarButtonItemStylePlain target:self action:@selector(popviewAction)];
    self.navigationItem.leftBarButtonItem=_btn;
    _arrayList=[[NSMutableArray alloc] init];
}

- (void)featchData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *_parameters=nil;
    if (_type==1) {
        _parameters=@{@"mark":@"niche"};
    } else if(_type==2) {
        _parameters=@{@"mark":@"insider"};
    } else if(_type==5) {
        _parameters=@{@"mark":@"day"};
    } else if(_type==6) {
        _parameters=@{@"mark":@"boarding"};
    } else if(_type==4) {
        _parameters=@{@"mark":@"blue_ribbon"};
    }
    [manager GET:[[NSString alloc] initWithFormat:@"%@%@",DNS,@"/v1/rank_schools"] parameters:_parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self setdata:dict];
        [self->_tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view.window addSubview:[[ToolManager sharedManager] showSuccessfulOperationViewWithTitle:@"网络连接错误，请检查网络" WithImg:@"Prompt_网络出错白色" Withtype:1]];
    }];
}


#pragma mark - getters && setters
- (void)setType:(NSInteger)type {

    titleArr=@[@"Niche 榜",@"Business Insider 榜",@"Prep Review 榜",@"蓝带学校榜"];
    _type=type;

    [self prepareData];
    //    创建tableview
    [self createTableView];

    [self setTitleStyle];

    [self featchData];
}

@end
