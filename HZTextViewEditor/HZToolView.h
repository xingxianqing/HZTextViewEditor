//
//  HZToolView.h
//  JinRongArticle
//
//  Created by 邢现庆 on 16/8/15.
//  Copyright © 2016年 91JinRong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HZToolViewDelegate <NSObject>

-(void)selectImageAction;

@end


@interface HZToolView : UIView

@property(nonatomic,strong)UIButton* selectImgBtn;
@property(nonatomic,strong)UILabel* textNumLabel;
@property(nonatomic,strong)UIImageView* selectImg;
@property(nonatomic,weak)id <HZToolViewDelegate> delegate;

-(void)showOrHidenSelectImageBtn:(BOOL)isShow;
@end
