//
//  LeftDrawerViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/10/31.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit


/**
 The leftDrawerDelegate protocol help you implement custom behaviors which
 are triggered when user when user choose option in left drawer menu.
 */
protocol LeftDrawerDelegate {
    /**
     Called when user tap option in left drawer menu.
     - Parameter indexPath: Selected row index path
     */
    func selectMenuWithIndex(_ indexPath: IndexPath)
}

class LeftDrawerViewController: UITableViewController {
    
    // MARK: -Properties
    
    var delegate: LeftDrawerDelegate?
    let choice = ["Home", "Saved Files", "Uploaded Files", "Developer Center"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initialize `tableView`.
        clearsSelectionOnViewWillAppear = false
        tableView.frame = CGRect(x: -200, y: 0, width: 200, height: fullScreenSize.height)
        tableView.rowHeight = 58
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choice.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 11, *) {
            return 44
        } else {
            return 64
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = choice[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1)
        cell.textLabel?.highlightedTextColor = UIColor(red: 56/255.0, green: 148/255.0, blue: 226/255.0, alpha: 1)
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectMenuWithIndex(indexPath)
    }
}
