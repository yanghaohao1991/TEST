//
//  ViewController.m
//  ISIDReaderPreview
//
//  Created by 汪凯 on 15/11/12.
//  Copyright © 2015年 汪凯. All rights reserved.
//

#import "CardViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ISIDReaderPreviewSDK/ISIDReaderPreviewSDK.h>
#import <ISOpenSDKFoundation/ISOpenSDKFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ISIDReaderResultViewController.h"


#define kMaxRange  120

#define BorderOriginY 60
#define BorderWidth 270
#define BorderHeight 428

#warning 针对iphone4及以下低配置机型，width和height需设置在1280x720及以下。
#define ImageFrameWidth 1280
#define ImageFrameHeight 720
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]


static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
@interface CardViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UILabel *tipTitle;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) CALayer *cardNumberLayer;
@property (nonatomic, strong) CALayer *cardBorderLayer;
@end

@implementation CardViewController{
    CGFloat scale1;
    CAShapeLayer *_maskWithHole;//预览界面覆盖的半透明层
    UIView *borderView;
    CGRect sRect;
    UIImageView *scanNetImageView;
    CABasicAnimation *scanNetAnimation;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ISIDCardReaderController sharedISOpenSDKController] destructResources];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拍摄身份证";
    // Do any additional setup after loading the view, typically from a nib.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(orientationDidChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        if (self.captureSession) {
            [self.captureSession stopRunning];
            self.captureSession = nil;
        }
    });
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.captureSession == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *appKey = @"ENFfa5J11JB02e6Nyf6NEKPT";
            //            NSString *appKey = nil;
            NSString *subAppkey = nil;//reserved for future use
            [[ISIDCardReaderController sharedISOpenSDKController] constructResourcesWithAppKey:appKey subAppkey:subAppkey finishHandler:^(ISOpenSDKStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status == ISOpenSDKStatusSuccess)
                    {
                        [self setupAVCapture];
                        [self setupBorderView];
                        [self setupOtherThings];
                        [self focus];
                        [self changeOrientation:self.positivePic];
                        if (![self.captureSession isRunning])
                        {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [self.captureSession startRunning];
                            });
//                            [self.captureSession startRunning];
                        }
                    }
                    else
                    {
                        NSLog(@"Authorize error: %ld", (long)status);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"SDK错误：%ld", (long)status] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                });
            }];
        });
    }
    else
    {
        [self scananimation];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
    [self changeOrientation:self.positivePic];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) focus
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        NSError *error =  nil;
        if([device lockForConfiguration:&error]){
            [device setFocusPointOfInterest:CGPointMake(.5f, .5f)];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    AVCaptureSession *session = [AVCaptureSession new];
    self.captureSession = session;
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( [self.captureSession canAddInput:deviceInput] )
        [self.captureSession addInput:deviceInput];
    
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want YUV, both CoreGraphics and OpenGL work well with 'YUV'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput])
    {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    //1920*1080 is the suggested size if it is supported by device.
#warning 针对iphone4及以下低配置机型，sessionPreset需设置在1280x720及以下，并且建议适用设备在iPhone4S以上。
    [session setSessionPreset:AVCaptureSessionPreset1280x720];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = ImageFrameWidth * screenWidth / ImageFrameHeight ;
    [self.previewLayer setFrame:CGRectMake(0, 0, screenWidth, height)];
    [rootLayer addSublayer:self.previewLayer];
}


//设置边框
- (void)scananimation
{
    if (scanNetImageView) {
        [scanNetImageView removeFromSuperview];
    }
    //设置扫描区域的动画效果
    CGFloat scanNetImageViewH = 241;
    CGFloat scanNetImageViewW = borderView.frame.size.width;
    scanNetImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_net"]];
    scanNetImageView.frame = CGRectMake(0, 0, scanNetImageViewW, scanNetImageViewH);
    scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath =@"transform.translation.y";
    scanNetAnimation.byValue = @(borderView.frame.size.height-241);
    scanNetAnimation.duration = 1.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [scanNetImageView.layer addAnimation:scanNetAnimation forKey:nil];
    [borderView addSubview:scanNetImageView];

}

//设置边框
- (void)setupScanView
{
    //设置扫描区域的四个角的边框
    CGFloat buttonWH = 16;
    UIButton *topLeft = [[UIButton alloc]initWithFrame:CGRectMake(0,0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"]forState:UIControlStateNormal];
    [borderView addSubview:topLeft];
    
    UIButton *topRight = [[UIButton alloc]initWithFrame:CGRectMake(borderView.frame.size.width - buttonWH,0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"]forState:UIControlStateNormal];
    [borderView addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc]initWithFrame:CGRectMake(0,borderView.frame.size.height-buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"]forState:UIControlStateNormal];
    [borderView addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc]initWithFrame:CGRectMake(borderView.frame.size.width-buttonWH,borderView.frame.size.height-buttonWH, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"]forState:UIControlStateNormal];
    [borderView addSubview:bottomRight];
     [self scananimation];
}


//设置边框
- (void)setupBorderView
{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    CGFloat width = size_screen.width;
    CGFloat height = size_screen.height;
    
    sRect = CGRectMake(30, 80, 260, 260*1.6);//以苹果5屏幕大小为模板设置sRect
    CGFloat fValue = 15.0;
    if (height == 480)
    {//苹果4屏幕上sRect
        sRect = CGRectMake(CGRectGetMinX(sRect), 70, 260,  260*1.3);
    }else if (height == 568){
        scale1 = width/320;
        sRect = CGRectMake(30, 80, CGRectGetWidth(sRect)*scale1, CGRectGetHeight(sRect)*scale1);
        fValue = 17.0;
    }else
    {//大屏幕在苹果5屏幕基础上等比例放大sRect
        scale1 = width/320;
        sRect = CGRectMake(CGRectGetMinX(sRect)*scale1, CGRectGetMinY(sRect)*scale1, CGRectGetWidth(sRect)*scale1, CGRectGetHeight(sRect)*scale1);
        fValue = 17.0;
    }
    borderView = [[UIView alloc] initWithFrame:sRect];
//    borderView.layer.borderColor = UIColorFromHex(0x00aeff).CGColor;
//    borderView.layer.borderWidth = 1.0f;
//    borderView.layer.masksToBounds = YES;
    [self setupScanView];
    self.borderView = borderView;
    [self.previewLayer addSublayer:borderView.layer];
    [self drawShapeLayer];
    [self setupTipTitle];
     UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(sRect.origin.x-15, 30, 40, 40)];
    [backBtn setImage:[UIImage imageNamed:@"navback"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    self.IDCardImage = [[UIImageView alloc]init];
    [self.view addSubview:self.IDCardImage];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupTipTitle
{
    CGPoint lup  = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMinY(sRect));
    CGPoint rup = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMaxY(sRect));
    //提示语
    self.tipTitle = [[UILabel alloc]initWithFrame:CGRectMake(lup.x-(rup.y-lup.y)/2+15, rup.y-(rup.y-lup.y)/2, rup.y-lup.y, 30)];
    self.tipTitle.numberOfLines = 0;
    self.tipTitle.font = [UIFont systemFontOfSize:14];
    self.tipTitle.textAlignment = NSTextAlignmentCenter;
    self.tipTitle.textColor = UIColorFromHex(0xeb594c);
    [self.view addSubview:self.tipTitle];
    self.tipTitle.transform=CGAffineTransformMakeRotation(M_PI/2);
    [self updateTitleLabel];
}

//重绘透明部分
- (void) drawShapeLayer
{
    //设置覆盖层
    _maskWithHole = [CAShapeLayer layer];
    
    // Both frames are defined in the same coordinate system
    CGRect biggerRect = self.view.bounds;
    CGFloat offset = 1.0f;
    if ([[UIScreen mainScreen] scale] >= 2) {
        offset = 0.5;
    }
    
    //设置检边视图层
    CGRect smallFrame;
    smallFrame  = borderView.frame;
    CGRect smallerRect = CGRectInset(smallFrame, -offset, -offset) ;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMaxY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(smallerRect), CGRectGetMinY(smallerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(smallerRect), CGRectGetMinY(smallerRect))];
    
    [_maskWithHole setPath:[maskPath CGPath]];
    [_maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [_maskWithHole setFillColor:[[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
    [self.view.layer addSublayer:_maskWithHole];
    [self.view.layer setMasksToBounds:YES];
    
}


- (void)setupOtherThings
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void) didTap:(UITapGestureRecognizer *) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateBegan)
    {
        [self focus];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CFRetain(sampleBuffer);
    CGFloat scale = ImageFrameHeight /self.previewLayer.frame.size.width;
    CGRect rect = CGRectMake(self.borderView.frame.origin.y * scale, (self.previewLayer.frame.size.width - CGRectGetMaxX(self.borderView.frame)) * scale, self.borderView.frame.size.height * scale, self.borderView.frame.size.width * scale);
    [[ISIDCardReaderController sharedISOpenSDKController] detectCardWithOutputSampleBuffer:sampleBuffer cardRect:rect detectCardFinishHandler:^(int result, NSArray *borderPointsArray) {
        if (result > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cardBorderLayer removeFromSuperlayer];
                self.cardBorderLayer = nil;
//                self.borderView.layer.borderWidth = 10.0f;
                [self drawBorderRectWithBorderPoints:borderPointsArray onCardBorderLayer:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.borderView.layer.borderWidth = 1.0f;
                [self.cardBorderLayer removeFromSuperlayer];
                self.cardBorderLayer = nil;
            });
        }
    } recognizeCardFinishHandler:^(NSDictionary *cardInfo) {
        NSDictionary *infoDic = [cardInfo valueForKey:kOpenSDKCardResultTypeCardItemInfo];
//        NSMutableDictionary *infoDic2 = [self changeDict:infoDic type:self.positivePic];
//        
//        NSLog(@"%@", [self DataTOjsonString:infoDic2]);
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        
//            if ([self.captureSession  isRunning]) {
//                [self.captureSession stopRunning];
//            }
//        });
        [self.captureSession stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
//            ISIDReaderResultViewController *vc = [[ISIDReaderResultViewController alloc] initWithDictionary:cardInfo];
//            [self presentViewController:vc animated:YES completion:^{
//                
//            }];
            
//            UIImage *originImage = [cardInfo valueForKey:kOpenSDKCardResultTypeOriginImage];
//             NSData *originData = UIImageJPEGRepresentation(originImage, 1);
//            NSString * base64String = [originData base64EncodedStringWithOptions:0];
//            NSString * getImageByOCR = [NSString stringWithFormat:@"getImageByOCR(\"%@\",\"%@\",\"%@\")",base64String ,self.positivePic, [self DataTOjsonString:infoDic2]];
//            getImageByOCR = [getImageByOCR stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
//            [self dismissViewControllerAnimated:YES completion:^{
//                [self.webView stringByEvaluatingJavaScriptFromString:getImageByOCR];
//                
//            }];
            ISIDReaderResultViewController *vc = [[ISIDReaderResultViewController alloc] initWithDictionary:cardInfo];
            vc.positivePic = self.positivePic;
            vc.webView = self.webView;
            UIBarButtonItem *backIetm = [[UIBarButtonItem alloc] init];
            backIetm.title =@"返回";
            self.navigationItem.backBarButtonItem = backIetm;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    CFRelease(sampleBuffer);
}


-(NSMutableDictionary *)changeDict:(NSDictionary*)dict type:(NSString *)type
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc]init];
    if ([type isEqualToString:@"1"]) {
        [infoDict setObject:[dict objectForKey:@"kCardItem7"] forKey:@"iddate"];
        [infoDict setObject:[dict objectForKey:@"kCardItem15"] forKey:@"policeorg"];
    }else{
        [infoDict setObject:[dict objectForKey:@"kCardItem4"] forKey:@"birthday"];
        [infoDict setObject:[dict objectForKey:@"kCardItem2"] forKey:@"sex"];
        [infoDict setObject:[dict objectForKey:@"kCardItem0"] forKey:@"idno"];
        [infoDict setObject:[dict objectForKey:@"kCardItem5"] forKey:@"native"];
        [infoDict setObject:[dict objectForKey:@"kCardItem3"] forKey:@"ethnicname"];
        [infoDict setObject:[dict objectForKey:@"kCardItem1"] forKey:@"custname"];
    }
    return infoDict;
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

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.captureSession startRunning];
    [self.cardNumberLayer removeFromSuperlayer];
    self.cardNumberLayer = nil;
}

- (void)drawBorderRectWithBorderPoints:(NSArray *)borderPoints onCardBorderLayer:(BOOL)flag
{
    if ([borderPoints count] >= 4)
    {
        CGPoint point1 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:0] CGPointValue]];
        CGPoint point2 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:1] CGPointValue]];
        CGPoint point3 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:2] CGPointValue]];
        CGPoint point4 = [self convertBorderPointsInImageToPreviewLayer:[[borderPoints objectAtIndex:3] CGPointValue]];
        
        CAShapeLayer *line = [CAShapeLayer layer];
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:point1];
        [linePath addLineToPoint:point2];
        [linePath addLineToPoint:point3];
        [linePath addLineToPoint:point4];
        [linePath addLineToPoint:point1];
        line.path = linePath.CGPath;
        line.fillColor = nil;
        line.opacity = 1.0;
        line.strokeColor = UIColorFromHex(0x00aeff).CGColor;
        if (flag)
        {
            self.cardBorderLayer = line;
        }
        else
        {
            self.cardNumberLayer = line;
        }
        [self.previewLayer addSublayer:line];
    }
}

- (CGPoint)convertBorderPointsInImageToPreviewLayer:(CGPoint )borderPoint
{
    //video orientation is landscape
    CGFloat y = borderPoint.x * self.previewLayer.bounds.size.height / ImageFrameWidth;
    CGFloat x = self.previewLayer.bounds.size.width - borderPoint.y * self.previewLayer.bounds.size.width / ImageFrameHeight;
    return CGPointMake(x, y);
}

#define clamp(a) (a>255?255:(a<0?0:a));

- (UIImage *) imageRefrenceFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = (uint8_t *)malloc(width * height * bytesPerPixel);
    
    for(int y = 0; y < height; y++)
    {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for(int x = 0; x < width; x++)
        {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

- (NSUInteger)stringLengthForUnsignedShortArray:(unsigned short *)target maxLength:(NSUInteger)maxLength
{
    NSUInteger length = 0;
    for (NSUInteger i = 0; i < maxLength; i++)
    {
        if (target[i] == 0)
        {
            break;
        }
        length++;
    }
    
    return length;
}

- (void)orientationDidChange:(NSNotification *)noti
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationPortrait :
        {
            CGFloat width = screenSize.width - 30;
            CGFloat height = (width * 2) / 3;
            self.borderView.frame = CGRectMake((screenSize.width - width)/2, (screenSize.height - height)/2, width, height);
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown :
        {
            CGFloat width = screenSize.width - 30;
            CGFloat height = (width * 2) / 3;
            self.borderView.frame = CGRectMake((screenSize.width - width)/2, (screenSize.height - height)/2, width, height);
        }
            break;
            
        case UIDeviceOrientationLandscapeLeft :
        {
            self.borderView.frame = CGRectMake((screenSize.width - BorderWidth)/2, (screenSize.height - BorderHeight)/2, BorderWidth, BorderHeight);
        }
            break;
            
        case UIDeviceOrientationLandscapeRight :
        {
            self.borderView.frame = CGRectMake((screenSize.width - BorderWidth)/2, (screenSize.height - BorderHeight)/2, BorderWidth, BorderHeight);
        }
            break;
            
        default:
            break;
    }
}

//更新title
- (void)updateTitleLabel
{
    if ([self.positivePic isEqualToString:@"1"]) {
        _tipTitle.text = @"请将国徽面放入框内，并调整好光线，不要有阴影或反光";
    }else{
        _tipTitle.text = @"请将人像面放入框内，并调整好光线，不要有阴影或反光";

    }
}



-(void)changeOrientation:(NSString*)orientation
{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    CGFloat width = size_screen.width;
    CGFloat height = rect_screen.size.height;
    CGPoint lup  = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMinY(sRect));
    CGPoint rup = CGPointMake(CGRectGetMaxX(sRect), CGRectGetMaxY(sRect));
    if ([orientation isEqualToString:@"1"]) {
        if (height == 480)
        {//苹果4屏幕上sRect
            self.IDCardImage.frame = CGRectMake(rup.x-100,lup.y+40, 70, 70);
        }else if (height == 568){
            self.IDCardImage.frame = CGRectMake(rup.x-70*scale1-30, lup.y+20, 70*scale1, 70*scale1);
        }else{
            self.IDCardImage.frame = CGRectMake(rup.x-70*scale1-50, lup.y+60, 70*scale1, 70*scale1);
        }
        [self.IDCardImage setImage:[self fixOrientation90:[UIImage imageNamed:@"IDCardImageB.png"]]];
    }else{
        if (height == 480)
        {//苹果4屏幕上sRect
            scale1 = width/320;
            self.IDCardImage.frame = CGRectMake(rup.x-160*scale1-20, rup.y-110*scale1-20, 110*scale1, 110*scale1);
        }else if (height == 568){
            self.IDCardImage.frame = CGRectMake(rup.x-160*scale1-40, rup.y-110*scale1-60, 110*scale1+30, 110*scale1+30);
        }else{
            self.IDCardImage.frame = CGRectMake(rup.x-160*scale1-40, rup.y-110*scale1-80, 110*scale1+40, 110*scale1+40);
        }
        [self.IDCardImage setImage:[self fixOrientation90:[UIImage imageNamed:@"IDCardImageF.png"]]];

    }
    [self updateTitleLabel];
}

//文字旋转90度
- (UIImage *)fixOrientation90:(UIImage *)aImage {
    UIImage *image = nil;
    image = [UIImage imageWithCGImage:aImage.CGImage scale:1 orientation:UIImageOrientationRight];
    return image;
}

@end
