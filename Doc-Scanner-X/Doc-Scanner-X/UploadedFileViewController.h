//
//  UploadedFileViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2018/1/9.
//  Copyright © 2018年 com.dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CustomNavigationBar.h"
#import "MainViewController.h"
#import "KeyChainManager.h"


@interface UploadedFileViewController : UIViewController<WKNavigationDelegate>

@property WKWebView* webView;

@property CustomNavigationBar* navigationBar;

@property UIActivityIndicatorView* activityIndicator;

@property UIRefreshControl* refreshControl;

@end
