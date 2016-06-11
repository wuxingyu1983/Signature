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
#import <AFNetworking/AFNetworking.h>
#import <pop/POP.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define Screen_Height       ([[UIScreen mainScreen] bounds].size.height)
#define Screen_Width        ([[UIScreen mainScreen] bounds].size.width)

#define BTN_WIDTH           200
#define BTN_HEIGHT          100

@interface SignViewController () <UploadViewControllerDelegate>
{
    PPSSignatureView *signView;
    UploadViewController *uploadVC;
    
    UIImageView *signBakImgView;
    UIImageView *sendingImgView;
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

    signView = [[PPSSignatureView alloc] initWithFrame:CGRectMake(10, 10, signBakImgView.frame.size.width - 20, signBakImgView.frame.size.height - 20)
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
    
    sendingImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    sendingImgView.image = [UIImage imageNamed:@"sending"];
    sendingImgView.layer.opacity = 0.0;
    [self.view addSubview:sendingImgView];
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

#pragma mark - UploadViewControllerDelegate

- (void)sendSuccessed
{
    [signView erase];
}

#pragma mark - private function

- (void)clean
{
    [signView erase];
}

- (void)next
{
    UIImage *img = signView.signatureImage;
    if (img) {
        uploadVC = [[UploadViewController alloc] init];
        uploadVC.delegate = self;
/*
        if (nil == uploadVC || nil == uploadVC.pictureID) {
            // 第一次用，或者已经上传完了，新一次的
            uploadVC = [[UploadViewController alloc] init];
        }
*/
        if (nil == uploadVC.pictureID) {
            // 上传图片
            signBakImgView.userInteractionEnabled = NO;
            
            POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            opacityAnimation.toValue = @(1.0);
            opacityAnimation.duration = 0.2f;
            [sendingImgView.layer pop_addAnimation:opacityAnimation forKey:@"layerOpacityAnimation"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                {
                    NSString *strUrl = @"http://192.168.1.1:8080/server/photo/upload.do";
//                    NSString *strUrl = @"http://120.203.18.7/server/photo/upload.do";
                    
                    NSData *aImageData = UIImageJPEGRepresentation(img, 0.8);
                    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                                              URLString:strUrl
                                                                                                             parameters:nil
                                                                                              constructingBodyWithBlock:^(id formData) {
                                                                                                  //key服务器地址url上二进制流的关键字字段
                                                                                                  //file，自定义的文件名
                                                                                                  //@”application/octet-stream”文件的类型，当你不知道时就默认用这个
                                                                                                  [formData appendPartWithFileData:aImageData
                                                                                                                              name:@"file"
                                                                                                                          fileName:@"sign.jpg"
                                                                                                                          mimeType:@"application/octet-stream"];
                                                                                                  
                                                                                              } error:nil];
                    
                    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                        //进度条
                        
                    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        //失败
                        if (error) {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"the url is %@, the error is %@", strUrl, [error localizedDescription]]];
                            [self uploadFailed];
                        } else {//成功
                            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"the url is %@, the return is %@", strUrl, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]]];
                            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                            if ([@"success" isEqualToString:[dict objectForKey:@"type"]]) {
                                // 上传成功
                                NSString *strData = [dict objectForKey:@"data"];
                                uploadVC.signatureImage = img;
                                uploadVC.pictureID = strData;
                                
                                [self uploadSuccess];
                            }
                            else {
                                // 上传失败
                                [self uploadFailed];
                            }
                        }
                    }];
                    
                    [uploadTask resume];
                }
            });
        }
        else {
            [self.navigationController pushViewController:uploadVC animated:YES];
        }
    }
}

- (void)uploadSuccess
{
    signBakImgView.userInteractionEnabled = YES;
    
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.2f;
    [sendingImgView.layer pop_addAnimation:opacityAnimation forKey:@"layerOpacityAnimation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:uploadVC animated:YES];
    });
}

- (void)uploadFailed
{
    signBakImgView.userInteractionEnabled = YES;
    
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.2f;
    [sendingImgView.layer pop_addAnimation:opacityAnimation forKey:@"layerOpacityAnimation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"上传失败，请重试 !"];
    });
}

@end
