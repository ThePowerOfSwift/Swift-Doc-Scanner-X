//
//  LocalFileViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/11/1.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit

class LocalFileViewController: UINavigationController {

    // MARK: - Properties
    
    var tableViewVC: LocalFileTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initialize `tableViewVC` and it's root view controller of UINavigationController.
        tableViewVC = LocalFileTableViewController(style: .plain)
        pushViewController(tableViewVC!, animated: true)
        let parentVC = self.parent as? MainViewController
        if #available(iOS 11, *) {
            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "icon_back"), for: .normal)
            backButton.addTarget(parentVC, action: #selector(parentVC?.backToHome), for: .touchUpInside)
            backButton.imageEdgeInsets.left = -14
            tableViewVC!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        } else {
            tableViewVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: parentVC, action: #selector(parentVC?.backToHome))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
