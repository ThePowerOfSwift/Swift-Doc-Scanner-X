//
//  UploadedFileViewController.swift
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2017/12/1.
//  Copyright © 2017年 Dynamsoft. All rights reserved.
//

import UIKit
import WebKit

class UploadedFileViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties
    let fullScreenSize = UIScreen.main.bounds.size
    var webView: WKWebView!
    var navigationBar: UINavigationBar!
    let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Initialize `webView`.
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64)
        
        /// Initialize `navigationBar`.
        navigationBar = CustomNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
        self.navigationItem.title = "Uploaded Files"
        navigationBar.pushItem(self.navigationItem, animated: true)
        let parentVC = parent as? MainViewController
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: parentVC, action: #selector(parentVC?.backToHome))
        
        /// Initialize `refreshControl`.
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 44, width: fullScreenSize.width, height: 44))
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refreshWeb), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl!)
        
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        /// Add `navigationBar` and `webView` as subviews of `view`.
        view.addSubview(navigationBar)
        view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Refresh `webView` when user enter this view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        let myURL = URL(string: "https://demo.dynamsoft.com/DCS_Mobile/filesList.html?userId="+KeyChainManager.readUUID()!)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "canGoBack")
    }
    
    func refreshWeb() {
        webView.reload()
    }
    
    func back() {
        webView.goBack()
    }
    
    // MARK: - Observer function
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if webView.canGoBack {
            navigationItem.leftBarButtonItem?.target = self
            navigationItem.leftBarButtonItem?.action = #selector(back)
        } else {
            let parentVC = parent as? MainViewController
            navigationItem.leftBarButtonItem?.target = parentVC
            navigationItem.leftBarButtonItem?.action = #selector(parentVC?.backToHome)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        progressIndicator.backgroundColor = UIColor.clear
        progressIndicator.center = CGPoint(x: fullScreenSize.width/2, y: fullScreenSize.height/2)
        progressIndicator.hidesWhenStopped = true
        view.addSubview(progressIndicator)
        progressIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressIndicator.stopAnimating()
        refreshControl?.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressIndicator.stopAnimating()
        refreshControl?.endRefreshing();
    }
}
