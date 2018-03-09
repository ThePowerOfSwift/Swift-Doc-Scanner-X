//
//  CenterViewController.h
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/11/27.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

#import "DynamsoftCameraSDK.framework/Headers/DcsView.h"
#import "DynamsoftCameraSDK.framework/Headers/DcsUIVideoView.h"
#import "DynamsoftCameraSDK.framework/Headers/DcsUIImageGalleryView.h"
#import "DynamsoftCameraSDK.framework/Headers/DcsUIDocumentEditorView.h"
#import "DynamsoftCameraSDK.framework/Headers/DcsIo.h"
#import "LocalData.h"
#import "CustomNavigationBar.h"
#import "MainViewController.h"
#import "KeyChainManager.h"
#import <UIKit/UIKit.h>


@interface CenterViewController : UIViewController<DcsUIVideoViewDelegate, DcsUIImageGalleryViewDelegate, DcsUIDocumentEditorViewDelegate>

#pragma mark Properties

@property (nonnull) DcsView* dcsView;

@property (nonnull) UIButton* cameraButton;

@property (nonnull) CustomNavigationBar* navigator;

@property (nonnull) UIToolbar* toolbar;

@property (nonnull) UIBarButtonItem* menuItem;

@property (nonnull) UIBarButtonItem* exportItem;

@property (nonnull) UIBarButtonItem* deleteItem;

@property (nonnull) UIBarButtonItem* uploadItem;

@property (nonnull) UIBarButtonItem* archiveItem;

@property (nullable) NSMutableArray<LocalData*>* localDatas;

@property (readonly, nonatomic) CGSize fullScreenSize;

@property (nonatomic) BOOL isSelectMode;

@property (nullable) UIProgressView* progressIndicator;

@property (nullable) UIView* progressBackground;

@property (nullable) UILabel* emptyHint;

@property (nullable) UIImageView* emptyImage;

@property (nonnull) UIImageView* thumbnailImageView;

@property (nonnull) UIImageView* bigImageView;

@property (nonnull) UITapGestureRecognizer* tapImageGesture;

@property (nullable) UIView* activityBackground;

@property (nullable) UIActivityIndicatorView* activityIndicator;

@end
