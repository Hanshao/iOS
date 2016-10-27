//
//  SHPickerView.swift
//  WifiService
//
//  Created by Shaojun Han on 6/15/16.
//  Copyright © 2016 HadLinks. All rights reserved.
//

import Foundation
import UIKit

@objc(SHPickerView) // 此声明用于声明该类可应用与OC中, 对于继承自NSObject的类型, 此声明可以不写
class SHPickerView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}