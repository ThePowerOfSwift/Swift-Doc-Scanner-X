//
//  WebViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
    _webView.navigationDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    NSURL* myURL = [[NSURL alloc] initWithString:@"https://developer.dynamsoft.com/dws/ios-guide"];
    NSURLRequest* myRequest = [[NSURLRequest alloc] initWithURL:myURL];
    [_webView loadRequest:myRequest];
    _webView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
    
    _navigationBar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    self.navigationItem.title = @"Developer Center";
    [_navigationBar pushNavigationItem:self.navigationItem animated:YES];
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:parentVC action:@selector(backToHome)];
    
    _refreshControl = [UIRefreshControl new];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [_refreshControl addTarget:self action:@selector(refreshWeb) forControlEvents:UIControlEventValueChanged];
    _webView.scrollView.bounces = YES;
    [_webView.scrollView addSubview:_refreshControl];
    
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:_navigationBar];
    [self.view addSubview:_webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_webView removeObserver:self forKeyPath:@"canGoBack"];
}

- (void)refreshWeb {
    [_refreshControl endRefreshing];
    [_webView reload];
}

- (void)back {
    [_webView goBack];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (_webView.canGoBack) {
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(back);
    } else {
        MainViewController* parentVC = (MainViewController*)self.parentViewController;
        self.navigationItem.leftBarButtonItem.target = parentVC;
        self.navigationItem.leftBarButtonItem.action = @selector(backToHome);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    _activityIndicator.backgroundColor = [UIColor clearColor];
    _activityIndicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_activityIndicator stopAnimating];
    [webView evaluateJavaScript:@"document.getElementById('liveChatMobile').style.visibility='hidden'" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_activityIndicator startAnimating];
    switch (error.code) {
        case NSURLErrorTimedOut:
            printf("timeout");
            break;
        case NSURLErrorNotConnectedToInternet:
            printf("no Internet");
            break;
        default:
            printf("other error");
            break;
    }
}


@end
