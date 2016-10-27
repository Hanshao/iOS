//
//  SHPopView.swift
//  WifiService
//
//  Created by Shaojun Han on 6/15/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

import Foundation
import UIKit

@objc(SHPopView)
class SHPopView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame:frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class func 你好() -> String {
        let viewCtrl = UIViewController()
        viewCtrl.view.addSubview(self.init())
        return "你好"
    }
}
