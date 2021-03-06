//
//  PJEditImageViewController.m
//  editImageTest
//
//  Created by pjpjpj on 2017/11/21.
//  Copyright © 2017年 #incloud. All rights reserved.
//

#import "PJEditImageViewController.h"
#import "PJEditImageBottomView.h"
#import "PJEditImageBackImageView.h"
#import "PJEditImageBottomColorView.h"
#import <UShareUI/UShareUI.h>


#define PJSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define PJSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PJEditImageViewController () <PJEditImageBottomViewDelegate, PJEditImageBottomColorViewDelegate>

@property (nonatomic, strong) PJEditImageBottomView *bottomView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) PJEditImageBackImageView *touchView;
@property (nonatomic, strong) PJEditImageBottomColorView *colorView;
@property (nonatomic, assign) BOOL isBlur;

@end

@implementation PJEditImageViewController

- (instancetype)initWithInputImage:(UIImage *)inputImage {
    self = [super init];
    _imgView.image = inputImage;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    _isBlur = false;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.bottomView = [PJEditImageBottomView new];
    [self.view addSubview:self.bottomView];
    self.bottomView.viewDelegate = self;
    
    self.touchView = [PJEditImageBackImageView initWithImage:self.inputImage frame:CGRectMake(0, 0, PJSCREEN_WIDTH, PJSCREEN_HEIGHT - 50) lineWidth:10 lineColor:[UIColor blackColor]];
    [self.view addSubview:self.touchView];
    [self.view sendSubviewToBack:self.touchView];
    
    CGFloat marginX = (PJSCREEN_WIDTH - 50 * 4) / 5;
    self.colorView = [[PJEditImageBottomColorView alloc] initWithFrame:CGRectMake(marginX * 2 + 50, PJSCREEN_HEIGHT - 180 - 50, 50, 180)];
    [self.view addSubview:self.colorView];
    self.colorView.viewDelegate = self;
    self.colorView.hidden = true;
}

- (void)PJEditImageBottomViewColorViewShow {
    self.colorView.hidden = !self.colorView.hidden;
}

- (void)PJEditImageBottomColorViewSelectedColor:(UIColor *)color {
    [self.touchView setStrokeColor:color];
    self.colorView.hidden = !self.colorView.hidden;
    self.touchView.isBlur = false;
    _isBlur = false;
}

- (void)PJEditImageBottomViewBackBtnClick {
    [self.touchView revokeScreen];
}

- (void)PJEditImageBottomViewBlurBtnClick {
    _isBlur = !_isBlur;
    self.touchView.isBlur = _isBlur;
}

- (void)PJEditImageBottomViewShareBtnClick {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(PJSCREEN_WIDTH, PJSCREEN_HEIGHT - 50), true, 1.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self shareWebPageToPlatformType:UMSocialPlatformType_DingDing image:uiImage];
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType image:(UIImage *)image {
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    [shareObject setShareImage:image];
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

@end
