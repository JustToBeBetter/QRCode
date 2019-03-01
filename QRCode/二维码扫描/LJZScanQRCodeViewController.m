//
//  LJZScanQRCodeViewController.m
//  QRCode
//
//  Created by 李金柱 on 16/4/29.
//  Copyright © 2016年 likeme. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "LJZScanQRCodeViewController.h"
#import "LJZQRCodeReaderView.h"
#define kScreenSize  [UIScreen mainScreen].bounds.size

@interface LJZScanQRCodeViewController ()<LJZQRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    LJZQRCodeReaderView *_scanView;//二维码扫描对象
    
    BOOL _isFirst;//第一次进入该页面
    BOOL _isPush;//跳转到下一级页面
}
@property (strong, nonatomic) CIDetector *detector;
@end

@implementation LJZScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self initScan];
}
- (void)rightItemClick{
    
    [self albumbBtnEvent];
}
- (void)initScan
{
    if (_scanView) {
        [_scanView removeFromSuperview];
        _scanView = nil;
    }
    
    _scanView = [[LJZQRCodeReaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    _scanView.isMotionFinished = YES;
    _scanView.backgroundColor  = [UIColor clearColor];
    _scanView.delegate         = self;
    _scanView.alpha            = 0;
    
    [self.view addSubview:_scanView];
    
    [UIView animateWithDuration:0.5 animations:^{
        _scanView.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}
- (void)albumbBtnEvent
{
    
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if ([[UIDevice currentDevice].systemVersion intValue] >= 8) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开t启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
}

#pragma
#pragma  mark =================UIImagePickerControllerDelegate=================

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    _scanView.isMotion= YES;
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            
            [self accordingQcode:scannedResult];
        }];
        
    }
    else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            _scanView.isMotion = NO;
            [_scanView start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}


#pragma
#pragma  mark =================QRCodeReaderViewDelegate=================

- (void)scanResult:(NSString *)result
{
    _scanView.isMotion = YES;
    [_scanView stop];
    
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self accordingQcode:result];
    //跳转二级页面则_isPush置为YES 否则获得扫描结果后会重新开启扫描
    if(!_isPush){
         [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
    }
}
- (void)reStartScan
{
    _scanView.isMotion = NO;
    
    if (_scanView.isMotionFinished) {
        [_scanView initScanLine];
    }
    
    [_scanView start];
}

#pragma
#pragma  mark =================扫描结果处理=================

- (void)accordingQcode:(NSString *)str
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if (_isFirst || _isPush) {
    if (_scanView) {
        [self reStartScan];
    }
    // }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_scanView) {
        [_scanView stop];
        _scanView.isMotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirst) {
        _isFirst = NO;
    }
    if (_isPush) {
        _isPush = NO;
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
