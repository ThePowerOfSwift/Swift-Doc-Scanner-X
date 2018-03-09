//
//  CenterViewController.m
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "CenterViewController.h"

@interface CenterViewController () {
    NSUInteger perImageProgress;
    NSUInteger uploadPieces;
}
@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fullScreenSize = [UIScreen mainScreen].bounds.size;
    
    [DcsView setLogLevel:DLLE_OFF];
    // Add navigationBar in DcsUIImageGalleryView
    _navigator = [[CustomNavigationBar alloc] initWithFrame: CGRectMake(0, 0, _fullScreenSize.width, 64)];
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    _menuItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:parentVC action:@selector(leftDrawerFromCenter)];
    self.navigationItem.title = @"Home";
    self.navigationItem.leftBarButtonItem = _menuItem;
    [_navigator pushNavigationItem:self.navigationItem animated:YES];
    
    _dcsView = [[DcsView alloc] initWithFrame:CGRectMake(0, 64, _fullScreenSize.width, _fullScreenSize.height-64-49)];

    _dcsView.videoView.delegate = self;
    _dcsView.imageGalleryView.delegate = self;
    _dcsView.documentEditorView.delegate = self;
    
    _dcsView.videoView.mode = DME_DOCUMENT;
    _dcsView.videoView.nextViewAfterCancel = DVE_IMAGEGALLERYVIEW;
    _dcsView.videoView.nextViewAfterCapture = DVE_VIDEOVIEW;
    _dcsView.videoView.ifAllowDocumentCaptureWhenNotDetected = YES;
    [_dcsView.imageGalleryView enterManualSortMode];
    _isSelectMode = NO;
    
    [self.view addSubview:_dcsView];
    [self.view addSubview:_navigator];
    
    _cameraButton = [UIButton new];
    [_cameraButton setImage:[UIImage imageNamed:@"icon_camera_click"] forState:UIControlStateHighlighted];
    [_cameraButton setImage:[UIImage imageNamed:@"icon_camera"] forState:UIControlStateNormal];
    _cameraButton.frame = CGRectMake(0, 0, 67, 67);
    _cameraButton.center = CGPointMake(_fullScreenSize.width/2, _fullScreenSize.height-49);
    [_cameraButton addTarget:self action:@selector(cameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _fullScreenSize.height-49, _fullScreenSize.width, 49)];
    _toolbar.barTintColor = [UIColor whiteColor];
    _deleteItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(enterDeleteMode)];
    _uploadItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(enterUploadMode)];
    _exportItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Export"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(enterExportMode)];
    _archiveItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(enterArchiveMode)];
    [self setToolbar];
    
    [self.view addSubview:_toolbar];
    [self.view addSubview:_cameraButton];
    
    _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, _fullScreenSize.height-31-47, 47, 47)];
    _thumbnailImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    _thumbnailImageView.clipsToBounds = YES;
    [_thumbnailImageView setUserInteractionEnabled:YES];
    _tapImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMultiImage)];
    [_thumbnailImageView addGestureRecognizer:_tapImageGesture];
    [_dcsView.videoView addSubview:_thumbnailImageView];
    
    _activityIndicator.center = CGPointMake(_fullScreenSize.width/2, _fullScreenSize.height/2);
    _activityBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _fullScreenSize.width, _fullScreenSize.height)];
    _activityBackground.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
    [_activityBackground addSubview:_activityIndicator];
    
    _progressIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 230, 0)];
    _progressIndicator.center = CGPointMake(_fullScreenSize.width/2, _fullScreenSize.height/2);
    _progressIndicator.transform = CGAffineTransformMakeScale(1, 5);
    _progressIndicator.progressTintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    _progressIndicator.trackTintColor = [UIColor colorWithRed:228/255.0 green:240/255.0 blue:246/255.0 alpha:1];
    _progressIndicator.clipsToBounds = YES;
    _progressIndicator.layer.masksToBounds = YES;
    _progressIndicator.layer.cornerRadius = 5;
    
    _progressBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _fullScreenSize.width, _fullScreenSize.height)];
    _progressBackground.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
    [_progressBackground addSubview:_progressIndicator];
    
    _emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty"]];
    _emptyImage.center = CGPointMake(_fullScreenSize.width/2, 200);
    _emptyHint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 44)];
    _emptyHint.center = CGPointMake(_fullScreenSize.width/2, 350);
    _emptyHint.textColor = [UIColor grayColor];
    _emptyHint.textAlignment = NSTextAlignmentCenter;
    _emptyHint.text = @"No images yet";
    if ([_dcsView.buffer count] == 0) {
        [_dcsView.imageGalleryView addSubview:_emptyHint];
        [_dcsView.imageGalleryView addSubview:_emptyImage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _localDatas = (NSMutableArray<LocalData*>*)[NSKeyedUnarchiver unarchiveObjectWithFile:[LocalData getArchiveURL].path];
    if (_localDatas == nil) {
        _localDatas = [NSMutableArray<LocalData*> new];
    }
    [_dcsView.buffer addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustUIWhenCalling) name:@"UIApplicationDidChangeStatusBarFrameNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_dcsView.buffer removeObserver:self forKeyPath:@"currentIndex"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidChangeStatusBarFrameNotification" object:nil];
}

- (void) adjustUIWhenCalling {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > 20) {
        [_dcsView setFrame:CGRectMake(_dcsView.frame.origin.x, _dcsView.frame.origin.y, _dcsView.frame.size.width, _dcsView.frame.size.height-20)];
        [_toolbar setFrame:CGRectMake(_toolbar.frame.origin.x, _toolbar.frame.origin.y, _toolbar.frame.size.width, _toolbar.frame.size.height-20)];
        [_cameraButton setFrame:CGRectMake(_cameraButton.frame.origin.x, _cameraButton.frame.origin.y, _cameraButton.frame.size.width, _cameraButton.frame.size.height-20)];
    } else {
        [_dcsView setFrame:CGRectMake(_dcsView.frame.origin.x, _dcsView.frame.origin.y, _dcsView.frame.size.width, _dcsView.frame.size.height+20)];
        [_toolbar setFrame:CGRectMake(_toolbar.frame.origin.x, _toolbar.frame.origin.y, _toolbar.frame.size.width, _toolbar.frame.size.height+20)];
        [_cameraButton setFrame:CGRectMake(_cameraButton.frame.origin.x, _cameraButton.frame.origin.y, _cameraButton.frame.size.width, _cameraButton.frame.size.height+20)];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (_dcsView.imageGalleryView.imageGalleryViewmode == DIVME_SINGLE) {
        NSString* title = [NSString stringWithFormat:@"%ld/%ld",(_dcsView.buffer.currentIndex+1),(long)[_dcsView.buffer count]];
        _navigator.topItem.title = title;
    }
}

#pragma mark Button actions.

- (void)enterDeleteMode {
    [_dcsView.imageGalleryView enterSelectMode];
    _isSelectMode = YES;
    [_cameraButton setHidden:YES];
    _navigator.topItem.title = @"Delete";
    _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectAll)];
    [_navigator.topItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1]];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    UIBarButtonItem* delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(onDelete)];
    [delete setEnabled:NO];
    cancel.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    delete.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolbar setItems:@[cancel, flexibleSpace, delete]];
}

- (void)onDelete {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        while ([_dcsView.imageGalleryView.selectedIndices count] > 0) {
            [_dcsView.buffer delete:((NSNumber*)_dcsView.imageGalleryView.selectedIndices[0]).integerValue];
        }
        [self onCancel];
        if ([_dcsView.buffer count] == 0) {
            [_dcsView.imageGalleryView addSubview:_emptyHint];
            [_dcsView.imageGalleryView addSubview:_emptyImage];
        }
    }];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)enterUploadMode {
    [_dcsView.imageGalleryView enterSelectMode];
    _isSelectMode = YES;
    [_cameraButton setHidden:YES];
    [self onSelectAll];
    _navigator.topItem.title = @"Upload";
    _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unselct All" style:UIBarButtonItemStylePlain target:self action:@selector(onUnselectAll)];
    _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    UIBarButtonItem* upload = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(onUpload)];
    [upload setEnabled:([_dcsView.buffer count] > 0)];
    cancel.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    upload.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolbar setItems:@[cancel, flexibleSpace, upload]];
}

- (void)onUpload {
    uploadPieces = 0;
    NSArray* indices = _dcsView.imageGalleryView.selectedIndices;
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Upload to server." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* pngAction = [UIAlertAction actionWithTitle:@"PNG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.view addSubview:_progressBackground];
        [self onCancel];
        [self recursive:0 indices:indices encodeFormat:[DcsPNGEncodeParameter new]];
    }];
    UIAlertAction* jpgAction = [UIAlertAction actionWithTitle:@"JPEG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.view addSubview:_progressBackground];
        [self onCancel];
        [self recursive:0 indices:indices encodeFormat:[DcsJPEGEncodeParameter new]];
    }];
    UIAlertAction* pdfAction = [UIAlertAction actionWithTitle:@"PDF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSSS";
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        NSString* dataTimeStamp = [dateFormatter stringFromDate:[NSDate date]];
        DcsHttpUploadConfig* uploadConfig = [DcsHttpUploadConfig new];
        uploadConfig.uploadMethod = DUME_POST;
        uploadConfig.filePrefix = [dataTimeStamp stringByReplacingOccurrencesOfString:@":" withString:@""];
        uploadConfig.dataFormat = DDFE_BINARY;
        uploadConfig.url = @"https://demo.dynamsoft.com/DCS_Mobile/upload.ashx";
        uploadConfig.formField = @{@"userId":[KeyChainManager readUUID],@"filePureName":uploadConfig.filePrefix};
        [self.view addSubview:_progressBackground];
        [self onCancel];
        [_dcsView.io uploadAsync:indices uploadConfig:uploadConfig encodeParameter:[DcsPDFEncodeParameter new] successCallback:^(NSData *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressBackground removeFromSuperview];
                _progressIndicator.progress = 0;
                [self uploadCompletionHandler:@"Upload completed"];
            });
        } failureCallback:^(id userData, DcsException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressBackground removeFromSuperview];
                _progressIndicator.progress = 0;
                if ([exception.reason  isEqual: @"The file size exceeded the 50MB limit."]) {
                    [self uploadCompletionHandler:@"Exceeded the 50MB limit"];
                } else {
                    [self uploadCompletionHandler:@"Upload failed"];
                }
            });
        } progressUpdateCallback:^BOOL(NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressIndicator setProgress:progress/100.0 animated:YES];
            });
            return YES;
        }];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self onCancel];
    }];
    [alertController addAction:pngAction];
    [alertController addAction:jpgAction];
    [alertController addAction:pdfAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)recursive:(NSInteger)pieces indices:(NSArray*)indices encodeFormat:(DcsEncodeParameter*)encodeFormat {
    perImageProgress = 0;
    if (pieces < indices.count) {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSSS";
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        NSString* dataTimeStamp = [dateFormatter stringFromDate:[NSDate date]];
        DcsHttpUploadConfig* uploadConfig = [DcsHttpUploadConfig new];
        uploadConfig.uploadMethod = DUME_POST;
        uploadConfig.filePrefix = [dataTimeStamp stringByReplacingOccurrencesOfString:@":" withString:@""];
        uploadConfig.dataFormat = DDFE_BINARY;
        uploadConfig.url = @"https://demo.dynamsoft.com/DCS_Mobile/upload.ashx";
        uploadConfig.formField = @{@"userId":[KeyChainManager readUUID],@"filePureName":uploadConfig.filePrefix};
        [_dcsView.io uploadAsync:@[indices[pieces]] uploadConfig:uploadConfig encodeParameter:encodeFormat successCallback:^(NSData *data) {
            [self recursive:(pieces+1) indices:indices encodeFormat:encodeFormat];
            uploadPieces += 1;
        } failureCallback:^(id userData, DcsException *exception) {
            [self recursive:(pieces+1) indices:indices encodeFormat:encodeFormat];
        } progressUpdateCallback:^BOOL(NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _progressIndicator.progress += (float)(progress-perImageProgress)/(100*indices.count);
                perImageProgress = progress;
            });
            return YES;
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressBackground removeFromSuperview];
            _progressIndicator.progress = 0;
            if (uploadPieces == indices.count) {
                [self uploadCompletionHandler:@"Upload completed"];
            } else if (uploadPieces == 0) {
                [self uploadCompletionHandler:@"Upload failed"];
            } else {
                [self uploadCompletionHandler:@"Upload failed for some of the files"];
            }
            uploadPieces = 0;
        });
        return;
    }
}

- (void)uploadCompletionHandler:(NSString*)result {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:result message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(DISPATCH_TIME_NOW+2.5, dispatch_get_main_queue(), ^{
        if ([result  isEqual: @"Upload completed"] || [result  isEqual: @"Upload failed for some of the files"]) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                MainViewController* parentVC = (MainViewController*)self.parentViewController;
                [parentVC backAfterUpload];
            }];
        } else {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)enterExportMode {
    [_dcsView.imageGalleryView enterSelectMode];
    _isSelectMode = YES;
    [_cameraButton setHidden:YES];
    [self onSelectAll];
    _navigator.topItem.title = @"Share";
    _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unselect All" style:UIBarButtonItemStylePlain target:self action:@selector(onUnselectAll)];
    _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    UIBarButtonItem* export = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(onExport)];
    [export setEnabled:([_dcsView.buffer count] > 0)];
    cancel.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    export.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolbar setItems:@[cancel, flexibleSpace, export]];
}

- (void)onExport {
    NSMutableArray<UIImage*>* images = [NSMutableArray<UIImage*> new];
    for (id index in _dcsView.imageGalleryView.selectedIndices) {
        DcsDocument* document = [_dcsView.buffer get:((NSNumber*)index).integerValue];
        [images addObject:document.uiImage];
    }
    UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems:images applicationActivities:nil];
    [activityVC setCompletionWithItemsHandler:^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        [self onCancel];
    }];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)enterArchiveMode {
    [_dcsView.imageGalleryView enterSelectMode];
    _isSelectMode = YES;
    [_cameraButton setHidden:YES];
    [self onSelectAll];
    _navigator.topItem.title = @"Save";
    _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unselect All" style:UIBarButtonItemStylePlain target:self action:@selector(onUnselectAll)];
    _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    UIBarButtonItem* archive = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onArchive)];
    [archive setEnabled:([_dcsView.buffer count] > 0)];
    cancel.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    archive.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolbar setItems:@[cancel, flexibleSpace, archive]];
}

- (void)onArchive {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Save to local file" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* pngAction = [UIAlertAction actionWithTitle:@"PNG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.view addSubview:_activityBackground];
        [_activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UNSPECIFIED, 0), ^{
            for (id index in _dcsView.imageGalleryView.selectedIndices) {
                NSDateFormatter* dateFormatter = [NSDateFormatter new];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSSS";
                dateFormatter.timeZone = [NSTimeZone systemTimeZone];
                NSString* dataTimeStamp = [dateFormatter stringFromDate:[NSDate date]];
                NSString* dataName = [[dataTimeStamp stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingString:@".png"];
                NSUInteger dataType = PNG;
                NSURL* path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:dataName]];
                [_dcsView.io save:@[index] file:path.path encodeParameter:[DcsPNGEncodeParameter new]];
                [_localDatas addObject:[[LocalData alloc] init:dataName dataType:dataType dataTimeStamp:dataTimeStamp]];
            }
            [self saveLocalDatas];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.activityBackground removeFromSuperview];
                [self onCancel];
                [self archiveCompletionHandler:@"Save completed"];
            });
        });
    }];
    UIAlertAction* jpgAction = [UIAlertAction actionWithTitle:@"JPEG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            for (id index in _dcsView.imageGalleryView.selectedIndices) {
                NSDateFormatter* dateFormatter = [NSDateFormatter new];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSSS";
                dateFormatter.timeZone = [NSTimeZone systemTimeZone];
                NSString* dataTimeStamp = [dateFormatter stringFromDate:[NSDate date]];
                NSString* dataName = [[dataTimeStamp stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingString:@".jpg"];
                NSUInteger dataType = JPEG;
                NSURL* path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:dataName]];
                [_dcsView.io save:@[index] file:path.path encodeParameter:[DcsPNGEncodeParameter new]];
                [_localDatas addObject:[[LocalData alloc] init:dataName dataType:dataType dataTimeStamp:dataTimeStamp]];
            }
            [self saveLocalDatas];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.activityBackground removeFromSuperview];
                [self onCancel];
                [self archiveCompletionHandler:@"Save completed"];
            });
        });
    }];
    UIAlertAction* pdfAction = [UIAlertAction actionWithTitle:@"PDF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSSS";
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        NSString* dataTimeStamp = [dateFormatter stringFromDate:[NSDate date]];
        NSString* dataName = [[dataTimeStamp stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingString:@".pdf"];
        NSUInteger dataType = PDF;
        NSURL* path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:[@"/" stringByAppendingString:dataName]];
        [self.view addSubview:_activityBackground];
        [self.activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            @try {
                [_dcsView.io save:_dcsView.imageGalleryView.selectedIndices file:path.path encodeParameter:[DcsPDFEncodeParameter new]];
                [_localDatas addObject:[[LocalData alloc] init:dataName dataType:dataType dataTimeStamp:dataTimeStamp]];
                [self saveLocalDatas];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.activityBackground removeFromSuperview];
                    [self onCancel];
                    [self archiveCompletionHandler:@"Save completed"];
                });
            }
            @catch (DcsException* e){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.activityBackground removeFromSuperview];
                    [self onCancel];
                    [self archiveCompletionHandler:@"Exceeded the 50MB limit"];
                });
            }
        });
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self onCancel];
    }];
    [alertController addAction:pngAction];
    [alertController addAction:jpgAction];
    [alertController addAction:pdfAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)archiveCompletionHandler:(NSString*)result {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:result message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(DISPATCH_TIME_NOW+2.5, dispatch_get_main_queue(), ^{
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            if (![result isEqual: @"Exceeded the 50MB limit"]) {
                MainViewController* parentVC = (MainViewController*)self.parentViewController;
                [parentVC backAfterArchive];
            }
        }];
    });
}

- (void)onUnselectAll {
    _dcsView.imageGalleryView.selectedIndices = nil;
}

- (void)onSelectAll {
    NSMutableArray<NSNumber*>* arr = [NSMutableArray<NSNumber*> new];
    for (NSInteger i = 0; i<[_dcsView.buffer count]; i++) {
        [arr addObject:[[NSNumber alloc] initWithInteger:i]];
    }
    _dcsView.imageGalleryView.selectedIndices = arr;
}

- (void)onCancel {
    [_dcsView.imageGalleryView enterManualSortMode];
    _isSelectMode = NO;
    [_cameraButton setHidden:NO];
    _navigator.topItem.title = @"Home";
    _navigator.topItem.rightBarButtonItem = nil;
    [self setToolbar];
}

- (void)cameraButtonTapped {
    [_navigator setHidden:YES];
    [_toolbar setHidden:YES];
    [_cameraButton setHidden:YES];
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    [parentVC showOrHideStatusBar];
    _dcsView.currentView = DVE_VIDEOVIEW;
    _dcsView.videoView.cancelText = @"Cancel";
    _thumbnailImageView.image = nil;
}

- (void)showMultiImage {
    _dcsView.currentView = DVE_IMAGEGALLERYVIEW;
    _dcsView.imageGalleryView.imageGalleryViewmode = DIVME_MULTIPLE;
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    [parentVC showOrHideStatusBar];
    [_navigator setHidden:NO];
    [_toolbar setHidden:NO];
    [_cameraButton setHidden:NO];
}

- (void)onDocumentDetected:(id)sender document:(DcsDocument *)document {
}

- (void)onCancelTapped:(id)sender {
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    [parentVC showOrHideStatusBar];
    [_navigator setHidden:NO];
    [_toolbar setHidden:NO];
    if ([sender isMemberOfClass:[DcsUIVideoView class]]) {
        [_cameraButton setHidden:NO];
    } else if ([sender isMemberOfClass:[DcsUIDocumentEditorView class]]) {
        [_cameraButton setHidden:YES];
    }
}

- (void)onCaptureTapped:(id)sender {
}

- (BOOL)onPreCapture:(id)sender {
    return YES;
}

- (void)onPostCapture:(id)sender image:(DcsImage*)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        _bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 145, 235, 376)];
        _bigImageView.backgroundColor = [UIColor clearColor];
        _bigImageView.image = image.uiImage;
        [_dcsView.videoView addSubview:_bigImageView];
        [self performSelector:@selector(removeBigImage:) withObject:image.uiImage afterDelay:0.5];
        [UIView animateWithDuration:0.5 animations:^{
            _bigImageView.transform = CGAffineTransformMakeScale(0.2, 0.125);
            [_bigImageView setFrame:CGRectMake(_thumbnailImageView.frame.origin.x, _thumbnailImageView.frame.origin.y, _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.size.height)];
        }];
        _dcsView.videoView.cancelText = @"Done";
        if (_emptyHint.superview != nil) {
            [_emptyHint removeFromSuperview];
            [_emptyImage removeFromSuperview];
        }
    });
}

- (void)onCaptureFailure:(id)sender exception:(DcsException *)exception {
}

- (void)onSingleTap:(id)sender index:(NSInteger)index {
    if (_dcsView.imageGalleryView.imageGalleryViewmode == DIVME_SINGLE) {
        NSString* title = [[NSString alloc] initWithFormat:@"%ld/%ld",(_dcsView.buffer.currentIndex+1),_dcsView.buffer.count];
        [_navigator pushNavigationItem:[[UINavigationItem alloc] initWithTitle:title] animated:NO];
        _navigator.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(multiMode)];
        _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(enterEdit)];
        _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
        [_navigator layoutSubviews];
        UIBarButtonItem* delete = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_delete_blue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(deleteSingle)];
        UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_toolbar setItems:@[flexibleSpace,delete] animated:YES];
        [_cameraButton setHidden:YES];
    } else if (_dcsView.imageGalleryView.imageGalleryViewmode == DIVME_MULTIPLE && _isSelectMode == NO) {
        [_navigator popNavigationItemAnimated:NO];
        _navigator.topItem.title = @"Home";
        [_navigator layoutSubviews];
        [_cameraButton setHidden:NO];
        [self setToolbar];
    }
}

- (void)onSelectChanged:(id)sender selectedIndices:(NSArray *)indices {
    if (indices.count > 0) {
        [_toolbar.items[2] setEnabled:YES];
    } else {
        [_toolbar.items[2] setEnabled:NO];
    }
    if (indices.count == _dcsView.buffer.count) {
        _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unselect All" style:UIBarButtonItemStylePlain target:self action:@selector(onUnselectAll)];
        _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    } else {
        _navigator.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectAll)];
        _navigator.topItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:56/255.0 green:148/255.0 blue:226/255.0 alpha:1];
    }
}

- (void)onLongPress:(id)sender index:(NSInteger)index {
}

- (void)onOkTapped:(id)sender exception:(DcsException *)exception {
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    [parentVC showOrHideStatusBar];
    [_navigator setHidden:NO];
    [_toolbar setHidden:NO];
}

- (void)removeBigImage:(UIImage*)image {
    _thumbnailImageView.image = image;
    [_bigImageView removeFromSuperview];
}

- (void)deleteSingle {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete this image?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [_dcsView.buffer delete:_dcsView.buffer.currentIndex];
        NSString* title = [[NSString alloc] initWithFormat:@"%ld/%ld",(_dcsView.buffer.currentIndex+1),_dcsView.buffer.count];
        _navigator.topItem.title = title;
        if (_dcsView.buffer.count == 0) {
            [_dcsView.imageGalleryView addSubview:_emptyHint];
            [_dcsView.imageGalleryView addSubview:_emptyImage];
        }
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)multiMode {
    _dcsView.imageGalleryView.imageGalleryViewmode = DIVME_MULTIPLE;
    [_navigator popNavigationItemAnimated:NO];
    _navigator.topItem.title = @"Home";
    [_navigator layoutSubviews];
    [_cameraButton setHidden:NO];
    [self setToolbar];
}

- (void)enterEdit {
    MainViewController* parentVC = (MainViewController*)self.parentViewController;
    [parentVC showOrHideStatusBar];
    [_navigator setHidden:YES];
    [_toolbar setHidden:YES];
    _dcsView.currentView = DVE_EDITORVIEW;
}

- (void)saveLocalDatas {
    [NSKeyedArchiver archiveRootObject:_localDatas toFile:[LocalData getArchiveURL].path];
}

- (void)setToolbar {
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 93;
    [_toolbar setItems:@[_deleteItem,flexibleSpace,_exportItem,fixedSpace,_uploadItem,flexibleSpace,_archiveItem] animated:YES];
}
@end
