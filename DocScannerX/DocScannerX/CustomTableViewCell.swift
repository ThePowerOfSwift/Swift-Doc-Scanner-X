//
//  CustomTableViewCell.swift
//  Doc-Scanner-X
//
//  Created by dynamsoft on 2018/1/4.
//  Copyright © 2018年 Dynamsoft. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    /// Override `layoutSubviews` to customize tableView cell appearce.
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 17, y: 17, width: 60, height: 60)
        if (self.imageView?.image?.size.width)! > 0 {
            self.textLabel!.frame = CGRect(x: 87, y: self.textLabel!.frame.origin.y, width: self.textLabel!.frame.width, height: self.textLabel!.frame.height)
            self.detailTextLabel!.frame = CGRect(x: 87, y: self.detailTextLabel!.frame.origin.y, width: self.detailTextLabel!.frame.width, height: self.detailTextLabel!.frame.height)
        }
    }

}
