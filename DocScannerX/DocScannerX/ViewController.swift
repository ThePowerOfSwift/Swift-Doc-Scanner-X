//
//  ViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/10/9.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, DcsUIVideoViewDelegate, DcsUIImageGalleryViewDelegate, DcsUIDocumentEditorViewDelegate {
    
    // MARK: - Properties
    var dcsView: DcsView!
    var navigator: CustomNavigationBar?
    var toolbar: UIToolbar?
    var menuItem: UIBarButtonItem?
    var deleteItem: UIBarButtonItem?
    var uploadItem: UIBarButtonItem?
    var exportItem: UIBarButtonItem?
    var archiveItem: UIBarButtonItem?
    var localDatas: [LocalData]?
    var isSelectMode: Bool = false
    var progressBackground: UIView?
    var activityBackground: UIView?
    var thumbnailImageView: UIImageView?
    var bigImageView: UIImageView?
    var tapImageGesture: UITapGestureRecognizer?
    var uploadPieces: Int = 0
    var emptyImage: UIImageView?
    var emptyHint: UILabel?
    let progressIndicator = UIProgressView(progressViewStyle: .default)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let cameraButton: UIButton = UIButton(type: .custom)
    let fullScreenSize: CGSize = UIScreen.main.bounds.size
    var heightOffset: CGFloat {
        return (UIApplication.shared.statusBarFrame.height>20) ? 20 : 0
    }
    
    // MARK: - ViewController life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = self.parent!.view.bounds
        
        /// Initialize `navigator`
        navigator = CustomNavigationBar(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 64))
        let parentVC = self.parent as? MainViewController
        menuItem = UIBarButtonItem(image: UIImage(named: "icon_menu")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: parentVC, action: #selector(parentVC?.leftDrawerFromCenter))
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = menuItem
        navigator?.pushItem(navigationItem, animated: true)
        
        /// Set DcsView log level
        DcsView.setLogLevel(DLLE_OFF)
        
        /// Initialize `dcsView`
        dcsView = DcsView(frame: CGRect.init(x: 0, y: 64, width: fullScreenSize.width, height: fullScreenSize.height-64-49))
        
        /// Set delegates
        dcsView.videoView.delegate = self
        dcsView.imageGalleryView.delegate = self
        dcsView.documentEditorView.delegate = self
        
        /// Initialize `dcsView.videoView` and `dcsView.imageGalleryView`
        dcsView.videoView.mode = DME_DOCUMENT
        dcsView.videoView.nextViewAfterCancel = DVE_IMAGEGALLERYVIEW
        dcsView.videoView.nextViewAfterCapture = DVE_VIDEOVIEW
        dcsView.videoView.ifAllowDocumentCaptureWhenNotDetected = true
        dcsView.imageGalleryView.enterManualSortMode()
        
        /// Add `dcsview` and `navigator` as subviews of `view`
        view.addSubview(dcsView)
        view.addSubview(navigator!)
        
        /// Initialize `cameraButton`
        cameraButton.setImage(UIImage(named: "icon_camera_click"), for: .highlighted)
        cameraButton.setImage(UIImage(named: "icon_camera"), for: .normal)
        cameraButton.frame = CGRect(x: 0, y: 0, width: 67, height: 67)
        cameraButton.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height-heightOffset)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        
        /// Initialize `toolbar`
        toolbar = UIToolbar(frame: CGRect(x: 0, y: fullScreenSize.height-49-heightOffset, width: fullScreenSize.width, height: 49))
        toolbar?.barTintColor = UIColor.white
        deleteItem = UIBarButtonItem(image: UIImage(named: "Delete")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(enterDeleteMode))
        uploadItem = UIBarButtonItem(image: UIImage(named: "Upload")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(enterUploadMode))
        exportItem = UIBarButtonItem(image: UIImage(named: "Export")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(enterExportMode))
        archiveItem = UIBarButtonItem(image: UIImage(named: "Save")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(enterArchiveMode))
        setToolbar()

        /// Add `cameraButton` and `toolbar` as subviews of `view`
        view.addSubview(toolbar!)
        view.addSubview(cameraButton)
        
        /// Initialize `thumbnailImageView`
        thumbnailImageView = UIImageView(frame: CGRect(x: 40, y: fullScreenSize.height-31-47, width: 47, height: 47))
        thumbnailImageView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        thumbnailImageView?.clipsToBounds = true
        thumbnailImageView?.isUserInteractionEnabled = true
        tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(showMultiImage))
        thumbnailImageView?.addGestureRecognizer(tapImageGesture!)
        
        /// Add `thumbnailImageView` as a subview of `dcsView.videoView`
        dcsView.videoView.addSubview(thumbnailImageView!)
        
        /// Add `activityIndicator` which indicates saving PDF/PNG/JPEG
        activityIndicator.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/2)
        activityBackground = UIView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height))
        activityBackground?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        activityBackground?.addSubview(activityIndicator)
        
        /// Initialize `progressIndicator` which indicates uploading PDF/PNG/JPEG
        progressIndicator.frame = CGRect(x: 0, y: 0, width: 230, height: 0)
        progressIndicator.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/2)
        progressIndicator.transform = CGAffineTransform(scaleX: 1, y: 5)
        progressIndicator.progressTintColor = UIColor(red: 50/255, green: 148/255, blue: 226/255, alpha: 1)
        progressIndicator.trackTintColor = UIColor(red: 228/255, green: 240/255, blue: 246/255, alpha: 1)
        progressIndicator.clipsToBounds = true
        progressIndicator.layer.masksToBounds = true
        progressIndicator.layer.cornerRadius = 5
        
        /// Initialize `progressBackground`
        progressBackground = UIView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height))
        progressBackground?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        progressBackground?.addSubview(progressIndicator)
        
        /// Initialize `emptyImage` and `emptyHint`
        emptyImage = UIImageView(image: UIImage(named: "empty"))
        emptyImage?.center = CGPoint(x: fullScreenSize.width/2, y: 200)
        emptyHint = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 44))
        emptyHint?.center = CGPoint(x: fullScreenSize.width/2, y: 350)
        emptyHint?.textColor = .gray
        emptyHint?.textAlignment = .center
        emptyHint?.text = "No images yet"
        if dcsView.buffer.count() == 0 {
            dcsView.imageGalleryView.addSubview(emptyHint!)
            dcsView.imageGalleryView.addSubview(emptyImage!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Retrieve local files' information
        localDatas = NSKeyedUnarchiver.unarchiveObject(withFile: LocalData.ArchiveURL.path) as? [LocalData] ?? [LocalData]()
        /// Add KVO for `dcsView.buffer.currentIndex`
        dcsView.buffer.addObserver(self, forKeyPath: "currentIndex", options: .new, context: nil)
        /// Add observer for StatusBar height change
        NotificationCenter.default.addObserver(self, selector: #selector(adjustUIWhenCalling), name: NSNotification.Name(rawValue: "UIApplicationDidChangeStatusBarFrameNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Remove KVO for `dcsView.buffer.currentIndex`
        dcsView.buffer.removeObserver(self, forKeyPath: "currentIndex")
        /// Remove observer for StatusBar height change
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIApplicationDidChangeStatusBarFrameNotification"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Observer functions
    
    /// Adjust UI when StatusBar height change.
    func adjustUIWhenCalling() {
        if UIApplication.shared.statusBarFrame.height>20 {
            dcsView.frame.size.height = dcsView.frame.size.height - 20
            toolbar!.frame.origin.y = toolbar!.frame.origin.y - 20
            cameraButton.center.y = cameraButton.center.y - 20
        } else {
            dcsView.frame.size.height = dcsView.frame.size.height + 20
            toolbar!.frame.origin.y = toolbar!.frame.origin.y + 20
            cameraButton.center.y = cameraButton.center.y + 20
        }
    }
    
    /// Change title when `dcsView.buffer.currentIndex` change.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if dcsView.imageGalleryView.imageGalleryViewmode == DIVME_SINGLE {
            let title = (dcsView.buffer.currentIndex+1).description+"/"+dcsView.buffer.count().description
            navigator?.topItem?.title = title
        }
    }
    
    // MARK: - Button Actions
    
    func enterDeleteMode() {
        dcsView.imageGalleryView.enterSelectMode()
        isSelectMode = true
        cameraButton.isHidden = true
        navigator?.topItem?.title = "Delete"
        navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(onSelectAll))
        navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(onDelete))
        delete.isEnabled = false
        cancel.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        delete.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar?.setItems([cancel, flexibleSpace, delete], animated: true)
    }
    
    func onDelete() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: deleteImage)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func enterUploadMode() {
        dcsView.imageGalleryView.enterSelectMode()
        isSelectMode = true
        cameraButton.isHidden = true
        onSelectAll()
        navigator?.topItem?.title = "Upload"
        navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Unselect All", style: .plain, target: self, action: #selector(onUnselectAll))
        navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        let upload = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(onUpload))
        upload.isEnabled = dcsView.buffer.count()>0
        cancel.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        upload.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar?.setItems([cancel, flexibleSpace, upload], animated: true)
    }
    
    func onUpload() {
        let alertController = UIAlertController(title: "Upload to server.", message: nil, preferredStyle: .actionSheet)
        let pngAction = UIAlertAction(title: "PNG", style: .default, handler: uploadAsPNG)
        let jpgAction = UIAlertAction(title: "JPEG", style: .default, handler: uploadAsJPEG)
        let pdfAction = UIAlertAction(title: "PDF", style: .default, handler: uploadAsPDF)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.onCancel()
        })
        alertController.addAction(pngAction)
        alertController.addAction(jpgAction)
        alertController.addAction(pdfAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func enterExportMode() {
        dcsView.imageGalleryView.enterSelectMode()
        isSelectMode = true
        cameraButton.isHidden = true
        onSelectAll()
        navigator?.topItem?.title = "Share"
        navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Unselect All", style: .plain, target: self, action: #selector(onUnselectAll))
        navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        let export = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(onExport))
        export.isEnabled = dcsView.buffer.count()>0
        cancel.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        export.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar?.setItems([cancel, flexibleSpace, export], animated: true)
    }
    
    func onExport() {
        var images = [UIImage]()
        for index in dcsView.imageGalleryView.selectedIndices {
            images.append((dcsView.buffer.get(index as! Int) as! DcsDocument).uiImage())
        }
        let activityVC = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (_, _, _, _) in
            self.onCancel()
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    func enterArchiveMode() {
        dcsView.imageGalleryView.enterSelectMode()
        isSelectMode = true
        cameraButton.isHidden = true
        onSelectAll()
        navigator?.topItem?.title = "Save"
        navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Unselect All", style: .plain, target: self, action: #selector(onUnselectAll))
        navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        let archive = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onArchive))
        archive.isEnabled = dcsView.buffer.count()>0
        cancel.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        archive.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar?.setItems([cancel, flexibleSpace, archive], animated: true)
    }
    
    func onArchive() {
        let alertController = UIAlertController(title: "Save to local file", message: nil, preferredStyle: .actionSheet)
        let pngAction = UIAlertAction(title: "PNG", style: .default, handler: archiveAsPNG)
        let jpgAction = UIAlertAction(title: "JPEG", style: .default, handler: archiveAsJPEG)
        let pdfAction = UIAlertAction(title: "PDF", style: .default, handler: archiveAsPDF)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.onCancel()
        })
        alertController.addAction(pngAction)
        alertController.addAction(jpgAction)
        alertController.addAction(pdfAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// Quit SelectMode and complete UI adjustment.
    func onCancel() {
        dcsView.imageGalleryView.enterManualSortMode()
        isSelectMode = false
        cameraButton.isHidden = false
        navigator?.topItem?.title = "Home"
        navigator?.topItem?.rightBarButtonItem = nil
        setToolbar()
    }
    
    /// Select all images in `dcsView.imageGalleryView`.
    func onSelectAll() {
        for i in 0..<dcsView.buffer.count() {
            dcsView.imageGalleryView.selectedIndices.append(i)
        }
    }
    
    /**
     Unselect all by `dcsView.imageGalleryView.selectedIndices = nil`
     while you can't achive the same goal by `dcsView.imageGalleryView.selectedIndices.removeAll()`.
     */
    func onUnselectAll() {
        dcsView.imageGalleryView.selectedIndices = nil
    }
    
    func cameraButtonTapped() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .authorized {
            let alert = UIAlertController(title: "Doc-Scanner-X want to access your camera", message: "To scan documents using your device, Doc-Scanner-X needs access to your camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.show(alert, sender: nil)
        } else {
            navigator?.isHidden = true
            toolbar?.isHidden = true
            cameraButton.isHidden = true
            let parentVC = parent as? MainViewController
            parentVC?.showOrHideStatusBar()
            /// Just set `dcsView.currentView = DVE_VIDEOVIEW` to show `dcsView.videoView`
            dcsView.currentView = DVE_VIDEOVIEW
            dcsView.videoView.cancelText = "Cancel"
            thumbnailImageView?.image = nil
        }
    }
    
    /**
     Set `dcsView.currentView = DVE_IMAGEGALLERYVIEW` and `dcsView.imageGalleryView.imageGalleryViewmode = DIVME_MULTIPLE` 
     to show `dcsView.imageGalleryView` in multiImage mode.
     */
    func showMultiImage() {
        dcsView.currentView = DVE_IMAGEGALLERYVIEW
        let parentVC = parent as? MainViewController
        parentVC?.showOrHideStatusBar()
        navigator?.isHidden = false
        toolbar?.isHidden = false
        cameraButton.isHidden = false
    }

    // MARK: - DcsUIVideoViewDelegate
    
    func onDocumentDetected(_ sender: Any!, document: DcsDocument!) {
    }
    
    /**
     When user tap cancelButton in `dcsView.videoView` or `dcsView.imageEditorView` or 
     `dcsView.documentEditorView`, this callback will be called.
     */
    func onCancelTapped(_ sender: Any!) {
        let parentVC = parent as? MainViewController
        parentVC?.showOrHideStatusBar()
        navigator?.isHidden = false
        toolbar?.isHidden = false
        if sender is DcsUIVideoView {
            cameraButton.isHidden = false
        } else if sender is DcsUIImageEditorView || sender is DcsUIDocumentEditorView {
            cameraButton.isHidden = true
        }
    }
    
    func onCaptureTapped(_ sender: Any!) {
    }
    
    /// Return true to continue capture
    func onPreCapture(_ sender: Any!) -> Bool {
        return true
    }
    
    /// After capturing, remove `empty[Hint,Image]` if in need.
    func onPostCapture(_ sender: Any!, image: DcsImage!) {
        DispatchQueue.main.async {
            self.bigImageView = UIImageView(frame: CGRect(x: 70, y: 145, width: 235, height: 376))
            self.bigImageView?.backgroundColor = .clear
            self.bigImageView?.image = image.uiImage()
            self.dcsView.videoView.addSubview(self.bigImageView!)
            self.perform(#selector(self.removeBigImage), with: image.uiImage(), afterDelay: 0.5)
            UIView.animate(withDuration: 0.5, animations: {
                self.bigImageView?.transform = CGAffineTransform(scaleX: 0.2, y: 0.125)
                self.bigImageView?.frame.origin = self.thumbnailImageView!.frame.origin
            })
            self.dcsView.videoView.cancelText = "Done"
            if let _ = self.emptyHint?.superview {
                self.emptyHint?.removeFromSuperview()
                self.emptyImage?.removeFromSuperview()
            }
        }
    }
    
    func onCaptureFailure(_ sender: Any!, exception: DcsException!) {
    }
    
    // MARK: - DcsUIImageGalleryViewDelegate
    
    /**
     When user tap any images in `dcsView.imageGalleryView`, this callback will be called.
     Through `dcsView.imageGalleryView.imageGalleryViewmode` to determine in which mode we are, then do corresponding adjustment.
     */
    func onSingleTap(_ sender: Any!, index: Int) {
        if dcsView.imageGalleryView.imageGalleryViewmode == DIVME_SINGLE {
            let title = (dcsView.buffer.currentIndex+1).description+"/"+dcsView.buffer.count().description
            navigator?.pushItem(UINavigationItem(title: title), animated: false)
            navigator?.topItem?.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(multiMode))
            navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(enterEdit))
            navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 50/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
            navigator?.layoutSubviews()
            let delete = UIBarButtonItem(image: UIImage(named: "icon_delete_blue")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: self, action: #selector(deleteSingle(_:)))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar?.setItems([flexibleSpace, delete], animated: true)
            cameraButton.isHidden = true
        } else if dcsView.imageGalleryView.imageGalleryViewmode == DIVME_MULTIPLE && isSelectMode == false{
            navigator!.popItem(animated: false)
            navigator?.topItem?.title = "Home"
            navigator?.layoutSubviews()
            cameraButton.isHidden = false
            setToolbar()
        }
    }
    
    /// When `dcsView.imageGalleryView.selectedIndices` changed, do corresponding adjustment.
    func onSelectChanged(_ sender: Any!, selectedIndices indices: [Any]!) {
        if indices.count > 0 {
            toolbar?.items?[2].isEnabled = true
        } else {
            toolbar?.items?[2].isEnabled = false
        }
        if indices.count == self.dcsView.buffer.count() {
            self.navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Unselect All", style: .plain, target: self, action: #selector(onUnselectAll))
            navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        } else {
            self.navigator?.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(onSelectAll))
            navigator?.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        }
    }
    
    func onLongPress(_ sender: Any!, index: Int) {
    }
    
    // MARK: - DcsUIDocumentEditorViewDelegate
    
    func onOkTapped(_ sender: Any!, exception: DcsException!) {
        let parentVC = parent as? MainViewController
        parentVC?.showOrHideStatusBar()
        navigator?.isHidden = false
        toolbar?.isHidden = false
    }
    
    // MARK: - Private Methods
    
    /**
     Delete selected images through `dcsView.buffer.delete`.
     After deleting all images, show `emptyHint` and `emptyImage`.
     */
    private func deleteImage(_: UIAlertAction) {
        while dcsView.imageGalleryView.selectedIndices.count>0 {
            dcsView.buffer.delete(self.dcsView.imageGalleryView.selectedIndices[0] as! Int)
        }
        onCancel()
        if dcsView.buffer.count() == 0 {
            dcsView.imageGalleryView.addSubview(emptyHint!)
            dcsView.imageGalleryView.addSubview(emptyImage!)
        }
    }
    
    /**
     When viewing single image in `dcsView.imageGalleryView` and tap delete, an UIAlertController appears.
     If user choose **Delete**, then delete that images and change title in the meantime.
     */
    @objc private func deleteSingle(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete this image?", message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {_ in
            self.dcsView.buffer.delete(self.dcsView.buffer.currentIndex)
            let title = (self.dcsView.buffer.currentIndex+1).description+"/"+self.dcsView.buffer.count().description
            self.navigator?.topItem?.title = title
            /// After deleting all images, show `emptyHint` and `emptyImage`.
            if self.dcsView.buffer.count() == 0 {
                self.dcsView.imageGalleryView.addSubview(self.emptyImage!)
                self.dcsView.imageGalleryView.addSubview(self.emptyHint!)
                sender.isEnabled = false
                sender.image = UIImage(named: "icon_delete_blue")
                self.navigator?.topItem?.rightBarButtonItem?.isEnabled = false
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    /**
     Called after capturing and animation.
    */
    @objc private func removeBigImage(_ image: UIImage) {
        thumbnailImageView?.image = image
        bigImageView?.removeFromSuperview()
    }
    
    /**
     Upload images as PNG or JPEG to server recursively.
     */
    private func uploadAsPNG(_: UIAlertAction) {
        view.addSubview(progressBackground!)
        if let indices = dcsView.imageGalleryView.selectedIndices as NSArray as? [Any] {
            onCancel()
            recursive(0, indices: indices, encodeFormat: DcsPNGEncodeParameter())
        }
    }
    
    private func uploadAsJPEG(_: UIAlertAction) {
        view.addSubview(progressBackground!)
        if let indices = dcsView.imageGalleryView.selectedIndices as NSArray as? [Any] {
            onCancel()
            recursive(0, indices: indices, encodeFormat: DcsJPEGEncodeParameter())
        }
    }
    
    /**
     Upload PNG or JPEG to server one by one in background thread. No matter one image uploading successfully or unsuccessfully, continue 
     until `pieces == indices.count`.
     After recursive completed, compare `self.uploadPieces` with `indices.count` to determine the final uploading result.
     - Parameters:
        - pieces: Current uploading image index
        - indices: The array which contains images index which need to be uploaded
        - encodeFormat: Image encode format
     */
    private func recursive(_ pieces: Int, indices: [Any], encodeFormat: DcsEncodeParameter) {
        var perImageProgress = 0
        if pieces<indices.count{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
            dateFormatter.timeZone = TimeZone.current
            let dataTimeStamp = dateFormatter.string(from: Date())
            let uploadConfig = DcsHttpUploadConfig()
            uploadConfig.uploadMethod = DUME_POST
            uploadConfig.filePrefix = dataTimeStamp.replacingOccurrences(of: ":", with: "")
            uploadConfig.dataFormat = DDFE_BINARY
            uploadConfig.url = "https://your.upload.server"
            /// Server save user's UUID and corresponding files, so that others can't see your files.
            uploadConfig.formField = ["userId": KeyChainManager.readUUID()!, "filePureName": uploadConfig.filePrefix]
            dcsView.io.uploadAsync([indices[pieces]], uploadConfig: uploadConfig, encodeParameter: encodeFormat, successCallback: { (_) in
                self.recursive(pieces+1, indices: indices, encodeFormat: encodeFormat)
                self.uploadPieces += 1
                }, failureCallback: { (_, _) in
                    self.recursive(pieces+1, indices: indices, encodeFormat: encodeFormat)
                }, progressUpdateCallback: { (progress) -> Bool in
                    DispatchQueue.main.async {
                        self.progressIndicator.progress += Float(progress-perImageProgress)/Float(100*indices.count)
                        perImageProgress = progress
                    }
                    return true
            })
        } else {
            DispatchQueue.main.async {
                self.progressBackground!.removeFromSuperview()
                self.progressIndicator.progress = 0
                if self.uploadPieces == indices.count {
                    self.uploadCompletionHandler(with: "Upload completed")
                } else if self.uploadPieces == 0 {
                    self.uploadCompletionHandler(with: "Upload failed")
                } else {
                    self.uploadCompletionHandler(with: "Upload failed for some of the files")
                }
                self.uploadPieces = 0
            }
            return
        }
    }
    
    /// Upload images as PDF to server asynchronously.
    private func uploadAsPDF(_: UIAlertAction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
        dateFormatter.timeZone = TimeZone.current
        let dataTimeStamp = dateFormatter.string(from: Date())
        if let indices = dcsView.imageGalleryView.selectedIndices as NSArray as? [Any] {
            let uploadConfig = DcsHttpUploadConfig()
            uploadConfig.uploadMethod = DUME_POST
            uploadConfig.filePrefix = dataTimeStamp.replacingOccurrences(of: ":", with: "")
            uploadConfig.dataFormat = DDFE_BINARY
            uploadConfig.url = "https://your.upload.server"
            uploadConfig.formField = ["userId": KeyChainManager.readUUID()!, "filePureName": uploadConfig.filePrefix]
            view.addSubview(progressBackground!)
            onCancel()
            dcsView.io.uploadAsync(indices, uploadConfig: uploadConfig, encodeParameter: DcsPDFEncodeParameter(), successCallback: { (_) in
                DispatchQueue.main.async {
                    self.progressBackground!.removeFromSuperview()
                    self.progressIndicator.progress = 0
                    self.uploadCompletionHandler(with: "Upload completed")
                }
                }, failureCallback: { (_, myException) in
                    DispatchQueue.main.async {
                        self.progressBackground!.removeFromSuperview()
                        self.progressIndicator.progress = 0
                        if myException?.reason == "The file size exceeded the 50MB limit." {
                            self.uploadCompletionHandler(with: "Exceeded the 50MB limit")
                        } else {
                            self.uploadCompletionHandler(with: "Upload failed")
                        }
                    }
                }, progressUpdateCallback: { (progress) -> Bool in
                    DispatchQueue.main.async {
                        self.progressIndicator.setProgress(Float(progress)/100.0, animated: true)
                    }
                    return true
            })
        }
    }
    
    /**
     After upload completed, show result and determine whether do view change according to result.
     - Parameter result: Uploading results
     */
    private func uploadCompletionHandler(with result: String) {
        let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.5, execute: {
            if result == "Upload completed" || result == "Upload failed for some of the files"{
                self.presentedViewController?.dismiss(animated: true, completion: {
                    let parentVC = self.parent as? MainViewController
                    parentVC?.backAfterUpload()
                })
            } else {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    /// Archive images as PNG or JPEG or PDF files to APP's sandbox, and also save files information in APP's sandbox.
    private func archiveAsPNG(_: UIAlertAction) {
        view.addSubview(activityBackground!)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.dcsView.imageGalleryView.selectedIndices {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
                dateFormatter.timeZone = TimeZone.current
                let dataTimeStamp = dateFormatter.string(from: Date())
                let dataName = dataTimeStamp.replacingOccurrences(of: ":", with: "") + ".png"
                let dataType = FileType.PNG.rawValue
                let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+dataName)
                self.dcsView.io.save([index], file: path.path, encodeParameter: DcsPNGEncodeParameter())
                self.localDatas?.append(LocalData(dataName: dataName, dataType: dataType, dataTimeStamp: dataTimeStamp))
            }
            self.saveLocalDatas()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityBackground!.removeFromSuperview()
                self.onCancel()
                self.archiveCompletionHandler(with: "Save completed")
            }
        }
    }
    
    private func archiveAsJPEG(_: UIAlertAction) {
        view.addSubview(activityBackground!)
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            for index in self.dcsView.imageGalleryView.selectedIndices {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
                dateFormatter.timeZone = TimeZone.current
                let dataTimeStamp = dateFormatter.string(from: Date())
                let dataName = dataTimeStamp.replacingOccurrences(of: ":", with: "") + ".jpg"
                let dataType = FileType.JPEG.rawValue
                let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+dataName)
                self.dcsView.io.save([index], file: path.path, encodeParameter: DcsJPEGEncodeParameter())
                self.localDatas?.append(LocalData(dataName: dataName, dataType: dataType, dataTimeStamp: dataTimeStamp))
            }
            self.saveLocalDatas()
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityBackground!.removeFromSuperview()
                self.onCancel()
                self.archiveCompletionHandler(with: "Save completed")
            }
        }
    }
    
    private func archiveAsPDF(_: UIAlertAction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
        dateFormatter.timeZone = TimeZone.current
        let dataTimeStamp = dateFormatter.string(from: Date())
        let dataName = dataTimeStamp.replacingOccurrences(of: ":", with: "") + ".pdf"
        let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+dataName)
        let dataType = FileType.PDF.rawValue
        if let indices = dcsView.imageGalleryView.selectedIndices as NSArray as? [Any] {
            view.addSubview(activityBackground!)
            activityIndicator.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try OCExceptionCatcher.captureException({
                        self.dcsView.io.save(indices, file: path.path, encodeParameter: DcsPDFEncodeParameter())
                    })
                    self.localDatas?.append(LocalData(dataName: dataName, dataType: dataType, dataTimeStamp: dataTimeStamp))
                    self.saveLocalDatas()
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityBackground!.removeFromSuperview()
                        self.onCancel()
                        self.archiveCompletionHandler(with: "Save completed")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityBackground!.removeFromSuperview()
                        self.onCancel()
                        self.archiveCompletionHandler(with: "Exceeded the 50MB limit")
                    }
                }
            }
        }
    }
    
    /// After archive completed, show result and go to Archived Files view controller.
    private func archiveCompletionHandler(with result: String) {
        let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2.5, execute: {
            if result == "Exceeded the 50MB limit" {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.presentedViewController?.dismiss(animated: true, completion: {
                    let parentVC = self.parent as? MainViewController
                    parentVC?.backAfterArchive()
                })
            }
        })
    }
    
    /// Enter multiple mode and do UI adjustment.
    @objc private func multiMode() {
        dcsView.imageGalleryView.imageGalleryViewmode = DIVME_MULTIPLE
        navigator!.popItem(animated: false)
        navigator?.topItem?.title = "Home"
        navigator?.layoutSubviews()
        cameraButton.isHidden = false
        setToolbar()
    }
    
    /// Set `dcsView.currentView = DVE_EDITORVIEW` in order to enter editor view.
    @objc private func enterEdit() {
        let parentVC = parent as? MainViewController
        parentVC?.showOrHideStatusBar()
        navigator?.isHidden = true
        toolbar?.isHidden = true
        dcsView.currentView = DVE_EDITORVIEW
    }
    
    /// Save files information in APP's sandbox.
    private func saveLocalDatas() {
       NSKeyedArchiver.archiveRootObject(localDatas!, toFile: LocalData.ArchiveURL.path)
        
    }
    
    /// Set toolbar interface
    private func setToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace3 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace3.width = 93
        toolbar?.setItems([deleteItem!, flexibleSpace, exportItem!, fixedSpace3, uploadItem!, flexibleSpace, archiveItem!], animated: true)
    }
}

