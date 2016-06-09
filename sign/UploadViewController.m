//
//  UploadViewController.m
//  sign
//
//  Created by 吴星煜 on 16/6/4.
//  Copyright © 2016年 imixun. All rights reserved.
//

#import "UploadViewController.h"
#import <pop/POP.h>
#import "ImageView.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define Screen_Height       ([[UIScreen mainScreen] bounds].size.height)
#define Screen_Width        ([[UIScreen mainScreen] bounds].size.width)

@interface UploadViewController ()
{
    ImageView *signImgBakView;
    UIImageView *signImgView;
    
    NSInteger iSelected;
    
    UIImageView *termBakView;
    UIButton *pictureBtn;
    UIButton *themeBtn;
    UIImageView *tipsImgView;
    UIButton *arrowBtn;

    UITapGestureRecognizer *tapGestureRecognizer;
    UIPanGestureRecognizer *panGestureRecognizer;
}

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    iSelected = 0;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    // back button
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, Screen_Height - 80, 150, 50)];
    [backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:backBtn];
   
    // 签名图片
    signImgBakView = [[ImageView alloc] initWithFrame:CGRectMake(184, 256, 520, 312)];
    signImgBakView.image = [UIImage imageNamed:@"signbackground"];
    [self.view addSubview:signImgBakView];

    signImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, signImgBakView.frame.size.width, signImgBakView.frame.size.height)];
    signImgView.image = self.signatureImage;
    [signImgBakView addSubview:signImgView];

    // 左箭头
    arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowBtn.frame = CGRectMake(Screen_Width - 80, (Screen_Height - 80) / 2, 40, 80);
    [arrowBtn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [arrowBtn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateHighlighted];
    arrowBtn.layer.opacity = 0.0;
    [arrowBtn addTarget:self action:@selector(presentAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:arrowBtn];
    
    // 终端
    termBakView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - 228, 80, 228, 608)];
    termBakView.image = [UIImage imageNamed:@"termbackground"];
    termBakView.userInteractionEnabled = YES;
    [self.view addSubview:termBakView];
    
    pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureBtn.frame = CGRectMake(26, 112, 176, 150);
    [pictureBtn addTarget:self action:@selector(picture) forControlEvents:UIControlEventTouchDown];
    [termBakView addSubview:pictureBtn];
    
    themeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    themeBtn.frame = CGRectMake(26, 336, 176, 150);
    [themeBtn addTarget:self action:@selector(theme) forControlEvents:UIControlEventTouchDown];
    [termBakView addSubview:themeBtn];
    
    [self refreshBtn];
    
    // 提示
    tipsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(432, 60, 160, 69)];
    tipsImgView.image = [UIImage imageNamed:@"tips"];
    tipsImgView.layer.opacity = 0.0;
    [self.view addSubview:tipsImgView];

    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(hideAction)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(handlePan:)];
    panGestureRecognizer.enabled = NO;
    [signImgBakView addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    signImgView.image = self.signatureImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - private functions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)picture
{
    iSelected = 1;
    [self refreshBtn];
    [self hideAction];
    panGestureRecognizer.enabled = YES;
}

- (void)theme
{
    iSelected = 2;
    [self refreshBtn];
    [self hideAction];
    panGestureRecognizer.enabled = YES;
}

- (void)refreshBtn
{
    if (1 == iSelected) {
        [pictureBtn setImage:[UIImage imageNamed:@"picture_selected"] forState:UIControlStateNormal];
        [pictureBtn setImage:[UIImage imageNamed:@"picture_selected"] forState:UIControlStateHighlighted];
    }
    else {
        [pictureBtn setImage:[UIImage imageNamed:@"picture_unselected"] forState:UIControlStateNormal];
        [pictureBtn setImage:[UIImage imageNamed:@"picture_unselected"] forState:UIControlStateHighlighted];
    }
    
    if (2 == iSelected) {
        [themeBtn setImage:[UIImage imageNamed:@"theme_selected"] forState:UIControlStateNormal];
        [themeBtn setImage:[UIImage imageNamed:@"theme_selected"] forState:UIControlStateHighlighted];
    }
    else {
        [themeBtn setImage:[UIImage imageNamed:@"theme_unselected"] forState:UIControlStateNormal];
        [themeBtn setImage:[UIImage imageNamed:@"theme_unselected"] forState:UIControlStateHighlighted];
    }
}

// 右侧显示事件
- (void)presentAction
{
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.5f;
    [tipsImgView.layer pop_addAnimation:opacityAnimation forKey:@"layerOpacityAnimation"];
    
    POPBasicAnimation *opacityArrowAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityArrowAnimation.toValue = @(0.0);
    opacityArrowAnimation.duration = 0.5f;
    [arrowBtn.layer pop_addAnimation:opacityArrowAnimation forKey:@"layerOpacityAnimation"];
    
    POPBasicAnimation *posTermAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    posTermAnimation.toValue = @(Screen_Width - termBakView.frame.size.width / 2);
    posTermAnimation.duration = 0.5f;
    [termBakView.layer pop_addAnimation:posTermAnimation forKey:@"layerPositionXAnimation"];
    
    POPBasicAnimation *posSignAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    posSignAnimation.toValue = @(184 + 520 / 2);
    posSignAnimation.duration = 0.5f;
    [signImgBakView.layer pop_addAnimation:posSignAnimation forKey:@"layerPositionXAnimation"];

    tapGestureRecognizer.enabled = YES;
}

// 右侧隐藏事件
- (void)hideAction
{
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(1.0);
    opacityAnimation.duration = 0.5f;
    [tipsImgView.layer pop_addAnimation:opacityAnimation forKey:@"layerOpacityAnimation"];
    
    POPBasicAnimation *opacityArrowAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityArrowAnimation.toValue = @(1.0);
    opacityArrowAnimation.duration = 0.5f;
    [arrowBtn.layer pop_addAnimation:opacityArrowAnimation forKey:@"layerOpacityAnimation"];
    
    POPBasicAnimation *posTermAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    posTermAnimation.toValue = @(Screen_Width + termBakView.frame.size.width / 2);
    posTermAnimation.duration = 0.5f;
    [termBakView.layer pop_addAnimation:posTermAnimation forKey:@"layerPositionXAnimation"];
    
    POPBasicAnimation *posSignAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    posSignAnimation.toValue = @(self.view.center.x);
    posSignAnimation.duration = 0.5f;
    [signImgBakView.layer pop_addAnimation:posSignAnimation forKey:@"layerPositionXAnimation"];

    tapGestureRecognizer.enabled = NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        if (velocity.y < -2000) {
            POPBasicAnimation *posSignAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
            posSignAnimation.toValue = @(0 - signImgBakView.frame.size.height / 2);
            posSignAnimation.duration = 0.2f;
            [signImgBakView.layer pop_addAnimation:posSignAnimation forKey:@"layerPositionYAnimation"];
            
            // 提交
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                             delegate:nil
                                                                        delegateQueue:[NSOperationQueue mainQueue]];
                
                NSString *strUrl;
                if (1 == iSelected) {
                    // 照片墙
                    strUrl = [NSString stringWithFormat:@"http://120.203.18.7/server/cmd/send.do?flash=ZPQ_%@", self.pictureID];
                }
                else {
                    // 主题墙
                    strUrl = [NSString stringWithFormat:@"http://120.203.18.7/server/cmd/send.do?flash=HYC_%@", self.pictureID];
                }
                
                NSURL * url = [NSURL URLWithString:strUrl];
                
                NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                    if(error == nil)
                                                                    {
                                                                        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                                                         error:nil];
                                                                        if ([@"success" isEqualToString:[responseObject objectForKey:@"type"]]) {
                                                                            if (self.delegate) {
                                                                                [self.delegate sendSuccessed];
                                                                            }
                                                                            
                                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                                [self.navigationController popViewControllerAnimated:YES];
                                                                            });
                                                                        }
                                                                        else {
                                                                            [self sendFailed];
                                                                        }
                                                                    }
                                                                    else {
                                                                        [self sendFailed];
                                                                    }
                                                                }];
                
                [dataTask resume];

            });
        }
    }
}

- (void)sendFailed
{
    POPBasicAnimation *posSignAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    posSignAnimation.toValue = @(self.view.center.y);
    posSignAnimation.duration = 0.2f;
    [signImgBakView.layer pop_addAnimation:posSignAnimation forKey:@"layerPositionYAnimation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"上传失败，请重试 !"];
    });
}

@end
