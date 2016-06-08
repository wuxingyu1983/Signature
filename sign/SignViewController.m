//
//  SignViewController.m
//  sign
//
//  Created by 吴星煜 on 16/6/4.
//  Copyright © 2016年 imixun. All rights reserved.
//

#import "SignViewController.h"
#import "UploadViewController.h"
#import <PPSSignatureView.h>

#define Screen_Height       ([[UIScreen mainScreen] bounds].size.height)
#define Screen_Width        ([[UIScreen mainScreen] bounds].size.width)

#define BTN_WIDTH           200
#define BTN_HEIGHT          100

@interface SignViewController ()
{
    PPSSignatureView *signView;
    UploadViewController *uploadVC;
    
    UIImageView *signBakImgView;
}

@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    // 手写板
    signBakImgView = [[UIImageView alloc] initWithFrame:CGRectMake(92, 129, 840, 510)];
    signBakImgView.contentMode = UIViewContentModeScaleToFill;
    signBakImgView.image = [UIImage imageNamed:@"signbackground"];
    signBakImgView.userInteractionEnabled = YES;
    [self.view addSubview:signBakImgView];

    signView = [[PPSSignatureView alloc] initWithFrame:CGRectMake(0, 0, signBakImgView.frame.size.width, signBakImgView.frame.size.height)
                                               context:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
    signView.backgroundColor = [UIColor clearColor];
    signView.strokeColor = [UIColor whiteColor];
    [signBakImgView addSubview:signView];

    // 控制按钮
    UIButton *eraseBtn = [[UIButton alloc] initWithFrame:CGRectMake(559, 672, 130, 50)];
    [eraseBtn setImage:[UIImage imageNamed:@"cleanBtn"] forState:UIControlStateNormal];
    [eraseBtn setImage:[UIImage imageNamed:@"cleanBtn"] forState:UIControlStateHighlighted];
    [eraseBtn addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:eraseBtn];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(337, 672, 130, 50)];
    [nextBtn setImage:[UIImage imageNamed:@"confirmBtn"] forState:UIControlStateNormal];
    [nextBtn setImage:[UIImage imageNamed:@"confirmBtn"] forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:nextBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - private function

- (void)clean
{
    [signView erase];
}

- (void)next
{
    UIImage *img = signView.signatureImage;
    if (img) {
        if (nil == uploadVC) {
            uploadVC = [[UploadViewController alloc] init];
        }
        
        uploadVC.signatureImage = img;
        
        [self.navigationController pushViewController:uploadVC animated:YES];
    }
}

@end
