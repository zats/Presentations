//
//  UIKitty
//
//  Created by Sash Zats on 6/28/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation
import UIKit
import Aspects


/**
    A useful 🔧 for your View debugging needs
 */
public class View🔧: NSObject, EarlyBird {
    
    public func getTheWorm() {
        let block: @objc_block (AspectInfo) -> Void = { (aspectInfo) in
            if let controller = aspectInfo.instance() as? UIViewController {
                if !controller.isViewLoaded() {
                    return
                }
                
                let viewClass: AnyClass = object_getClass(controller.view)
                let viewControllerClass: AnyClass = object_getClass(controller)
                if NSStringFromClass(viewClass).hasSuffix(NSStringFromClass(viewControllerClass)) {
                    return
                }
                let newName = "\(NSStringFromClass(viewClass))_\(NSStringFromClass(viewControllerClass))"
                var newViewClass: AnyClass!
                if let existentClass: AnyClass = NSClassFromString(newName) {
                    newViewClass = existentClass
                } else {
                    newViewClass = objc_allocateClassPair(viewClass, newName, 0)
                    objc_registerClassPair(newViewClass)
                }
                object_setClass(controller.view, newViewClass)
            }
        }
        let blockObject: AnyObject = unsafeBitCast(block, AnyObject.self)
        (UIViewController.self as AnyObject).aspect_hookSelector(Selector("loadView"), withOptions: .PositionAfter, usingBlock: blockObject, error: nil)
        (UIViewController.self as AnyObject).aspect_hookSelector(Selector("viewDidLoad"), withOptions: .PositionBefore, usingBlock: blockObject, error: nil)
    }
    
    // MARK: - Private
    
    private func isClass(cls: AnyClass, kindOfClass cls2: AnyClass) -> Bool {
        var currentClass: AnyClass? = cls
        while currentClass != nil {
            if currentClass! == cls2 {
                return true
            }
            currentClass = class_getSuperclass(currentClass)
        }
        return false
    }
}

private func == (lhs: AnyClass, rhs: AnyClass) -> Bool {
    // This is not cool
    return class_getName(lhs) == class_getName(rhs)
}
