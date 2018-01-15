//
//  QuickLookViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/11/6.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit
import WebKit

/**
 It's used to mark file type when save files in APP's sandbox.
 */
enum FileType: UInt {
    case PNG, JPEG, PDF
}


class QuickLookViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    var imageView: UIImageView?
    var webView: WKWebView?
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 244/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - WKNavigationDelegate
    
    /**
     When use WKWebView to load local PDF, PDF's background is grey.
     This function is for changing PDF's background.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        var v: UIView? = webView as UIView
        while v != nil {
            v?.backgroundColor = UIColor.clear
            v = v?.subviews.first
        }
    }
    
    /**
     Present file which is saved in APP's sandbox.
     
     - Parameters:
        - type: File type
        - dataName: File name
     */
    func quickLook(type: UInt, in dataName: String) {
        let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+dataName)
        switch type {
        case FileType.PNG.rawValue, FileType.JPEG.rawValue:
            imageView = UIImageView(frame: CGRect(x: 0, y: 64, width: fullScreenSize.width, height: fullScreenSize.height-64))
            imageView?.image = UIImage(contentsOfFile: path.path)
            imageView?.contentMode = .scaleAspectFit
            view.addSubview(imageView!)
        case FileType.PDF.rawValue:
            webView = WKWebView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64))
            webView?.navigationDelegate = self
            webView!.loadFileURL(path, allowingReadAccessTo: path)
            view.addSubview(webView!)
        default:
            fatalError("falied!!!!!!!!!!")
        }
    }
}
