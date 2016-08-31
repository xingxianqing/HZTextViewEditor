//
//  HZToolView.m
//  JinRongArticle
//
//  Created by 邢现庆 on 16/8/15.
//  Copyright © 2016年 91JinRong. All rights reserved.
//

#import "HZToolView.h"
#import "HZHeader.h"


@implementation HZToolView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self addSubview:self.selectImg];
        [self addSubview:self.selectImgBtn];
        [self addSubview:self.textNumLabel];
        [self.selectImgBtn addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
        UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        [lable setBackgroundColor:COLOR_204];
        [self addSubview:lable];
    }
    return self;
}
-(UIImageView *)selectImg{
    if (!_selectImg) {
        _selectImg = [[UIImageView alloc]init];
        [_selectImg setFrame:CGRectMake(25, 15, 20, 20)];
        [_selectImg setImage:[UIImage imageNamed:@"selectImage"]];
        
    }
    return _selectImg;
}

-(UIButton *)selectImgBtn{
    if (!_selectImgBtn) {
        _selectImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectImgBtn setFrame:CGRectMake(10, 0, 50, 50)];
        [_selectImgBtn setBackgroundColor:[UIColor clearColor]];
    }
    return _selectImgBtn;
}

-(UILabel *)textNumLabel{
    if (!_textNumLabel) {
        _textNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 15, self.bounds.size.width - 125, 20)];
        [_textNumLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_textNumLabel setTextColor:COLOR_204];
        [_textNumLabel setTextAlignment:NSTextAlignmentRight];
    }
    return _textNumLabel;
}

-(void)showOrHidenSelectImageBtn:(BOOL)isShow{
    [self.selectImgBtn setHidden:isShow];
    [self.selectImg setHidden:isShow];
}

#pragma mark --HZToolViewDelegate
-(void)selectImage:(UIButton*)sender{
    [self.delegate selectImageAction];
}



@end
