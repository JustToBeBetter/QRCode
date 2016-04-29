//
//  LJZQRCodeGenerator.h
//  QRCode
//
//  Created by 李金柱 on 16/4/29.
//  Copyright © 2016年 likeme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LJZQRCodeGenerator : NSObject
//iOS7之后生成二维码
- (UIImage *)imageWithSize:(CGFloat)size andColorWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue andQRString:(NSString *)qrString;

@end
