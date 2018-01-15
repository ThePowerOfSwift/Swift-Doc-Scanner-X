//
//  MainViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/10/31.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LeftDrawerDelegate {

    // MARK: - Properties
    var centerVC: ViewController?
    var leftVC: LeftDrawerViewController?
    var trickButton: UIButton?
    var webVC: WebViewController?
    var fileVC: LocalFileViewController?
    var uploadVC: UploadedFileViewController?
    var isStatusBarHidden: Bool = false
    /**
     This property belongs to View Controller, and is read-only. It determines whether StatusBar in this View Controller is hidden.
     Override this property and return another read-write property in it's getter. In this way I can hide or show StatusBar
     any time.
     */
    override var prefersStatusBarHidden: Bool {
        get{
            return isStatusBarHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerVC = ViewController()
        leftVC = LeftDrawerViewController()
        leftVC?.delegate = self
        webVC = WebViewController()
        fileVC = LocalFileViewController()
        uploadVC = UploadedFileViewController()
        self.addChildViewController(centerVC!)
        self.view.addSubview(centerVC!.view)
        self.addChildViewController(leftVC!)
        self.view.addSubview(leftVC!.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Every time when I need to show or hide StatusBar, its status is definitely the opposite.
     Thus there is no need to give this function a parameter. Just go to the opposite.
     */
    func showOrHideStatusBar() {
        isStatusBarHidden = !isStatusBarHidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    /**
     Show left drawer menu when user tap menu button in centerVC.
     And add a `trickButton` to centerVC which cover the whole. As its name, it's a trick.
     */
    func leftDrawerFromCenter() {
        UIView.animate(withDuration: 0.3, animations: {
            for vc in self.childViewControllers {
                vc.view.transform = CGAffineTransform(translationX: 200, y: 0)
            }
        })
        trickButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        trickButton?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        trickButton?.addTarget(self, action: #selector(back), for: .touchUpInside)
        centerVC?.view.addSubview(trickButton!)
        
    }
    
    /// Show `centerVC.view`.
    func backToHome() {
        centerVC?.view.transform = CGAffineTransform(translationX: 0, y: 0)
        for vc in childViewControllers {
            if vc === leftVC! {
                continue
            } else {
                vc.removeFromParentViewController()
                vc.view.removeFromSuperview()
            }
        }
        self.addChildViewController(centerVC!)
        self.view.addSubview(centerVC!.view)
        leftVC?.tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
    /// Show `uploadVC.view`.
    func backAfterUpload() {
        for vc in childViewControllers {
            if vc === leftVC! {
                continue
            } else {
                vc.removeFromParentViewController()
                vc.view.removeFromSuperview()
            }
        }
        self.addChildViewController(uploadVC!)
        self.view.addSubview(uploadVC!.view)
        leftVC?.tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
    /// Show `fileVC.view`.
    func backAfterArchive() {
        for vc in childViewControllers {
            if vc === leftVC! {
                continue
            } else {
                vc.removeFromParentViewController()
                vc.view.removeFromSuperview()
            }
        }
        self.addChildViewController(fileVC!)
        self.view.addSubview(fileVC!.view)
        fileVC?.tableViewVC?.reload()
        leftVC?.tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
    /// Close left drawer menu.
    @objc func back() {
        trickButton?.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            for vc in self.childViewControllers {
                vc.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        })
    }
    
    // MARK: - LeftDrawerDelegate
    func selectMenuWithIndex(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            for vc in self.childViewControllers {
                if vc === leftVC! {
                    continue
                } else {
                    vc.removeFromParentViewController()
                    vc.view.removeFromSuperview()
                }
            }
            self.addChildViewController(centerVC!)
            self.view.addSubview(centerVC!.view)
            back()
        case 1:
            for vc in self.childViewControllers {
                if vc === leftVC! {
                    continue
                } else {
                    vc.removeFromParentViewController()
                    vc.view.removeFromSuperview()
                }
            }
            self.addChildViewController(fileVC!)
            self.view.addSubview(fileVC!.view)
            back()
            fileVC?.tableViewVC?.reload()
        case 2:
            for vc in self.childViewControllers {
                if vc === leftVC! {
                    continue
                } else {
                    vc.removeFromParentViewController()
                    vc.view.removeFromSuperview()
                }
            }
            self.addChildViewController(uploadVC!)
            self.view.addSubview(uploadVC!.view)
            back()
        case 3:
            for vc in self.childViewControllers {
                if vc === leftVC! {
                    continue
                } else {
                    vc.removeFromParentViewController()
                    vc.view.removeFromSuperview()
                }
            }
            self.addChildViewController(webVC!)
            self.view.addSubview(webVC!.view)
            back()
        default:
            fatalError("Wrong select")
        }
    }
}
