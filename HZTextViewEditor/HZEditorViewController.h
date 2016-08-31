//
//  HZViewController.h
//  JinRongArticle
//
//  Created by 邢现庆 on 16/6/22.
//  Copyright © 2016年 91JinRong. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HZTextViewEditor.h"


@interface HZEditorViewController : UIViewController

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) UIView *noteTextBackgroudView;
//内容
@property(nonatomic,strong) HZTextViewEditor *noteTextView;

//输入标题的输入框
@property(nonatomic,strong)UITextView* inputTitle;


@end
