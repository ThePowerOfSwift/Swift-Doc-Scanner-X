//
//  LocalFileViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "LocalFileViewController.h"

@interface LocalFileViewController ()

@end

@implementation LocalFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableViewVC = [[LocalFileTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self pushViewController:_tableViewVC animated:YES];
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
        UIButton* backButton = [UIButton new];
        [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [backButton addTarget:parentVC action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(backButton.imageEdgeInsets.top, -14, backButton.imageEdgeInsets.bottom, backButton.imageEdgeInsets.right);
        _tableViewVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        _tableViewVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:parentVC action:@selector(backToHome)];
    }
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

@end
