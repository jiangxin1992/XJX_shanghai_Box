//
//  webViewController.m
//  OneBox
//
//  Created by 谢江新 on 15/7/7.
//  Copyright (c) 2015年 谢江新. All rights reserved.
//

#import "webViewController.h"

@interface webViewController ()<UIWebViewDelegate>

@end

@implementation webViewController
{

    UIWebView *web;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
}



-(void)loadData
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager GET:[[NSString alloc] initWithFormat:@"%@%@%@",DNS,@"/v1/app_settings/",[_dict objectForKey:@"type"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *html = operation.responseString;
        NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
        NSString *str2=nil;
        if([[dict objectForKey:@"data"] objectForKey:@"html_url"]==[NSNull null])
        {
            str2=@"";
        }else
        {
            str2=[[dict objectForKey:@"data"] objectForKey:@"html_url"];
        }
        web.backgroundColor = [UIColor clearColor];
        web.delegate=self;

        if(![str2 isEqualToString:@""])
        {
            NSURL *url =[NSURL URLWithString:str2];
            NSURLRequest *request =[NSURLRequest requestWithURL:url];
            [web loadRequest:request];

        }
        web.opaque = NO;
        web.dataDetectorTypes = UIDataDetectorTypeNone;


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view.window addSubview:[[ToolManager sharedManager] showSuccessfulOperationViewWithTitle:@"网络连接错误，请检查网络" WithImg:@"Prompt_网络出错蓝色" Withtype:2]];
        [[ToolManager sharedManager] removeProgress];
    }];
    
}
-(void)setDict:(NSDictionary *)dict
{
    if(_dict!=dict)
    {
        _dict=[dict copy];

         self.view.backgroundColor= _define_backview_color;
        UIImageView *daohang=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        [self.view addSubview:daohang];
        daohang.image=[UIImage imageNamed:@"导航底图"];
        daohang.userInteractionEnabled=YES;

        UILabel *label_title=[[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-250)/2.0f, CGRectGetHeight(daohang.frame)-40, 250, 30)];
        label_title.font=[regular getFont:16.0f];

        [label_title setAttributedText:[regular createAttributeString:[_dict objectForKey:@"title"] andFloat:@(9.0/3.0)]];
        label_title.textColor=[UIColor whiteColor];
        label_title.textAlignment=1;
        [daohang addSubview:label_title];
        if(!_isPad)
        {
            [label_title sizeToFit];

            label_title.frame=CGRectMake((ScreenWidth-250)/2.0f, 60*_Scale-((CGRectGetHeight(label_title.frame)-30*_Scale))/2.0f, 250, CGRectGetHeight(label_title.frame));

        }



        UIButton *backbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        backbtn.frame=CGRectMake(0, 0, 64, 64);
        [backbtn addTarget:self action:@selector(popviewAction) forControlEvents:UIControlEventTouchUpInside];
        [daohang addSubview:backbtn];
        UIImageView *icon=[[UIImageView alloc] initWithFrame:CGRectMake(14, 30, 10, 15)];
        [icon setImage:[UIImage imageNamed:@"返回箭头"]];
        [backbtn addSubview:icon];
        web=[[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(daohang.frame), ScreenWidth, ScreenHeight-64)];
        [self.view addSubview:web];
        [self loadData];

    }
}

-(void)popviewAction
{
    self.block();
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"webViewController"];

    [self.navigationController setNavigationBarHidden:YES animated:NO];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"webViewController"];
//      [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


@end
