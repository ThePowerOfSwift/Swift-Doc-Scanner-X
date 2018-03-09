//
//  WebViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "CustomNavigationBar.h"
#import "MainViewController.h"

@interface WebViewController : UIViewController<WKNavigationDelegate>

@property WKWebView* webView;

@property UINavigationBar* navigationBar;

@property UIActivityIndicatorView* activityIndicator;

@property UIRefreshControl* refreshControl;

@end
