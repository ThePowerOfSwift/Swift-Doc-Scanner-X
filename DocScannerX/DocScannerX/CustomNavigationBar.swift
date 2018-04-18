//
//  CustomNavigationBar.swift
//  DocScannerX
//
//  Created by Dynamsoft on 21/11/2017.
//  Copyright © 2017 Dynamsoft. All rights reserved.
//

import UIKit

fileprivate let navigationBarHeight: CGFloat = (UIScreen.main.bounds.height == 812) ? 88 : 64

class CustomNavigationBar: UINavigationBar {
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: navigationBarHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 11.0, *) {
            for view in subviews {
                if NSStringFromClass(view.classForCoder).contains("Background") {
                    view.frame = self.bounds
                } else if NSStringFromClass(view.classForCoder).contains("ContentView") {
                    view.frame = CGRect(x: 0, y: self.frame.height-44, width: self.frame.width, height: 44)
                }
            }
        }
    }
}
