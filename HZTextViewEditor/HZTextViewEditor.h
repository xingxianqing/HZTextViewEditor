//
//  HZTextViewEditor.h
//  JinRongArticle
//
//  Created by 邢现庆 on 16/8/15.
//  Copyright © 2016年 91JinRong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZTextAttachment.h"


@class HZTextViewEditor;

@protocol HZTextViewEditorDelegate <NSObject>

@optional
//选择完 图片后调用，对页面UI进行刷新
-(void)updateUIFrame;
/**
 *  点击的内容如果是图片  会触发
 *
 *  @param textViewEditor self
 *  @param index          被点击图片的下标 从0开始
 */
-(void)touched:(HZTextViewEditor*)textViewEditor andIndex:(NSUInteger)index;

@end


@interface HZTextViewEditor : UITextView <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property UIViewController *parentVC;

@property(nonatomic,weak)id<HZTextViewEditorDelegate>editorDelagte;

@property(nonatomic,assign)NSInteger selectCount;//选择的次数

@property(nonatomic,assign)NSInteger imageIndex;//图片占位  从1开始

@property(nonatomic,strong)NSMutableArray* bigImageDataArray;//选择过的图片的data数组，

@property(nonatomic,strong)NSMutableArray* commitImageDataArray;//编辑完成后获取到的data数组

@property(nonatomic,strong)NSMutableString* textString;//文本


//先选择图片来源方式
- (void)pickButtonClicked;

//直接进入图库选图
- (void)pickImageFromLibraryClicked;

/**
 *  获取内容
 *
 *  @return 返回字典格式 images:imageData数组， text：文本
 */
-(NSDictionary*)getContentData;

/**
 *  图片的缩放
 *
 *  @param image     图片
 *  @param scaleSize 比例
 *
 *  @return 返回缩放后的图片
 */
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/**
 *  更新imageData数组，做修改操作的时候会用到
 *
 *  @param imageArray 传入图片数组
 */
-(void)updateBigImageDataArray:(NSArray*)imageArray;

/**
 * 检查已经输入的图片个数
 *
 *  @return 返回值为 YES 的时候可以继续输入
 */
-(BOOL)checkImageCount;

/**
 *  插入图片，编辑的时候用，会将宽度大于800的图片缩到800，进行压缩
 *
 *  @param originImage 图片
 */
-(void)insertImage:(UIImage*)originImage;


/**
 *  插入图片，显示的时候用，不会进行压缩，只做显示处理
 *
 *  @param originImage 图片
 *  @param imageTag    tag
 *  @param range       range
 *  @param isDelete    是否要删除图片的占位符：[IMG#%ld]
 */

-(void)insertTextAttachmentByImage:(UIImage*)originImage andImageTag:(NSInteger)imageTag andRange:(NSRange)range andIsDeleteCharacters:(BOOL)isDelete;
@end

