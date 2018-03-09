//
//  LocalFileTableViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "LocalData.h"
#import "QuickLookViewController.h"
#import "CustomTableViewCell.h"
#import <UIKit/UIKit.h>

@interface LocalFileTableViewController : UITableViewController

@property (nullable) UIImage* image;

@property (nullable) QuickLookViewController* quickLookVC;

@property (nullable) NSMutableArray<LocalData*>* localDatas;

@property (nonnull) UIImageView* emptyImage;

@property (nonnull) UILabel* emptyHint;

- (void) reload;
@end
