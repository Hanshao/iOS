//
//  ImagePicker.swift
//  Helper
//
//  Created by Shaojun Han on 9/23/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

import Foundation
import UIKit

@objc
public class MyImagePickerController : UIImagePickerController, UINavigationControllerDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
//        addSomeElements(viewController)
//    }
//    
//    internal func findView(view:UIView?, name:String)->UIView? {
//        
//        if ((view?.isKindOfClass(NSClassFromString(name)!)) != nil) {
//            return view
//        }
//        for subview in (view?.subviews)! {
//            if subview.isKindOfClass(NSClassFromString(name)!) {
//                return subview
//            }
//        }
//        return nil
//    }
//    
//    internal func addSomeElements(viewController:UIViewController) {
//        let PLCameraView:UIView = findView(viewController.view, name:"PLCameraView")!
//        let PLCropOverlay:UIView = findView(PLCameraView, name:"PLCropOverlay")!
//        let bottomBar:UIView = findView(PLCropOverlay, name:"PLCropOverlayBottomBar")!
//        
//        let saveImageView:UIImageView = bottomBar.subviews[0] as! UIImageView
//        let retake:UIButton = saveImageView.subviews[0] as! UIButton
//        retake.setTitle("重拍", forState:.Normal)
//        let save:UIButton = saveImageView.subviews[0] as! UIButton
//        save.setTitle("选择", forState:.Normal)
//        
//        
//        let cameraImageView:UIImageView = bottomBar.subviews[0] as! UIImageView
//        let cancel:UIButton = cameraImageView.subviews[0] as! UIButton
//        cancel.setTitle("取消", forState:.Normal)
//    }
}