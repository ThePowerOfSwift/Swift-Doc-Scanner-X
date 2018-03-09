//
//  QuickLookViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "QuickLookViewController.h"

@interface QuickLookViewController ()

@end

@implementation QuickLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:239/255.0 blue:244/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    UIView* v = (UIView*)webView;
    while (v != nil) {
        v.backgroundColor = [UIColor clearColor];
        v = v.subviews.firstObject;
    }
}

- (void) quickLookWithType:(NSUInteger)type In:(NSString *)dataName {
    NSURL* path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:dataName]];
    switch (type) {
        case PNG:
        case JPEG:
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
            _imageView.image = [UIImage imageWithContentsOfFile:path.path];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:_imageView];
            break;
        case PDF:
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
            _webView.navigationDelegate = self;
            [_webView loadFileURL:path allowingReadAccessToURL:path];
            [self.view addSubview:_webView];
            break;
            
        default:
            break;
    }
}

@end
