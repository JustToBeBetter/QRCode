//
//  LJZQRCodeReaderView.m
//  DesignBox
//
//  Created by 李金柱 on 16/4/19.
//  Copyright © 2016年 likeme. All rights reserved.
//

#import "LJZQRCodeReaderView.h"
#import  <AVFoundation/AVFoundation.h>
#define kScreenSize  [UIScreen mainScreen].bounds.size

#define widthRate kScreenSize.width/320

#define LJZRGBColor(r, g, b)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define kContentColor LJZRGBColor(102, 102, 102)

@interface LJZQRCodeReaderView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    
}

@end

@implementation LJZQRCodeReaderView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initScanDevice];
    }
    return  self;
}
- (void)initScanDevice{
    
    //扫描区域
    UIImageView *scanZoneBg      = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanBg"]];
    scanZoneBg.backgroundColor   = [UIColor clearColor];
    scanZoneBg.layer.borderColor = [UIColor whiteColor].CGColor;
    scanZoneBg.layer.borderWidth = 2.5;
    
    //添加一个背景图片
    CGRect scanRect  =  CGRectMake(60 * widthRate, (kScreenSize.height - 200 * widthRate)/2, 200 * widthRate, 200 * widthRate);
    scanZoneBg.frame = scanRect;
    [self addSubview:scanZoneBg];
    
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput *input   = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    CGRect scanInterest = [self getScanCrop:scanRect scanViewBounds:self.frame];
    output.rectOfInterest = scanInterest;
    
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    
    //设置高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [_session addInput:input];
    }
    if (output) {
        [_session addOutput:output];
        //设置扫码支持的编码格式（二维码和条形码）
        NSMutableArray *mArr = [[NSMutableArray alloc]init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [mArr addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [mArr addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [mArr addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [mArr addObject:AVMetadataObjectTypeCode128Code];
        }
        //添加所有的编码格式
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeUPCECode]) {
            [mArr addObject:AVMetadataObjectTypeUPCECode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode39Code]) {
            [mArr addObject:AVMetadataObjectTypeCode39Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode39Mod43Code]) {
            [mArr addObject:AVMetadataObjectTypeCode39Mod43Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode93Code]) {
            [mArr addObject:AVMetadataObjectTypeCode93Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypePDF417Code]) {
            [mArr addObject:AVMetadataObjectTypePDF417Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeAztecCode]) {
            [mArr addObject:AVMetadataObjectTypeAztecCode];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeInterleaved2of5Code]) {
            [mArr addObject:AVMetadataObjectTypeInterleaved2of5Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeITF14Code]) {
            [mArr addObject:AVMetadataObjectTypeITF14Code];
        }

        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeDataMatrixCode]) {
            [mArr addObject:AVMetadataObjectTypeDataMatrixCode];
        }

      
        output.metadataObjectTypes = mArr;
        
    }
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame        = self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    //设置界面
    [self setOverlayPickerView:self];
    
    //开始捕获
    [_session startRunning];
    
}
- (void)setOverlayPickerView:(LJZQRCodeReaderView *)reader
{
    
    CGFloat width  = 60*widthRate;
    CGFloat height = (kScreenSize.height-200*widthRate)/2;
    
    //最上部view
    CGFloat alpha  = 0.6;
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, height)];
    upView.alpha   = alpha;
    upView.backgroundColor = kContentColor;
    [reader addSubview:upView];
    
    //用于说明的label
    UILabel *labIntroudction        = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame           = CGRectMake(0, 64+(height-64-50*widthRate)/2, kScreenSize.width, 50*widthRate);
    labIntroudction.textAlignment   = NSTextAlignmentCenter;
    labIntroudction.textColor       = [UIColor whiteColor];
    labIntroudction.text            = @"请扫描二维码或条形码";
    [upView addSubview:labIntroudction];
    
    //左侧的view
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, 200*widthRate)];
    leftView.alpha    = alpha;
    leftView.backgroundColor = kContentColor;
    [reader addSubview:leftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kScreenSize.width-width, height, width, 200*widthRate)];
    rightView.alpha   = alpha;
    rightView.backgroundColor = kContentColor;
    [reader addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, height+200*widthRate, kScreenSize.width, kScreenSize.height - height-200*widthRate)];
    downView.alpha    = alpha;
    downView.backgroundColor = kContentColor;
    [reader addSubview:downView];
    
    //开关灯button
    UIButton *turnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    turnBtn.backgroundColor = [UIColor clearColor];
    [turnBtn setBackgroundImage:[UIImage imageNamed:@"lightSelect"] forState:UIControlStateNormal];
    [turnBtn setBackgroundImage:[UIImage imageNamed:@"lightNormal"] forState:UIControlStateSelected];
    turnBtn.frame = CGRectMake((kScreenSize.width-50*widthRate)/2, (CGRectGetHeight(downView.frame)-50*widthRate)/2, 50*widthRate, 50*widthRate);
    [turnBtn addTarget:self action:@selector(turnBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:turnBtn];
    
}
- (void)turnBtnEvent:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}
- (void)turnTorchOn:(bool)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(CGRect)getScanCrop:(CGRect)rect scanViewBounds:(CGRect)scanViewBounds{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(scanViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(scanViewBounds);
    y = (CGRectGetWidth(scanViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(scanViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(scanViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(scanViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

- (void)start{
    [_session startRunning];
    
}
- (void)stop{
    [_session stopRunning];
}
- (void)initScanLine{
    
    _isMotionFinished = NO;
    CGRect rect = CGRectMake(60*widthRate, (kScreenSize.height-200*widthRate)/2, 200*widthRate, 2);
    if (_scanLineView) {
        _scanLineView.alpha = 1;
        _scanLineView.frame = rect;
    }
    else{
        _scanLineView = [[UIImageView alloc] initWithFrame:rect];
        [_scanLineView setImage:[UIImage imageNamed:@"scanLine"]];
        [self addSubview:_scanLineView];
    }
    
    [UIView animateWithDuration:1.5 animations:^{
        //修改fream的代码写在这里
        _scanLineView.frame =CGRectMake(60*widthRate, (kScreenSize.height-200*widthRate)/2+200*widthRate-5, 200*widthRate, 2);
    } completion:^(BOOL finished) {
        if (!_isMotion) {
            [self initScanLine];
        }
        _isMotionFinished= YES;
    }];

}
#pragma
#pragma  mark =================扫描结果=================

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects && metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        if (_delegate && [_delegate respondsToSelector:@selector(scanResult:)]) {
            [_delegate scanResult:metadataObject.stringValue];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
