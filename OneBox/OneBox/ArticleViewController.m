//
//  FoundViewController.m
//  OneBox
//
//  Created by 谢江新 on 15/12/7.
//  Copyright © 2015年 谢江新. All rights reserved.
//

#import "ArticleViewController.h"

#import "MJRefresh.h"

#import "ArticleColViewController.h"
#import "ArticleDetailViewController.h"
#import "CustomTabbarController.h"
#import "LoginViewController.h"

#import "ArticleCell.h"

#import "ArticleModel.h"

#define foundCellHeight 360*_Scale

@interface ArticleViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIButton *rightBarbtn;
@property (nonatomic, assign) NSInteger Record_cell_num;
@property (nonatomic, assign) CGFloat min_offset;
@property (nonatomic, strong) UITableView *tableView;
//    开始
@property (nonatomic, assign) BOOL isfirst_choose;//是否是第一次打开筛选视图
//    滑动image
@property (nonatomic, assign) BOOL nav_donghua;//记录导航栏是否滑动上去（是否消失）
@property (nonatomic, assign) CGFloat start_y;//表示tableview开始拖动时候的起始位置
@property (nonatomic, assign) BOOL Dragging;//表示tableview开始拖动，记录拖动的开始
@property (nonatomic, assign) BOOL appear;
@property (nonatomic, assign) NSInteger page;//记录当前page

@property (nonatomic, strong) NSMutableArray *arrayData;//存放页面的数据

@end

@implementation ArticleViewController
{
    BOOL bKeyBoardHide;//判断键盘显示状态
    void (^blockSuccess)(NSDictionary *dict);//主界面数据请求成功后调用
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNotication];
    [self SomePrepare];
    [self UIConfig];
    [self setupRefresh];
    [self createBlock];
}
#pragma mark-----------------Notications----------------
//创建该界面中的Notication
-(void)createNotication
{
//    将导航栏的位置还原（应对 app推出后台时候导航栏异常情况）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navBarReset) name:@"navBarReset" object:nil];
//    添加键盘监控,在键盘消失或者出现时候会调用，来改变bKeyBoardHide的值，以此来判断当前键盘是否为弹出状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//键盘消失时候调用
-(void)keyboardWillHide:(NSNotification *)notification
{
    bKeyBoardHide = YES;
}
//键盘出现时候调用
-(void)keyboardWillShow:(NSNotification *)notification
{
    bKeyBoardHide = NO;
}

#pragma mark*导航栏重置
-(void)navBarReset
{
//将导航栏位置复原
    self.navigationController.navigationBar.frame=CGRectMake(0, kStatusBarHeight, [[UIScreen mainScreen] bounds].size.width, kNavigationBarHeight);
//    导航栏标题透明度还原成1，还原_Dragging，_nav_donghua
    self.navigationItem.titleView.alpha=1;
    _rightBarbtn.alpha=1;
    _Dragging=NO;
    _nav_donghua=NO;
}
#pragma mark-----------------SomePrepare----------------
-(void)SomePrepare
{
    [self PrepareData];//一些数据的初始化
    [self PrepareUI];//一些初始化UI的准备
    WeakSelf(ws);
    changeBlock=^(NSInteger row)
    {
        ((ArticleModel *)[ws.arrayData objectAtIndex:row]).isapp=YES;
    };
}
-(void)PrepareData
{
    _Record_cell_num=0;
    _page=1;
    bKeyBoardHide=YES;//开始时候键盘为隐藏状态
    _appear=YES;
    _Dragging=NO;
    _nav_donghua=NO;
    _start_y=0;
    _isfirst_choose=YES;
    _arrayData=[[NSMutableArray alloc] init];
}

-(void)PrepareUI
{
//    设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:70.0f/255.0f green:195.0f/255.0f blue:247.0f/255.0f alpha:1];
//    设置背景颜色
    self.view.backgroundColor=_define_backview_color;
//    添加标题

    self.navigationItem.titleView=[regular returnNavView:@"发现" withmaxwidth:200];

}
#pragma mark-----------------UIConfig----------------
-(void)UIConfig
{
    _rightBarbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBarbtn setImage:[UIImage imageNamed:@"article_icon_收藏"] forState:UIControlStateNormal];
    [_rightBarbtn setBackgroundImage:[UIImage imageNamed:@"article_icon_收藏"] forState:UIControlStateNormal];
    _rightBarbtn.contentMode = UIViewContentModeScaleAspectFill;
    _rightBarbtn.frame=CGRectMake(0, 0, 18, 18);
    [_rightBarbtn addTarget:self action:@selector(pushColView) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *_btn=[[UIBarButtonItem alloc] initWithCustomView:_rightBarbtn];
    self.navigationItem.rightBarButtonItem=_btn;
//    创建tableview
    [self createTableView];

}
-(void)pushColView
{
    if(![regular isLogin])
    {
        LoginViewController*login=[[LoginViewController alloc] init];
        login.type=@"other";
        [self.navigationController pushViewController:login animated:YES];
    }else
    {
        [self.navigationController pushViewController:[ArticleColViewController new] animated:YES];
    }
}
#pragma mark*创建TableView
-(void)createTableView
{
    _tableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-kTabBarHeight);
    }];
    _tableView.delegate=self;
    _tableView.dataSource=self;
//    水平方向滑条显示
    _tableView.showsVerticalScrollIndicator=YES;
    _tableView.backgroundColor=_define_backview_color;
//    消除分割线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _min_offset=_tableView.contentOffset.y;
}
#pragma mark-----------------Refresh----------------
#pragma mark*开始进入刷新状态
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    WeakSelf(ws);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws headerRereshing];
    }];
    _tableView.mj_header = header;
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;

    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [ws footerRereshing];
    }];

    [_tableView.mj_header beginRefreshing];
}
- (void)headerRereshing
{
    _page=1;//page初始化
    [self requestData];//请求列表
}
-(void)footerRereshing
{
    _page++;//下一页
    [self requestData];//请求下一页列表
}
#pragma mark-----------------Requests----------------
#pragma mark*主界面
//主界面列表数据的请求
-(void)requestData
{
//    创建参数列表
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
//    添加page
    [dict setObject:[[NSString alloc] initWithFormat:@"%ld",(long)_page] forKey:@"page"];

    [dict setObject:[regular getToken] forKey:@"token"];
//请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[[NSString alloc] initWithFormat:@"%@%@",DNS,@"/v1/posts"] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
//        请求成功后的处理
        blockSuccess(dict);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView.mj_header endRefreshing];
        [self.view.window addSubview:[[ToolManager sharedManager] showSuccessfulOperationViewWithTitle:@"网络连接错误，请检查网络" WithImg:@"Prompt_网络出错白色" Withtype:1]];
    }];
}

#pragma mark-----------------AnalyseData----------------
#pragma mark*主界面数据处理
-(void)createBlock
{
    [self SuccessBlock];
}
-(void)SuccessBlock
{
    WeakSelf(ws);
    blockSuccess=^(NSDictionary *_dict)
    {
//        刷新动画收起
        [ws.tableView.mj_header endRefreshing];
        [ws.tableView.mj_footer endRefreshing];
        if(ws.page==1)
        {
            [ws.arrayData removeAllObjects];
        }

//        数据处理，获取模型数组
        NSArray *getdata=[ArticleModel parsingData:_dict];
//        当获取数据count数量大于0时候，刷新tableview

        if(getdata.count>0)
        {
            [ws.arrayData addObjectsFromArray:getdata];
            [ws.tableView reloadData];
        }else
        {
            [ws.view.window addSubview:[[ToolManager sharedManager] showSuccessfulOperationViewWithTitle:@"没有更多了" WithImg:@"Prompt_提交成功" Withtype:1]];
        }
    };
}

#pragma mark-----------------Actions----------------
#pragma mark*空
//一些空action，处理一些异常
-(void)nullAction{}


//删除背景蒙板
-(void)backview1Action__2
{
    [[self.view viewWithTag:100] removeFromSuperview];
}


#pragma mark-----------------SomeDelegate----------------

#pragma mark*TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //结束编辑点击键盘上的return键执行动画效果使视图回落
    [textField resignFirstResponder];
    if([textField.text isEqualToString:@""])
    {
        [[ToolManager sharedManager] alertTitle_Simple:@"请输入关键字"];
    }else
    {
//        //跳转到搜索页面
//        SouSuoViewController *sousuo= [[SouSuoViewController alloc] init];
//        sousuo.keystring=textField.text;
//        [self.navigationController pushViewController:sousuo animated:YES];
    }
    return YES;
}


#pragma mark*ScrollViewDelegate
//导航栏的动画显示与隐藏
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_appear&&scrollView==_tableView)
    {
//        记录开始滑动时候tableview的偏移量
        _start_y=scrollView.contentOffset.y;
//        开始滑动
        _Dragging=YES;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat _height=scrollView.contentOffset.y+CGRectGetHeight(_tableView.frame)-_min_offset-kTabBarHeight;

    NSInteger now_cell=0;
    if(_isPad)
    {
        now_cell=(NSInteger)(_height/((NSInteger)360*_Scale));
    }else
    {
        now_cell=(NSInteger)(_height/180);
    }

    if(now_cell!=_Record_cell_num)
    {
        _Record_cell_num=now_cell;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ArticleAnimation" object:[NSNumber numberWithLong:_Record_cell_num]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ArticleAnimation1" object:nil];

    if(_Dragging)
    {
//        当导航栏已经消失
        if(_appear&&scrollView==_tableView)
        {
            if(_start_y<20&&scrollView.contentOffset.y>20)
            {
//            当开始时偏移量小于20并且当前偏移量大于20，开始上滑动画
                [self SlideUpAction];
            }else
            {
                if(scrollView.contentOffset.y<20)
                {
                    [self SlideDownAction];
                }else
                {
                    if(!_nav_donghua&&((scrollView.contentOffset.y-_start_y)>(ScreenHeight/4.0f)))
                    {
                        [self SlideUpAction];
                    }else if(_nav_donghua&&((_start_y-scrollView.contentOffset.y)>(ScreenHeight/4.0f)))
                    {

                        [self SlideDownAction];
                    }
                }
            }
        }
    }
}
//导航栏恢复动画
-(void)SlideDownAction
{
    [UIView beginAnimations:@"SlideDownAction" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.navigationController.navigationBar.frame=CGRectMake(0, kStatusBarHeight, [[UIScreen mainScreen] bounds].size.width, kNavigationBarHeight);
    _rightBarbtn.alpha=1;
    self.navigationItem.titleView.alpha=1;
    [UIView commitAnimations];
    _nav_donghua=NO;
}
//导航栏上滑动画
-(void)SlideUpAction
{
    [UIView beginAnimations:@"SlideUpAction" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.navigationController.navigationBar.frame=CGRectMake(0, kStatusBarHeight - kStatusBarAndNavigationBarHeight, [[UIScreen mainScreen] bounds].size.width, kNavigationBarHeight);
    _rightBarbtn.alpha=0;
    self.navigationItem.titleView.alpha=0;
    [UIView commitAnimations];
    _nav_donghua=NO;

}
//滑动结束时候调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if(_appear&&scrollView==_tableView)
    {
        _Dragging=NO;
    }
}
// 回到最顶部
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
//导航栏恢复
    _Dragging=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, kStatusBarHeight, [[UIScreen mainScreen] bounds].size.width, kNavigationBarHeight);
    _rightBarbtn.alpha=1;
    self.navigationItem.titleView.alpha=1;
    _nav_donghua=NO;

    return YES;
}
#pragma mark*TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return foundCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(!bKeyBoardHide)
    {
//        当键盘为出现状态时，触发 键盘消失方法
        [regular dismissKeyborad];

    }else
    {
//键盘没有出现时候调用
        ArticleDetailViewController *Article=[[ArticleDetailViewController alloc] init];
        Article.ArticleID=[[NSString alloc] initWithFormat:@"%lld",[((ArticleModel *)[_arrayData objectAtIndex:indexPath.row]).m_id longLongValue]];
        [self.navigationController pushViewController:Article animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(_arrayData.count==section)
    {
        return 0;
    }
    return _arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    数据还未获取时候
    if(_arrayData.count==indexPath.section)
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
//获取到数据以后
    static NSString *cellid=@"ArticleCell";
    ArticleCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
//6 3
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[_arrayData objectAtIndex:indexPath.row],@"model",[NSNumber numberWithInteger:indexPath.row],@"row",[NSNumber numberWithInteger:[_arrayData count]],@"num",nil];
    cell.block=changeBlock;
    cell.dict=dict;


    return cell;



}

#pragma mark-----------------Others----------------

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _appear=YES;
//    tabbar设为出现
    [[CustomTabbarController sharedManager] tabbarAppear];
//    友盟页面监控（登出）
    [MobClick beginLogPageView:@"FoundViewController"];

    self.navigationController.navigationBar.subviews[0].subviews[0].hidden = YES;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    导航栏还原
    _appear=NO;
    _Dragging=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, kStatusBarHeight, [[UIScreen mainScreen] bounds].size.width, kNavigationBarHeight);
    self.navigationItem.titleView.alpha=1;
    _rightBarbtn.alpha=1;
    _nav_donghua=NO;
//    友盟页面监控（进入）
    [MobClick endLogPageView:@"FoundViewController"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
