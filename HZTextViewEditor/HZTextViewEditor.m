//
//  HZTextViewEditor.m
//  JinRongArticle
//
//  Created by 邢现庆 on 16/8/15.
//  Copyright © 2016年 91JinRong. All rights reserved.
//

#import "HZTextViewEditor.h"

#define ImgMaxCount  20
#define FontSize     16.0f

@implementation HZTextViewEditor

-(instancetype)init{
    self = [super init];
    if (self) {
        _selectCount = 0;
        _bigImageDataArray = [NSMutableArray array];
    }
    return self;
}

//获取当前显示的vc
+ (UIViewController *)getCurrentViewController{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

-(UIViewController*)getParentViewController{
    if (!_parentVC) {
        _parentVC = [HZTextViewEditor getCurrentViewController];
        if (!_parentVC) {
            NSLog(@"_parentVC is nil");
        }
    }
    return _parentVC;
}

- (void)resetTextStyle {
    NSRange wholeRange = NSMakeRange(0, self.textStorage.length);
    
    [self.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    
    [self.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSize] range:wholeRange];
}
//选图方式选择
- (void)pickButtonClicked{
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"图库",@"相册", nil];
    [chooseImageSheet showInView:[self getParentViewController].view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    switch (buttonIndex) {
        case 0://Take picture
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
            }else{
                NSLog(@"模拟器无法打开相机");
            }
            break;
            
        case 1://From album
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        default:
            
            return;//没有选择结果
    }
    [[self getParentViewController] presentModalViewController:picker animated:YES];
}

//直接进入图库选图
- (void)pickImageFromLibraryClicked{
    if (![self checkImageCount]) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[self getParentViewController] presentModalViewController:picker animated:YES];
}

//图片缩放   按照比例
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//图片缩放到指定宽度
-(UIImage *)scaleImage:(UIImage *)image toWidth:(float)width{
    CGFloat height  = image.size.height;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,(width/image.size.width)*height), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, width, (width/image.size.width)*height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//检查已有图片的数量
-(BOOL)checkImageCount{
    NSUInteger imageCount = self.bigImageDataArray.count >= ImgMaxCount ? [self getEditorImagecount] : 0;
    
    if (imageCount >= ImgMaxCount) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"图片已经达到限制数量"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    return YES;
}

//将image转成data
-(NSData*)getImageDataByImage:(UIImage*)image{
    
    return UIImageJPEGRepresentation(image, 1);
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([self.text isEqualToString:@"请输入内容(1000字以内)"]) {
        [self setAttributedText:[[NSAttributedString alloc]init]];
    }
    
    UIImage* originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self insertImage:originImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self becomeFirstResponder];

}


//压缩图片
- (NSData *)compressImage:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio{
    
    int MAX_UPLOAD_SIZE = 50;
    CGFloat compression = ratio;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);

    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxRatio) {
        compression -= 0.10;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

//插入图片
-(void)insertImage:(UIImage*)originImage{
    
    [self setScrollEnabled:YES];
    
    UIImage *bigImage = originImage;

    if (originImage.size.width > 800) {
        bigImage = [self scaleImage:originImage toWidth:800];
    }
    
    NSData* compressData = [self compressImage:bigImage compressRatio:0.5 maxCompressRatio:0.4];
    [self.bigImageDataArray addObject:compressData];
    

    UIImage * compressImage = [UIImage imageWithData:compressData];
    [self insertTextAttachmentByImage:compressImage andImageTag:self.selectCount andRange:self.selectedRange andIsDeleteCharacters:NO];
        
    self.selectedRange = NSMakeRange(self.selectedRange.location + 1, self.selectedRange.length);
    
    [self resetTextStyle];
    [self.editorDelagte updateUIFrame];
    
    self.selectCount++;
}


//插入图片
-(void)insertTextAttachmentByImage:(UIImage*)originImage andImageTag:(NSInteger)imageTag andRange:(NSRange)range andIsDeleteCharacters:(BOOL)isDelete{
    
    float scale = (self.bounds.size.width-10)/originImage.size.width;
//    scale = scale > 1.0 ? 1.0 : scale;//如果放开这行代码，小于屏幕宽度的图片会显示原图
    UIImage *scaleImage = [self scaleImage:originImage toScale:scale];

    CGRect rect = CGRectMake(0, 0, self.frame.size.width-10, scaleImage.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect( currentContext, rect);
    CGRect rect2 = CGRectMake((rect.size.width - scaleImage.size.width)/2, 0, scaleImage.size.width, rect.size.height);
    [scaleImage drawInRect:rect2];
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    HZTextAttachment *textAttachment = [[HZTextAttachment alloc]init];
    textAttachment.image = cropped;
    textAttachment.imageTag = imageTag;
    
    [self.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]
                                                  atIndex:range.location];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    [self.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.attributedText.length)];
    if (isDelete) {
        //删除占位符
        [self.textStorage deleteCharactersInRange:NSMakeRange(range.location+1, range.length)];
    }
}

//更新imageData
-(void)updateBigImageDataArray:(NSArray*)imageArray{
    
    self.bigImageDataArray = [NSMutableArray array];
    for (int i = 0; i < imageArray.count; i++) {
        UIImage* image = imageArray[i];
        [self.bigImageDataArray addObject:[self getImageDataByImage:image]];
    }
    self.selectCount = self.bigImageDataArray.count;
    
}

//获取数据
-(NSDictionary*)getContentData{
    self.imageIndex = 1;
    self.commitImageDataArray = [NSMutableArray array];
    self.textString = [NSMutableString string];
    NSMutableDictionary *contentDic = nil;
    if(self.attributedText){
        contentDic = [NSMutableDictionary dictionary];
        NSRange sRange = NSMakeRange(0,self.attributedText.length);
        [self.attributedText enumerateAttributesInRange:sRange
                                                options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                             usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop){
            if (attrs[@"NSAttachment"]) {
                HZTextAttachment* at =attrs[@"NSAttachment"];
                NSData* imageData = self.bigImageDataArray[at.imageTag];
                [self.commitImageDataArray addObject:imageData];
                [self.textString appendString:[NSString stringWithFormat:@"[IMG#%ld]",self.imageIndex]];
                self.imageIndex++;
            }else{
                [self.textString appendString:[self.attributedText.string substringWithRange:range]];
            };
        }];
        [contentDic setObject:self.commitImageDataArray forKey:@"images"];
        [contentDic setObject:self.textString forKey:@"text"];
    }
    return contentDic;
}
//获取已有图片的数量
-(NSUInteger)getEditorImagecount{
    NSMutableArray* array = [NSMutableArray array];
    if(self.attributedText){
        NSRange sRange = NSMakeRange(0,self.attributedText.length);
        [self.attributedText enumerateAttributesInRange:sRange
                                                options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                             usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop){
            if (attrs[@"NSAttachment"]) {
                HZTextAttachment* at =attrs[@"NSAttachment"];
                NSData* imageData = self.bigImageDataArray[at.imageTag];
                [array addObject:imageData];
            }else{
                NSLog(@"is text:%@",[self.attributedText.string substringWithRange:range]);
            };
        }];
    }
    return array.count;
}
//获取所有图片的rect
-(NSArray*)getImageRectArray{
    NSMutableArray* array = [NSMutableArray array];
    if(self.attributedText){
        NSRange sRange = NSMakeRange(0,self.attributedText.length);
        [self.attributedText enumerateAttributesInRange:sRange
                                                options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                             usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop){
                                                 if (attrs[@"NSAttachment"]) {
                                                     self.selectedRange = range;
                                                     NSValue* rectValue = [[self selectionRectsForRange:self.selectedTextRange] firstObject];
                                                     [array addObject:rectValue];
                                                     self.selectedRange = NSMakeRange(0, 0);
                                                 }else{
                                                     NSLog(@"is text:%@",[self.attributedText.string substringWithRange:range]);
                                                 };
                                             }];
    }
    return array;
}

//touch
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.editable) {
        return ;
    }
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    NSArray* array = [self getImageRectArray];
    
    if (array == nil || array.count == 0) {
        return;
    }
    for (int i = 0; i < array.count; i++) {
        UITextSelectionRect * tRect = array[i];
        if (CGRectContainsPoint(tRect.rect,point)) {
            //如果点击到了图片会触发
            [self.editorDelagte touched:self andIndex:i];
        }
    }
}
@end
