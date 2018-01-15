//
//  CustomNavigationBar.swift
//  DocScannerX
//
//  Created by Dynamsoft on 21/11/2017.
//  Copyright © 2017 Dynamsoft. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            for view in subviews {
                if NSStringFromClass(view.classForCoder).contains("Background") {
                    view.frame = self.bounds
                } else if NSStringFromClass(view.classForCoder).contains("ContentView") {
                    view.frame = CGRect(x: 0, y: 20, width: self.frame.width, height: self.frame.height-20)
                }
            }
        }
    }
}
