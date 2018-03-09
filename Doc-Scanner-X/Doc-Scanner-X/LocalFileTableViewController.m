//
//  LocalFileTableViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "LocalFileTableViewController.h"

@interface LocalFileTableViewController ()

@end

@implementation LocalFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 17, 0, 0);
    self.navigationItem.title = @"Saved Files";
    
    self.emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty"]];
    self.emptyImage.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 200);
    self.emptyHint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    self.emptyHint.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 350);
    self.emptyHint.textColor = [UIColor grayColor];
    self.emptyHint.textAlignment = NSTextAlignmentCenter;
    self.emptyHint.text = @"You have not saved any files";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.localDatas == nil) {
        return 0;
    }
    return self.localDatas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    if (self.localDatas == nil) {
        return cell;
    }
    cell.textLabel.text = self.localDatas[indexPath.row].dataName;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.detailTextLabel.text = self.localDatas[indexPath.row].dataTimeStamp;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSURL* fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:self.localDatas[indexPath.row].dataName]];
    cell.imageView.image = [self getThumbnailImageFrom:fileURL Type:self.localDatas[indexPath.row].dataType];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.localDatas == nil) {
        self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        UIView* uiView = [[UIView alloc] initWithFrame:self.tableView.frame];
        [uiView addSubview:self.emptyHint];
        [uiView addSubview:self.emptyImage];
        return uiView;
    }
    if (self.localDatas.count != 0) {
        self.view.backgroundColor = [UIColor clearColor];
        UIView* uiView = [[UIView alloc] initWithFrame:CGRectZero];
        return uiView;
    } else {
        self.view.backgroundColor = [[UIColor alloc] initWithRed:240/255.0 green:239/255.0 blue:244/255.0 alpha:1];
        UIView* uiView = [[UIView alloc] initWithFrame:self.tableView.frame];
        [uiView addSubview:self.emptyHint];
        [uiView addSubview:self.emptyImage];
        return uiView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.localDatas[indexPath.row] == nil) {
        return;
    }
    self.quickLookVC = [QuickLookViewController new];
    self.quickLookVC.navigationItem.title = @"Preview";
    [self.navigationController pushViewController:self.quickLookVC animated:NO];
    [self.quickLookVC quickLookWithType:self.localDatas[indexPath.row].dataType In:self.localDatas[indexPath.row].dataName];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteFile:self.localDatas[indexPath.row].dataName];
        [self.localDatas removeObjectAtIndex:indexPath.row];
        [NSKeyedArchiver archiveRootObject:self.localDatas toFile:[LocalData getArchiveURL].path];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (self.localDatas.count == 0) {
            [self reload];
        }
    }];
    return @[deleteAction];
}

- (void) reload {
    self.localDatas = [[(NSMutableArray<LocalData*>*)[NSKeyedUnarchiver unarchiveObjectWithFile:[LocalData getArchiveURL].path] reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}

- (void) deleteFile:(NSString*)fileName {
    NSURL* path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:fileName]];
    [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
}

- (UIImage*) getThumbnailImageFrom:(NSURL*)fileURL Type:(NSUInteger)type {
    switch (type) {
        case PNG:
        case JPEG:
        {
            _image = [UIImage imageWithContentsOfFile:fileURL.path];
            CGSize imageSize = CGSizeMake(60, 60);
            if (_image.size.width > _image.size.height) {
                imageSize.height = 60 * _image.size.height / _image.size.width;
            } else {
                imageSize.width = 60 * _image.size.width / _image.size.height;
            }
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
            CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            [_image drawInRect:imageRect];
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            break;
        }
        case PDF:
        {
            CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
            CGPDFPageRef firstPage = CGPDFDocumentGetPage(pdf, 1);
            CGRect pageRect = CGPDFPageGetBoxRect(firstPage, kCGPDFMediaBox);
            UIGraphicsBeginImageContext(pageRect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, pageRect.size.height);
            CGContextScaleCTM(context, 1, -1);
            CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(firstPage, kCGPDFMediaBox, pageRect, 0, YES));
            CGContextDrawPDFPage(context, firstPage);
            CGContextRestoreGState(context);
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndPDFContext();
            CGSize imageSize = CGSizeMake(60, 60);
            if (_image.size.width > _image.size.height) {
                imageSize.height = 60 * _image.size.height / _image.size.width;
            } else {
                imageSize.width = 60 * _image.size.width / _image.size.height;
            }
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
            CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            [_image drawInRect:imageRect];
            _image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            break;
        }
        default:
            return nil;
    }
    return _image;
}

@end
