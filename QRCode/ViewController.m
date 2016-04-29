//
//  ViewController.m
//  QRCode
//
//  Created by 李金柱 on 16/3/11.
//  Copyright © 2016年 likeme. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LJZScanQRCodeViewController.h"
#import "LJZQRCodeGenerator.h"
@interface ViewController ()
{
    LJZQRCodeGenerator *_codeGenerator;
}
@property (weak, nonatomic) IBOutlet UITextField *textfield;

- (IBAction)scanQRCode:(id)sender;

- (IBAction)createQRCode:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *QRImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidekeyBoard:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)hidekeyBoard:(UITapGestureRecognizer *)tap{
    [self.textfield resignFirstResponder];
}
//扫描二维码
- (IBAction)scanQRCode:(id)sender {
    LJZScanQRCodeViewController *scanVC = [[LJZScanQRCodeViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}
//生成二维码
- (IBAction)createQRCode:(id)sender {
    
    self.QRImageView.image = nil;
    self.smallImage.hidden = YES;
    _codeGenerator = [[LJZQRCodeGenerator alloc] init];
    if (self.textfield.text.length > 0) {
        UIImage *image = [_codeGenerator imageWithSize:self.QRImageView.bounds.size.width andColorWithRed:82.0 Green:172.0 Blue:220.0 andQRString:self.textfield.text];
        self.QRImageView.image = image;
        self.smallImage.hidden = NO;
    }else{
        self.QRImageView.image = [UIImage imageNamed:@"myqrcode"];
    }
}
@end
