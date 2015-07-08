//
//  UIKitty
//
//  Created by Sash Zats on 6/27/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

import UIKit
import Aspects

/**
    Patches for your UI😸
*/
class UI😸 : NSObject {
    
    static func 🚀() {
        patchSearchingViewHeight()
    }
    
    private static func patchSearchingViewHeight() {
        if let cls: AnyObject = NSClassFromString("UIPrinterSearchingView") {
            let block: @objc_block (AspectInfo) -> Void = { (aspectInfo) in
                if let view = aspectInfo.instance() as? UIView {
                    view.frame.size.height = view.superview!.frame.height - 44
                }
            }
            cls.aspect_hookSelector(Selector("layoutSubviews"), withOptions: .PositionAfter, usingBlock: unsafeBitCast(block, AnyObject.self), error: nil)
        }
    }
}
