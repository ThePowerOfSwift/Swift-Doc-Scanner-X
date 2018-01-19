//
//  WebViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/11/1.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore


class WebViewController: UIViewController, WKNavigationDelegate {
    // MARK: - Properties
    
    var webView: WKWebView!
    var navigationBar: UINavigationBar!
    let fullScreenSize = UIScreen.main.bounds.size
    let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var refreshControl: UIRefreshControl?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initialize `webView`.
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        let myURL = URL(string: "https://developer.dynamsoft.com/dws/ios-guide")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64)
        webView.allowsBackForwardNavigationGestures = true
        
        /// Initialize `navigationBar`.
        navigationBar = CustomNavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 64))
        navigationItem.title = "Developer Center"
        navigationBar.pushItem(self.navigationItem, animated: true)
        let parentVC = self.parent as? MainViewController
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: .plain, target: parentVC, action: #selector(parentVC?.backToHome))
        
        /// Initialize `refreshControl`.
        refreshControl = UIRefreshControl()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "canGoBack")
    }
    
    func refreshWeb() {
        webView.reload()
        refreshControl?.endRefreshing()
    }
    
    func back(){
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
        webView.evaluateJavaScript("document.getElementById('liveChatMobile').style.visibility='hidden'", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressIndicator.stopAnimating()
        if let err = error as? URLError {
            switch err.code {
            case URLError.timedOut:
                print("timeout")
            case URLError.notConnectedToInternet:
                print("no Internet")
            default:
                print("other error")
            }
        }
    }

}
