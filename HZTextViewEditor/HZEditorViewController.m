///
//  HZViewController.m
//  JinRongArticle
//
//  Created by 邢现庆 on 16/6/22.
//  Copyright © 2016年 91JinRong. All rights reserved.
//

#import "HZEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HZToolView.h"
#import "HZHeader.h"
#import "HZShowContentViewController.h"

@interface HZEditorViewController ()<UITextViewDelegate,HZToolViewDelegate,HZTextViewEditorDelegate>
{
    //备注文本View高度
    float noteTextHeight;
    float titleTextHeight;
    float allViewHeight;
    
}
@property(nonatomic,strong)HZToolView* toolView;
@property(nonatomic,assign)CGFloat cursorPositionY;
@property(nonatomic,assign)BOOL isContentBeginEditing;//是不是内容的textView在响应
@property(nonatomic,assign)CGFloat keyboardHeight;///<键盘高度

@property(nonatomic,strong)UILabel* lineLable;
@property(nonatomic,strong)UILabel *placeLabel;

@property(nonatomic,strong)NSString * contentString;
@property(nonatomic,strong)NSArray  * bigImagesDataArray;

@end

@implementation HZEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图文混编";
    self.keyboardHeight = 0;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //收起键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self initViews];
    
    [self initHZToolView];
    
    [self initNavBarButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:)
                                                  name:UIKeyboardDidHideNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(inputTitleTextViewEditChanged:)
                                                name:UITextViewTextDidChangeNotification
                                              object:self.inputTitle];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:)
                                                name:UITextViewTextDidChangeNotification
                                              object:self.noteTextView];
    
}

-(void)initHZToolView{
    self.toolView = [[HZToolView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 49)];
    self.toolView.backgroundColor = [UIColor whiteColor];
    self.toolView.delegate = self;
    self.noteTextView.inputAccessoryView = self.toolView;
    self.inputTitle.inputAccessoryView = self.toolView;
}
#pragma mark -- HZTextViewEditorDelegate
-(void)updateUIFrame{
    CGRect cursorRect = [self.noteTextView caretRectForPosition:self.noteTextView.selectedTextRange.start];
    self.cursorPositionY = cursorRect.origin.y + cursorRect.size.height;
    [self textChanged];
}

#pragma mark -- HZToolViewDelegate
-(void)selectImageAction{
    //检查已选图片数量
    if (![self.noteTextView checkImageCount]) {
        return;
    }
    //去选图片
    [self.noteTextView pickImageFromLibraryClicked];
}

-(void)keyboardWillShow:(NSNotification* )note{
    NSDictionary *info = [note userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
    
    [self textChanged];
}
- (void) keyboardWasHidden:(NSNotification *) notif{
    self.scrollView.contentSize = CGSizeMake(0,allViewHeight-self.keyboardHeight);
    self.keyboardHeight = 0;
}
//提交
-(void)initNavBarButton{
    UIButton* right = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 25)];
    right.backgroundColor = [UIColor redColor];
    [right setTitle:@"提交" forState:UIControlStateNormal];
    [right.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [right.layer setCornerRadius:5];
    [right addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark -   提交
-(void)sendAction:(UIButton*)sender{
    [self.inputTitle resignFirstResponder];
    [self.noteTextView resignFirstResponder];
    
    if (self.inputTitle.attributedText == nil ||
        self.inputTitle.attributedText.length == 0) {
        
        [self showAlert:@"请输入标题"];
        return;
    }
    if (self.noteTextView.attributedText == nil ||
        self.noteTextView.attributedText.length == 0 ||
        [self.noteTextView.text isEqualToString:@"请输入内容(1000字以内)"]) {
        
        [self showAlert:@"请输入内容"];
        return ;
    }
    
    NSLog(@"编辑的标题：%@",self.inputTitle.text);

    NSDictionary* dic = [self.noteTextView getContentData];
    NSArray* images = [dic objectForKey:@"images"];
    NSString* string = [dic objectForKey:@"text"];
    NSLog(@"编辑内容的图片个数：%lu",images.count);
    NSLog(@"编辑内容的图片个数：%@",string);

    
}


-(void)initViews{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //标题
    _inputTitle = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, ScreenWidth-40, titleTextHeight)];
    _inputTitle.delegate = self;
    [_inputTitle setFont:[UIFont boldSystemFontOfSize:16]];
    [_inputTitle setScrollEnabled:NO];
    _placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_inputTitle.frame.origin.x,
                                                            _inputTitle.frame.origin.y+2,
                                                            ScreenWidth-40,
                                                            20)];
    _placeLabel.text = @"请输入标题(50字以内)";
    _placeLabel.font = [UIFont boldSystemFontOfSize:16];
    _placeLabel.textColor = [UIColor lightGrayColor];

    //横线
    UILabel* line = [[UILabel alloc]initWithFrame:CGRectMake(25,
                                                             _inputTitle.frame.origin.y+_inputTitle.frame.size.height+20,
                                                             ScreenWidth-50,
                                                             0.5)];
    line.backgroundColor = COLOR_204;
    self.lineLable = line;
    //输入内容
    _noteTextView = [[HZTextViewEditor alloc]init];
    _noteTextView.textColor = COLOR_153;
    _noteTextView.delegate = self;
    _noteTextView.editorDelagte = self;
    _noteTextView.font = [UIFont systemFontOfSize:16];
    _noteTextView.text = @"请输入内容(1000字以内)";
    _noteTextView.layer.shadowColor = [UIColor clearColor].CGColor;

    [_scrollView addSubview:self.inputTitle];
    [_scrollView addSubview:line];
    [_scrollView addSubview:_noteTextView];
    [_scrollView addSubview:_placeLabel];
    [self.view addSubview:_scrollView];
    
    [self updateViewsFrame];
}

- (void)viewTapped{
    [self.view endEditing:YES];
}

- (void)updateViewsFrame{
    
    if (!allViewHeight) {
        allViewHeight = 0;
    }
    if (!noteTextHeight) {
        noteTextHeight = ScreenHeight - _inputTitle.frame.origin.y-_inputTitle.bounds.size.height - 40 - 90;
    }
    if (!titleTextHeight) {
        titleTextHeight = 36;
    }
    
    _inputTitle.frame = CGRectMake(20, 10, ScreenWidth-40, titleTextHeight);
    _placeLabel.frame = CGRectMake(_inputTitle.frame.origin.x+3,
                                   _inputTitle.frame.origin.y+5,
                                   _placeLabel.frame.size.width,
                                   _placeLabel.frame.size.height);
    _lineLable.frame = CGRectMake(25,
                                  _inputTitle.frame.origin.y+_inputTitle.bounds.size.height+20,
                                  ScreenWidth-50,
                                  0.5);
    _noteTextView.frame = CGRectMake(20,
                                     self.inputTitle.frame.origin.y+_inputTitle.bounds.size.height+40,
                                     ScreenWidth - 40,
                                     noteTextHeight);
    [_noteTextView setScrollEnabled:NO];
    
    allViewHeight =_noteTextView.frame.origin.y + noteTextHeight + self.keyboardHeight ;

    self.scrollView.contentSize = CGSizeMake(0,allViewHeight);
    
    if (self.isContentBeginEditing){
        CGFloat offset =  self.cursorPositionY + self.noteTextView.frame.origin.y;
        CGFloat offs =  offset -(ScreenHeight-self.keyboardHeight-49);
        if (offset > ScreenHeight-self.keyboardHeight-49 && offs > self.scrollView.contentOffset.y) {
            [self.scrollView setContentOffset:CGPointMake(0,offs) animated:YES];
        }
    }
}
#pragma mark -- UITextViewTextDidChangeNotification
-(void)inputTitleTextViewEditChanged:(NSNotification *)obj{
    UITextView *textView = (UITextView *)obj.object;
    NSString *lang = self.textInputMode.primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {//如果是简体中文输入，要忽略输入中拼音的长度
        UITextRange *selectedRange = [textView markedTextRange];
        if (!selectedRange) {
            if (textView.attributedText != nil && textView.attributedText.length >= 50) {
                NSAttributedString* aString = [self attributedStringSubFromRangeWithString:textView.attributedText andRange:NSMakeRange(0, 50)];
                [self.inputTitle setAttributedText:aString];
            }
        }else{
            
        }
    }else{
        if(textView.attributedText != nil && textView.attributedText.length >= 50) {
            NSAttributedString* aString = [self attributedStringSubFromRangeWithString:textView.attributedText andRange:NSMakeRange(0, 50)];
            [self.inputTitle setAttributedText:aString];
        }
    }
    [self.toolView.textNumLabel setText:[NSString stringWithFormat:@"%lu/50",self.inputTitle.attributedText.length]];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    [self.inputTitle.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.inputTitle.attributedText.length)];

    CGRect orgRect = self.inputTitle.frame;
    CGSize size = [self.inputTitle sizeThatFits:CGSizeMake(self.inputTitle.frame.size.width, MAXFLOAT)];
    if (size.height > 36) {
        orgRect.size.height = size.height;
        titleTextHeight = size.height;
        [self updateViewsFrame];
    }
}

-(void)textViewEditChanged:(NSNotification*)obj{
    UITextView *textView = (UITextView *)obj.object;
    self.cursorPositionY = [textView caretRectForPosition:textView.selectedTextRange.start].origin.y;
    NSString *lang = self.textInputMode.primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {//如果是简体中文输入，要忽略输入中拼音的长度
        UITextRange *selectedRange = [textView markedTextRange];
        if (!selectedRange) {
            if (textView.attributedText != nil && textView.attributedText.length >= 1000) {
                NSAttributedString* aString = [self attributedStringSubFromRangeWithString:textView.attributedText andRange:NSMakeRange(0, 1000)];
                [self.noteTextView setAttributedText:aString];
            }
        }else{
            
        }
    }else{
        if(textView.attributedText != nil && textView.attributedText.length >= 1000) {
            NSAttributedString* aString = [self attributedStringSubFromRangeWithString:textView.attributedText andRange:NSMakeRange(0, 1000)];
            [self.noteTextView setAttributedText:aString];
        }
    }
    
    [self.toolView.textNumLabel setText:[NSString stringWithFormat:@"%lu/1000",self.noteTextView.attributedText.length]];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    [self.noteTextView.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.noteTextView.attributedText.length)];
    [self textChanged];
}

#pragma mark -- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView == self.inputTitle) {
        self.isContentBeginEditing = NO;
        [self.toolView showOrHidenSelectImageBtn:YES];
        [self.toolView.textNumLabel setText:[NSString stringWithFormat:@"%lu/50",self.inputTitle.attributedText.length]];
        if ([textView.text isEqualToString:@""]) {
            _placeLabel.text = @" ";
        }else{
            _placeLabel.text = @"";
        }
        return YES;
    }else{
        self.isContentBeginEditing = YES;
        [self.toolView showOrHidenSelectImageBtn:NO];

        if (textView.attributedText != nil && textView.attributedText.length >= 1000) {
            NSAttributedString* aString = [self attributedStringSubFromRangeWithString:textView.attributedText andRange:NSMakeRange(0, 1000)];
            [self.noteTextView setAttributedText:aString];
        }
        [self.toolView.textNumLabel setText:[NSString stringWithFormat:@"%lu/1000",self.noteTextView.attributedText.length]];
        if ([textView.text isEqualToString:@"请输入内容(1000字以内)"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
            [self.toolView.textNumLabel setText:@"0/1000"];
        }
        
        return YES;
    }
    
}

-(NSAttributedString*)attributedStringSubFromRangeWithString:(NSAttributedString*)aString andRange:(NSRange)range{
    
    NSAttributedString* content = aString;
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:content];
    NSAttributedString* subStr = [attributedString attributedSubstringFromRange:range];
    return subStr;
}

-(NSMutableAttributedString*)stringAddLineSpacingAndFontAttributeName:(NSString*)string andLineSpacing:(CGFloat)lineSpacing andFontAttributeName:(UIFont*)font{
    
    NSMutableAttributedString * att = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    [att addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [att length])];
    [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [att length])];
    return att;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView == self.noteTextView) {
        if (textView.text == nil || textView.text.length == 0) {
            textView.text = @"请输入内容(1000字以内)";
            textView.textColor = COLOR_153;
        }
        if (noteTextHeight < ScreenHeight - _inputTitle.frame.origin.y-_inputTitle.frame.size.height - 40 - 90) {
            
            noteTextHeight = ScreenHeight - _inputTitle.frame.origin.y-_inputTitle.frame.size.height - 40 - 90;
            
            [self updateViewsFrame];
        }
        
    }else if (textView == self.inputTitle){
        if (textView.text.length == 0) {
            _placeLabel.text = @"请输入标题(50字以内)";
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView == self.inputTitle) {
        if ([text isEqualToString:@"\n"] ) {
            if ([textView.text isEqualToString:@""] || textView.text== nil) {
                _placeLabel.text = @"请输入标题(50字以内)";
            }
            [textView resignFirstResponder];
            return NO;
        }else if (textView.text.length == 1 && [text isEqualToString:@""]){
            _placeLabel.text = @"请输入标题(50字以内)";
            return YES;
        }else if (textView.text.length == 0 && text.length > 0){
            _placeLabel.text = @"";
            return YES;
        }
        if (range.location == 0 && [text isEqualToString:@" "]) {
            return NO;
        }
        return YES;
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.cursorPositionY = [textView caretRectForPosition:textView.selectedTextRange.start].origin.y;
            [self textChanged];
        });
        return YES;
    }
}

-(void)textChanged{
    
    CGRect orgRect = self.noteTextView.frame;
    CGSize size = [self.noteTextView sizeThatFits:CGSizeMake(self.noteTextView.frame.size.width, MAXFLOAT)];
    orgRect.size.height=size.height;
    noteTextHeight = orgRect.size.height;
    [self updateViewsFrame];
   
}

-(void)showAlert:(NSString*)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
