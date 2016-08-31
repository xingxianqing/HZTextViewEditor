//
//  HZShowContentViewController.m
//  HZTextViewEditor
//
//  Created by 邢现庆 on 16/8/30.
//  Copyright © 2016年 XianQing Xing. All rights reserved.
//

#import "HZShowContentViewController.h"
#import "HZHeader.h"
#import "HZTextViewEditor.h"

@interface HZShowContentViewController ()<UITextViewDelegate,HZTextViewEditorDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UILabel* titleLable;///<标题lable
@property(nonatomic,strong)HZTextViewEditor* contentTV;///<内容TV
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)NSArray* images;
@property(nonatomic,strong)NSString* titleString;
@property(nonatomic,strong)NSString* contentString;


@end

@implementation HZShowContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.title = @"图文混排";
    
    self.titleString = @"这里是标题";
    
    self.contentString = @"我需要三件东西：爱情友谊和图书。然而这三者之间何其相通！炽热的爱情可以充实图书的内容，图书又是人们最忠实的朋友[IMG#1]时间是一切财富中最宝贵的财富。[IMG#2]土地是以它的肥沃和收获而被估价的；才能也是土地，不过它生产的不是粮食，而是真理。如果只能滋生瞑想和幻想的话，即使再大的才能也只是砂地或盐池，那上面连小草也长不出来的。[IMG#3]世界上一成不变的东西，只有“任何事物都是在不断变化的”这条真理。";
    
    self.images = @[ @"http://static.jinrongbaguanv.com/Fo-VnUD-CM-7XL7k0t9JdJWwerYu",
                     @"http://static.jinrongbaguanv.com/FpjUrDd4jBHmludvMBUsZniIXTHQ",
                     @"http://static.jinrongbaguanv.com/Fhic8xNkwJZsqe-9s5Zyxx8UCuTT"];
    
    self.index = 0;
    
    [self initUI];
    
    [self updateData];
    
}

-(void)initUI{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.scrollView.delegate = self;

    //标题
    self.titleLable = [[UILabel alloc] init];
    [self.titleLable setTextColor:[UIColor blackColor]];
    [self.titleLable setNumberOfLines:0];
    [self.titleLable setFont:[UIFont systemFontOfSize:16]];
    [self.scrollView addSubview:self.titleLable];
    //内容
    self.contentTV = [[HZTextViewEditor alloc]init];
    self.contentTV.delegate = self;
    self.contentTV.editorDelagte = self;
    [self.contentTV setTextColor:[UIColor grayColor]];
    [self.contentTV setScrollEnabled:NO];
    [self.contentTV setEditable:NO];
    [self.contentTV setFont:[UIFont systemFontOfSize:16]];
    [self.scrollView addSubview:self.contentTV];
    [self.view addSubview:self.scrollView];
}

-(void)updateData{
    //标题
    CGFloat titleHeight = [self labelWithString:self.titleString font:[UIFont boldSystemFontOfSize:16] limitWidth:ScreenWidth-50 withPargraphStyle:nil limitHeight:MAXFLOAT].height;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleString];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (titleHeight <21) {
        paragraphStyle.lineSpacing = 0;
    }else{
        paragraphStyle.lineSpacing = 4;
    }
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.titleString length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, [attributedString length])];
    CGSize titleSize = [self labelWithString:self.titleString font:[UIFont boldSystemFontOfSize:16] limitWidth:ScreenWidth-50 withPargraphStyle:paragraphStyle limitHeight:MAXFLOAT];
    [self.titleLable setFrame:CGRectMake(25, 10, titleSize.width, titleSize.height)];
    [self.titleLable setAttributedText:attributedString];
    
    
    //内容
    NSString* content  = self.contentString;
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle1.lineSpacing = 10;
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [content length])];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, [content length])];
    
    
    [self.contentTV setFrame:CGRectMake(20, self.titleLable.frame.origin.y+self.titleLable.frame.size.height+10, ScreenWidth-40, 0)];
    [self.contentTV setAttributedText:attributedString1];

    
    CGSize size = [self.contentTV sizeThatFits:CGSizeMake(ScreenWidth-50, MAXFLOAT)];
    CGRect rect = self.contentTV.frame;
    rect.size.height = size.height;
    self.contentTV.frame = rect;
    
    CGSize scrSize = self.scrollView.contentSize;
    scrSize.height = self.titleLable.frame.size.height + self.contentTV.frame.size.height+30;
    [self.scrollView setContentSize:scrSize];
    
    [self loadImage];
    
}
//加载图片
-(void)loadImage{
    NSLog(@"%ld",self.index);
    NSUInteger i = self.index;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableAttributedString* contentStr = [[NSMutableAttributedString alloc]initWithAttributedString:self.contentTV.attributedText];
        NSString* imageurl = self.images[i];
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]]];
        NSString* index = [NSString stringWithFormat:@"[IMG#%ld]",i+1];
        NSRange range = [contentStr.string rangeOfString:index];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (range.location != NSNotFound) {
                
                [self.contentTV insertTextAttachmentByImage:image andImageTag:i andRange:range andIsDeleteCharacters:YES];
                
            }
            CGSize size = [self.contentTV sizeThatFits:CGSizeMake(ScreenWidth-50, MAXFLOAT)];
            
            CGRect rect = self.contentTV.frame;
            rect.size.height = size.height;
            self.contentTV.frame = rect;

            CGSize scrSize = self.scrollView.contentSize;
            scrSize.height = self.titleLable.frame.size.height + self.contentTV.frame.size.height+30;
            [self.scrollView setContentSize:scrSize];
            
            
            if (self.index == self.images.count-1) {
               //停止
            }else{
                //继续加载下一张
                self.index += 1;
                [self loadImage];
            }
            
        });
    });
}


#pragma mark -- UITextViewDelegate   点击图片后 会触发，响应速度慢
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
    
    HZTextAttachment* ta = (HZTextAttachment*)textAttachment;
    [self goPhotoViewer:ta.imageTag];
    
    return YES;
}

#pragma mark --HZTextViewEditorDelegate     点击图片后 会触发，响应的速度快
-(void)touched:(HZTextViewEditor *)textViewEditor andIndex:(NSUInteger)index{
    
    [self goPhotoViewer:index];

}

-(void)goPhotoViewer:(NSUInteger)index{
    
    //可以在此处展示点击的图片、、、
    

}


-(CGSize)labelWithString:(NSString*)string font:(UIFont*)font limitWidth:(float)width withPargraphStyle:(NSParagraphStyle*)paragraphStyle limitHeight:(float)height{
    CGRect rect;
    if (paragraphStyle == nil) {
        rect = [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    }else{
        rect = [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil];
    }
    return rect.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
