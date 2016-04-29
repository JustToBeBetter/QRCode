//
//  LJZQRCodeReaderView.h
//  DesignBox
//
//  Created by 李金柱 on 16/4/19.
//  Copyright © 2016年 likeme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  LJZQRCodeReaderViewDelegate<NSObject>

- (void)scanResult:(NSString *)result;


@end

@interface LJZQRCodeReaderView : UIView

@property (nonatomic,weak) id<LJZQRCodeReaderViewDelegate>  delegate;
@property (nonatomic,  copy) UIImageView    *scanLineView;
@property (nonatomic,assign) BOOL  isMotion;
@property (nonatomic,assign) BOOL  isMotionFinished;

- (void)start;
- (void)stop;

- (void)initScanLine;

@end
