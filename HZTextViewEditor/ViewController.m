//
//  ViewController.m
//  HZTextViewEditor
//
//  Created by 邢现庆 on 16/8/30.
//  Copyright © 2016年 XianQing Xing. All rights reserved.
//

#import "ViewController.h"
#import "HZHeader.h"
#import "HZEditorViewController.h"
#import "HZShowContentViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Main";
    
    UIButton* editor = [[UIButton alloc]initWithFrame:CGRectMake(10, 100, ScreenWidth-20, 50)];
    [editor setBackgroundColor:[UIColor redColor]];
    [editor setTitle:@"图文混编" forState:UIControlStateNormal];
    [editor addTarget:self action:@selector(goEditor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editor];
    
    UIButton* show = [[UIButton alloc]initWithFrame:CGRectMake(10, 180, ScreenWidth-20, 50)];
    [show setBackgroundColor:[UIColor redColor]];
    [show setTitle:@"图文混排" forState:UIControlStateNormal];
    [show addTarget:self action:@selector(goLoad) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:show];
}

-(void)goEditor{
    HZEditorViewController* vc = [[HZEditorViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)goLoad{
    HZShowContentViewController* vc = [[HZShowContentViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    }

@end
