//
//  ViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "CenterViewController.h"
#import "LeftDrawerViewController.h"
#import "WebViewController.h"
#import "LocalFileViewController.h"
#import "UploadedFileViewController.h"
#import <UIKit/UIKit.h>

@class CenterViewController;
@class LeftDrawerViewController;
@class WebViewController;
@class LocalFileViewController;
@class UploadedFileViewController;

@interface MainViewController : UIViewController <LeftDrawerDelegate>

#pragma mark - Properties

@property CenterViewController* centerVC;

@property LeftDrawerViewController* leftVC;

@property WebViewController* webVC;

@property LocalFileViewController* fileVC;

@property UploadedFileViewController* uploadVC;

@property UIButton* trickButton;

@property BOOL isStatusBarHidden;

#pragma mark - Methods

- (void)leftDrawerFromCenter;

- (void)backToHome;

- (void)backAfterUpload;

- (void)backAfterArchive;

- (void)back;

- (void)selectMenuWithIndex:(NSIndexPath *)indexPath;

- (void)showOrHideStatusBar;
@end

