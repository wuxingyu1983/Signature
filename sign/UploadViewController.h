//
//  UploadViewController.h
//  sign
//
//  Created by 吴星煜 on 16/6/4.
//  Copyright © 2016年 imixun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UploadViewControllerDelegate <NSObject>

- (void)sendSuccessed;

@end

@interface UploadViewController : UIViewController

@property (strong, nonatomic) UIImage *signatureImage;
@property (copy, nonatomic) NSString *pictureID;
@property (strong, nonatomic) id<UploadViewControllerDelegate> delegate;

@end
