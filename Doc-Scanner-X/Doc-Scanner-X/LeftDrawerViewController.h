//
//  LeftDrawerViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftDrawerDelegate <NSObject>

- (void)selectMenuWithIndex: (nonnull NSIndexPath*)indexPath;

@end

@interface LeftDrawerViewController : UITableViewController

#pragma mark Properties
@property (nonnull) NSArray<NSString*>* choice;
@property (nullable, weak) id<LeftDrawerDelegate> delegate;
@end
