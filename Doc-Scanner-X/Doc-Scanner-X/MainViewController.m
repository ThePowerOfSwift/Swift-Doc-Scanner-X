//
//  ViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (BOOL)prefersStatusBarHidden {
    return _isStatusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _centerVC = [[CenterViewController alloc] init];
    [self addChildViewController:_centerVC];
    [self.view addSubview:_centerVC.view];
    _leftVC = [[LeftDrawerViewController alloc] init];
    _leftVC.delegate = self;
    [self addChildViewController: _leftVC];
    [self.view addSubview: _leftVC.view];
    _webVC = [[WebViewController alloc] init];
    _fileVC = [[LocalFileViewController alloc] init];
    _uploadVC = [[UploadedFileViewController alloc] init];
    _trickButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _trickButton.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
    [_trickButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LeftDrawerDelegate

- (void) selectMenuWithIndex:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            for (UIViewController* vc in self.childViewControllers) {
                if (vc == _leftVC) {
                    continue;
                } else {
                    [vc removeFromParentViewController];
                    [vc.view removeFromSuperview];
                }
            }
            [self addChildViewController:_centerVC];
            [self.view addSubview:_centerVC.view];
            [self back];
            break;
        case 1:
            for (UIViewController* vc in self.childViewControllers) {
                if (vc == _leftVC) {
                    continue;
                } else {
                    [vc removeFromParentViewController];
                    [vc.view removeFromSuperview];
                }
            }
            [self addChildViewController:_fileVC];
            [self.view addSubview:_fileVC.view];
            [self back];
            [_fileVC.tableViewVC reload];
            break;
        case 2:
            for (UIViewController* vc in self.childViewControllers) {
                if (vc == _leftVC) {
                    continue;
                } else {
                    [vc removeFromParentViewController];
                    [vc.view removeFromSuperview];
                }
            }
            [self addChildViewController:_uploadVC];
            [self.view addSubview:_uploadVC.view];
            [self back];
            break;
        case 3:
            for (UIViewController* vc in self.childViewControllers) {
                if (vc == _leftVC) {
                    continue;
                } else {
                    [vc removeFromParentViewController];
                    [vc.view removeFromSuperview];
                }
            }
            [self addChildViewController:_webVC];
            [self.view addSubview:_webVC.view];
            [self back];
            break;
        default:
            break;
    }
}

#pragma mark - Methods

- (void)showOrHideStatusBar {
    _isStatusBarHidden = !_isStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void) back {
    [_trickButton removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        for (UIViewController* vc in self.childViewControllers) {
            vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
        }
    }];
}

- (void) leftDrawerFromCenter {
    [UIView animateWithDuration:0.3 animations: ^{
        for (UIViewController* vc in self.childViewControllers) {
            vc.view.transform = CGAffineTransformMakeTranslation(200, 0);
        }
    }];
    [_centerVC.view addSubview:_trickButton];
}

- (void) backToHome {
    _centerVC.view.transform = CGAffineTransformMakeTranslation(0, 0);
    for (UIViewController* vc in self.childViewControllers) {
        if (vc == _leftVC) {
            continue;
        } else {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
        }
    }
    [self addChildViewController:_centerVC];
    [self.view addSubview:_centerVC.view];
    [_leftVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) backAfterUpload {
    for (UIViewController* vc in self.childViewControllers) {
        if (vc == _leftVC) {
            continue;
        } else {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
        }
    }
    [self addChildViewController:_uploadVC];
    [self.view addSubview:_uploadVC.view];
}

-(void) backAfterArchive {
    for (UIViewController* vc in self.childViewControllers) {
        if (vc == _leftVC) {
            continue;
        } else {
            [vc removeFromParentViewController];
            [vc.view removeFromSuperview];
        }
    }
    [self addChildViewController:_fileVC];
    [self.view addSubview:_fileVC.view];
    [_fileVC.tableViewVC reload];
}

@end
