//
//  QuickLookViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

enum FileType {
    PNG, JPEG, PDF
};


@interface QuickLookViewController : UIViewController<WKNavigationDelegate>

@property UIImageView* imageView;

@property WKWebView* webView;

- (void) quickLookWithType:(NSUInteger)type In:(NSString*)dataName;
@end
