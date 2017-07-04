//
//  ISIDReaderResultViewController.m
//  ISIDReaderPreview
//
//  Created by 汪凯 on 15/11/13.
//  Copyright © 2015年 汪凯. All rights reserved.
//

#import "ISIDReaderResultViewController.h"
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kScreenB [UIScreen mainScreen].bounds

#import "KVNProgress.h"
#import "RxWebViewController.h"
#import "ZYKeyboardUtil.h"


@interface ISIDReaderResultViewController () <UITextViewDelegate,UITextFieldDelegate>{
    UIView *wbackview;
    UIView *lineView2;
    UIScrollView *scrollView;
}
@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UIImageView *originImageView; //图片

//正面
@property (strong, nonatomic)  UILabel *nameLabel;          //姓名
@property (strong, nonatomic)  UILabel *idNumberLabel;     //身份证号
@property (strong, nonatomic)  UILabel *addressLabel;      //地址

@property (strong, nonatomic)  UITextField *nameText;          //姓名Text
@property (strong, nonatomic)  UITextField *idNumberText;     //身份证号Text
@property (strong, nonatomic)  UITextView *addressText;      //地址Text


//反面
@property (strong, nonatomic)  UILabel *issuingAuthorityLabel;//签发机关
@property (strong, nonatomic)  UILabel *validDateLabel;       //有效期限
@property (strong, nonatomic)  UITextField *issuingAuthorityText;
@property (strong, nonatomic)  UITextField *validDateText;

@property (strong, nonatomic)  UIButton *comfiBtn;

@property (strong, nonatomic) UIImage *originImage;
@property (strong, nonatomic) NSDictionary *infoDic;

@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;

@end

@implementation ISIDReaderResultViewController

- (instancetype)initWithDictionary:(NSDictionary *)info
{
    self = [super init];
    if (self != nil) {
        self.originImage = [info valueForKey:kOpenSDKCardResultTypeOriginImage];
        self.infoDic = [info valueForKey:kOpenSDKCardResultTypeCardItemInfo];
    }
    return self;
}

- (IBAction)okbuttonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.title = @"身份证信息校对";
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
    self.originImageView.image = self.originImage;
    [self configKeyBoardRespond];
    [self judgeLegal];
  }

//判断识别合法性
-(void)judgeLegal{

//    if ([self.positivePic isEqualToString:@"1"]) {
//        NSString *temp = [self.infoDic objectForKey:@"kCardItem7"];
//        if (temp.length == 0&&) {
//            alertview = [[UIAlertView alloc] initWithTitle:@"标题" message:@"信息不能为空，请重新扫描" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
//            [alertview show];
//            alertview.delegate = self;
//        }
//    }else{
//        NSString *temp = [self.infoDic objectForKey:@"kCardItem4"];
//        if (temp.length == 0) {
//            
//                alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"信息不能为空，请重新扫描" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
//                [alertview show];
//            
//        }
//    }
    
    if ([self.positivePic isEqualToString:@"1"]) {
        NSString *iddate = [self.infoDic objectForKey:@"kCardItem7"];
        NSString *policeorg = [self.infoDic objectForKey:@"kCardItem15"];
        if (iddate.length ==0 && policeorg.length==0) {
            [KVNProgress showErrorWithStatus:@"请使用身份证反面重新扫描!"];
        }
    }else{
        NSString *idno = [self.infoDic objectForKey:@"kCardItem0"];
         NSString *custname = [self.infoDic objectForKey:@"kCardItem1"];
         NSString *ethnicname = [self.infoDic objectForKey:@"kCardItem3"];
         NSString *sex = [self.infoDic objectForKey:@"kCardItem2"];
        if (idno.length == 0&& custname.length==0&& ethnicname.length==0&& sex.length==0){
             [KVNProgress showErrorWithStatus:@"请使用身份证正面重新扫描!"];
        }
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupUI{
    scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:scrollView];
    self.originImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/1.8)];
    scrollView.backgroundColor = UIColorFromHex(0xEBEBF1);
    [scrollView addSubview:self.originImageView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.originImageView.frame.size.height, 250, 30)];
    self.titleLabel.text = @"请修改身份信息与证件一致";
    self.titleLabel.font = [UIFont systemFontOfSize:17.0];
    self.titleLabel.textColor = UIColorFromHex(0x7b7b7b);
    [scrollView addSubview:self.titleLabel];
    
    if ([self.positivePic isEqualToString:@"1"]) {//反面
        wbackview = [[UIView alloc]initWithFrame:CGRectMake(0, self.originImageView.frame.size.height+self.titleLabel.frame.size.height, self.view.frame.size.width, 80)];
        [scrollView addSubview:wbackview];
         wbackview.backgroundColor = UIColorFromHex(0xFFFFFF);
        //左边
        self.issuingAuthorityLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 40)];
        self.issuingAuthorityLabel.text = @"签发机关";
        self.issuingAuthorityLabel.font = [UIFont systemFontOfSize:17.0];
        self.issuingAuthorityLabel.textColor = UIColorFromHex(0x333333);
        [wbackview addSubview:self.issuingAuthorityLabel];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 39, self.view.frame.size.width, 1)];
        lineView.backgroundColor = UIColorFromHex(0xF7F7F7);
        [wbackview addSubview:lineView];
        
        
        self.validDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 80, 40)];
        self.validDateLabel.text = @"有效期限";
        self.validDateLabel.font = [UIFont systemFontOfSize:17.0];
        self.validDateLabel.textColor = UIColorFromHex(0x333333);
        [wbackview addSubview:self.validDateLabel];
        
        
        //右边
        self.issuingAuthorityText = [[UITextField alloc]initWithFrame:CGRectMake(100, 0, 250, 40)];
        self.issuingAuthorityText.textColor = [UIColor blackColor];
        self.issuingAuthorityText.textAlignment = NSTextAlignmentLeft;
        self.issuingAuthorityText.font = [UIFont systemFontOfSize:17.0];
        [wbackview addSubview:self.issuingAuthorityText];
        NSString *issuingAuthority = [self.infoDic valueForKey:kCardItemIssueAuthority];
        if (issuingAuthority == nil) {
            issuingAuthority = @"";
        }
        self.issuingAuthorityText.text = issuingAuthority;
        self.issuingAuthorityText.returnKeyType =UIReturnKeyDone;
        self.issuingAuthorityText.delegate = self;
        
        
        
        self.validDateText = [[UITextField alloc]initWithFrame:CGRectMake(100, 40, 250, 40)];
        self.validDateText.textColor = [UIColor blackColor];
        self.validDateText.font = [UIFont systemFontOfSize:17.0];
        self.validDateText.textAlignment = NSTextAlignmentLeft;
        [wbackview addSubview:self.validDateText];
        NSString *validDate = [self.infoDic valueForKey:kCardItemValidity];
        if (validDate == nil) {
            validDate = @"";
        }
        self.validDateText.text = validDate;
        self.validDateText.tag =10087;
        self.validDateText.returnKeyType =UIReturnKeyDone;
        self.validDateText.delegate = self;
        
    }else{
       wbackview = [[UIView alloc]initWithFrame:CGRectMake(0, self.originImageView.frame.size.height+self.titleLabel.frame.size.height, self.view.frame.size.width, 150)];
        [scrollView addSubview:wbackview];
         wbackview.backgroundColor = UIColorFromHex(0xFFFFFF);
        //左边
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, 40)];
        self.nameLabel.text = @"姓名";
        self.nameLabel.font = [UIFont systemFontOfSize:17.0];
        self.nameLabel.textColor = UIColorFromHex(0x333333);
        [wbackview addSubview:self.nameLabel];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 39, self.view.frame.size.width, 1)];
        lineView.backgroundColor =  UIColorFromHex(0xF7F7F7);
        [wbackview addSubview:lineView];
        
        
        self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 60, 40)];
        self.addressLabel.text = @"住址";
        self.addressLabel.font = [UIFont systemFontOfSize:17.0];
        self.addressLabel.textColor = UIColorFromHex(0x333333);
        [wbackview addSubview:self.addressLabel];
        
        //@"住址";
        NSString *address = [self.infoDic valueForKey:kCardItemAddress];
        if (address == nil) {
            address = @"";
        }
        //行高
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:17.0],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
//
        self.addressText = [[UITextView alloc]initWithFrame:CGRectMake(65, 40, self.view.frame.size.width-self.addressLabel.frame.size.width-15, 40)];
        self.addressText.font = [UIFont systemFontOfSize:17.0];
        self.addressText.textAlignment = NSTextAlignmentLeft;
        self.addressText.attributedText = [[NSAttributedString alloc] initWithString:address attributes:attributes];
        self.addressText.scrollEnabled = NO;
        self.addressText.frame = CGRectMake(65, 40, self.view.frame.size.width-self.addressLabel.frame.size.width-15, [self heightForString: self.addressText andWidth:self.view.frame.size.width-self.addressLabel.frame.size.width-15]);
        [wbackview addSubview:self.addressText];
        self.addressText.textColor = [UIColor blackColor];
        
        self.addressText.returnKeyType =UIReturnKeyDone;
        self.addressText.delegate = self;
        lineView2 = [[UIView alloc]initWithFrame:CGRectMake(10, self.addressText.frame.origin.y+self.addressText.frame.size.height, self.view.frame.size.width, 1)];
        lineView2.backgroundColor =  UIColorFromHex(0xF7F7F7);
        [wbackview addSubview:lineView2];

        
        
        self.idNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, lineView2.frame.origin.y, 60, 40)];
        self.idNumberLabel.text = @"号码";
        self.idNumberLabel.font = [UIFont systemFontOfSize:17.0];
        self.idNumberLabel.textColor = UIColorFromHex(0x333333);
        [wbackview addSubview:self.idNumberLabel];
        
    
        
         //右边
        self.nameText = [[UITextField alloc]initWithFrame:CGRectMake(70, 0, 250, 40)];
        self.nameText.textColor = [UIColor blackColor];
        self.nameText.font = [UIFont systemFontOfSize:17.0];
        [wbackview addSubview:self.nameText];
        NSString *nameString = [self.infoDic valueForKey:kCardItemName];
        if (nameString == nil) {
            nameString = @"";
        }
        self.nameText.text = nameString;
        self.nameText.returnKeyType =UIReturnKeyDone;
        self.nameText.delegate = self;
        
        
        self.idNumberText = [[UITextField alloc]initWithFrame:CGRectMake(70, self.idNumberLabel.frame.origin.y, 250, 40)];
        self.idNumberText.textColor = [UIColor blackColor];
        self.idNumberText.font = [UIFont systemFontOfSize:17.0];
        [wbackview addSubview:self.idNumberText];
        NSString *idNumber = [self formatCardNum:[self.infoDic valueForKey:kCardItemIDNumber]];
        if (idNumber == nil) {
            idNumber = @"";
        }
        self.idNumberText.text = idNumber;
        self.idNumberText.keyboardType = UIKeyboardTypeNumberPad;
        self.idNumberText.returnKeyType =UIReturnKeyDone;
        self.idNumberText.delegate = self;
        self.idNumberText.tag = 10086;
        wbackview.frame =CGRectMake(0, self.originImageView.frame.size.height+self.titleLabel.frame.size.height, self.view.frame.size.width, self.idNumberLabel.frame.origin.y+40);

    }
    
    self.comfiBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, wbackview.frame.origin.y+wbackview.frame.size.height+20, self.view.frame.size.width-20, 50)];
    [self.comfiBtn setBackgroundImage:[self imageWithColor:UIColorFromHex(0x2287d6)] forState:UIControlStateNormal];
    [self.comfiBtn setBackgroundImage:[self imageWithColor:UIColorFromHex(0x1b6cab)] forState:UIControlStateHighlighted];
    //关键语句
    [self.comfiBtn.layer setMasksToBounds:YES];
    self.comfiBtn.layer.cornerRadius = 5.0;//2.0是圆角的弧度，根据需求自己更改
    [self.comfiBtn setTitle:@"核对无误" forState:UIControlStateNormal];
    self.comfiBtn.titleLabel.textColor = UIColorFromHex(0x76a7cd);
    self.comfiBtn.titleLabel.font =[UIFont systemFontOfSize:17.0];
    [self.comfiBtn addTarget:self action:@selector(comfirm) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.comfiBtn];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, self.comfiBtn.frame.origin.y+110)];
}

//  颜色转换为背景图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(void)comfirm{
    UIImage *originImage = self.originImage;
     NSData *imagedata = [self compressImageWith:originImage width:540*1.3 height:540];
    NSString * base64String = [imagedata base64EncodedStringWithOptions:0];
    NSMutableDictionary *infoDic2 = [self changeDict:self.infoDic type:self.positivePic];
    if (infoDic2.count >0) {
        NSString * getImageByOCR = [NSString stringWithFormat:@"getImageByOCR(\"%@\",\"%@\",\"%@\")",base64String ,self.positivePic, [self DataTOjsonString:infoDic2]];
        getImageByOCR = [getImageByOCR stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageByOCR" object:getImageByOCR userInfo:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}

//移除通知
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    return [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\'"];
}

- (NSData *)compressImageWith:(UIImage *)image width:(float)width height:(float)height
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , height)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return UIImageJPEGRepresentation(newImage, 0.7);
}

-(NSMutableDictionary *)changeDict:(NSDictionary*)dict type:(NSString *)type
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc]init];
    if ([type isEqualToString:@"1"]) {
        if (self.issuingAuthorityText.text.length==0||self.validDateText.text.length==0) {
            [KVNProgress showErrorWithStatus:@"身份证信息不能为空!"];
            return nil;
        }
//        NSString *temp = [dict objectForKey:@"kCardItem7"];
//        if (temp.length >0) {
            [infoDict setObject:self.validDateText.text forKey:@"iddate"];
            [infoDict setObject:self.issuingAuthorityText.text forKey:@"policeorg"];
//        }
    }else{
        if (self.nameText.text.length==0||self.idNumberText.text.length==0||self.addressText.text.length==0) {
            [KVNProgress showErrorWithStatus:@"身份证信息不能为空!"];
            return nil;
        }
//        NSString *temp = [dict objectForKey:@"kCardItem4"];
//        if (temp.length >0) {
            [infoDict setObject:[dict objectForKey:@"kCardItem4"] forKey:@"birthday"];
            [infoDict setObject:[dict objectForKey:@"kCardItem2"] forKey:@"sex"];
            [infoDict setObject:[self.idNumberText.text  stringByReplacingOccurrencesOfString: @" " withString: @""] forKey:@"idno"];
            [infoDict setObject:self.addressText.text forKey:@"native"];
            [infoDict setObject:[dict objectForKey:@"kCardItem3"] forKey:@"ethnicname"];
            [infoDict setObject:self.nameText.text forKey:@"custname"];
//        }
    }
    return infoDict;
}


- (void)configKeyBoardRespond {
    self.keyboardUtil = [[ZYKeyboardUtil alloc] initWithKeyboardTopMargin:10];
    __weak ISIDReaderResultViewController *weakSelf = self;
#pragma explain - 全自动键盘弹出/收起处理 (需调用keyboardUtil 的 adaptiveViewHandleWithController:adaptiveView:)
#pragma explain - use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearAutomaticAnimBlock will be invalid.
    [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        if ([weakSelf.positivePic isEqualToString:@"0"]) {
            [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.nameText, weakSelf.addressText, weakSelf.idNumberText, nil];
        }else{
             [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.issuingAuthorityText, weakSelf.validDateText,  nil];
        }
        
    }];
    /*  or
     [_keyboardUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
     [keyboardUtil adaptiveViewHandleWithAdaptiveView:weakSelf.inputViewBorderView, weakSelf.secondTextField, weakSelf.thirdTextField, nil];
     }];
     */
    
#pragma explain - 自定义键盘弹出处理(如配置，全自动键盘处理则失效)
#pragma explain - use animateWhenKeyboardAppearAutomaticAnimBlock, animateWhenKeyboardAppearBlock must be nil.
    /*
     [_keyboardUtil setAnimateWhenKeyboardAppearBlock:^(int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement) {
     NSLog(@"\n\n键盘弹出来第 %d 次了~  高度比上一次增加了%0.f  当前高度是:%0.f"  , appearPostIndex, keyboardHeightIncrement, keyboardHeight);
     //do something
     }];
     */
    
#pragma explain - 自定义键盘收起处理(如不配置，则默认启动自动收起处理)
#pragma explain - if not configure this Block, automatically itself.
    /*
     [_keyboardUtil setAnimateWhenKeyboardDisappearBlock:^(CGFloat keyboardHeight) {
     NSLog(@"\n\n键盘在收起来~  上次高度为:+%f", keyboardHeight);
     //do something
     }];
     */
    
#pragma explain - 获取键盘信息
    [_keyboardUtil setPrintKeyboardInfoBlock:^(ZYKeyboardUtil *keyboardUtil, KeyboardInfo *keyboardInfo) {
        NSLog(@"\n\n拿到键盘信息 和 ZYKeyboardUtil对象");
    }];
}

/**
 @method 获取指定宽度width,字体大小fontSize,字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float) heightForString:(UITextView *)value andWidth:(float)width{
    CGSize sizeToFit = [value sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (NSString*)formatCardNum:(NSString *)value {
    if (value.length == 18) {
        NSString *a = [value substringWithRange:NSMakeRange(0, 3)];
        NSString *b = [value substringWithRange:NSMakeRange(3, 3)];
        NSString *c = [value substringWithRange:NSMakeRange(6, 4)];
        NSString *d = [value substringWithRange:NSMakeRange(10, 4)];
        NSString *e = [value substringWithRange:NSMakeRange(14, 4)];
        value = [[NSString alloc]initWithFormat:@"%@ %@ %@ %@ %@",a,b,c,d,e];
    }
    
    return value;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == 10086 || textField.tag == 10087) {

        if (range.location>= 22)
            return NO;
    }
    
    return YES;
    
}

//当textViewField输入自动适配高度
-(void)textViewDidChange:(UITextView *)textView {
    [self textViewChange:textView];
}

-(void)textViewChange:(UITextView *)textView{
    //获得textView的初始尺寸
    //获得textView的初始尺寸
    CGFloat width = CGRectGetWidth(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width,MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(self.view.frame.size.width-self.addressLabel.frame.size.width-15, newSize.height);
    textView.frame = newFrame;
    [UIView animateWithDuration:1 animations:^{
        
        lineView2.frame = CGRectMake(10, textView.frame.origin.y+textView.frame.size.height, self.view.frame.size.width, 1);
        self.idNumberLabel.frame =CGRectMake(10, lineView2.frame.origin.y, 60, 40);
        self.idNumberText.frame = CGRectMake(70, self.idNumberLabel.frame.origin.y, 250, 40);
        wbackview.frame =CGRectMake(0, self.originImageView.frame.size.height+self.titleLabel.frame.size.height, self.view.frame.size.width, self.idNumberLabel.frame.origin.y+40);
        self.comfiBtn.frame = CGRectMake(10, wbackview.frame.origin.y+wbackview.frame.size.height+20, self.view.frame.size.width-20, 50);
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, self.comfiBtn.frame.origin.y+110)];
        
    }];
}

@end
