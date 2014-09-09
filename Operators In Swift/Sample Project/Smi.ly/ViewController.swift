//
//  ViewController.swift
//  Smi.ly
//
//  Created by Sasha Zats on 9/5/14.
//  Copyright (c) 2014 Sash Zats. All rights reserved.
//

import UIKit
import Obscura

import UIKit
import CoreImage

infix operator × { associativity left precedence 150 }
public func × (left: UIImage, right: UIImage) -> UIImage {
    return left.multiply(right)
}

public func - (left: UIImage, right: UIImage) -> UIImage {
    return left.difference(right)
}

public func -= (inout left: UIImage, right: UIImage) {
    left = left.difference(right)
}

prefix operator | {}
prefix public func | (image: UIImage) -> UIImage {
    return image.desaturate()
}

postfix operator | {}
postfix public func | (image: UIImage) -> UIImage {
    return image
}

prefix operator ∯ {}
public prefix func ∯ (left: UIImage) -> UIImage {
    return left.imageWithSmiley("😽")
}

extension UIImage {
    
    
    func desaturate() -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CoreImage.CIImage(image: self)
        let filter = CIFilter(name: "CIColorControls")
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        let result: CoreImage.CIImage = filter.valueForKey(kCIOutputImageKey) as CoreImage.CIImage;
        let cgImage = context.createCGImage(result, fromRect:result.extent())
        let image = UIImage(CGImage:cgImage);
        return image
    }
    
    func multiply(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.drawAtPoint(CGPointZero)
        image.drawAtPoint(CGPointZero, blendMode: kCGBlendModeMultiply, alpha: 1.0)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func difference(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.drawAtPoint(CGPointZero)
        image.drawAtPoint(CGPointZero, blendMode: kCGBlendModeDifference, alpha: 1.0)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func imageWithSmiley(smiley: String) -> UIImage {
        let ciImage = CoreImage.CIImage(image: self)
        
        let ciContext = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: ciContext, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector.featuresInImage(ciImage)
        let faceFeature = features.first! as CIFaceFeature
        var faceBounds = faceFeature.bounds
        faceBounds.origin.y = self.size.height - CGRectGetMaxY(faceBounds)
        
        UIGraphicsBeginImageContext(self.size);
        self.drawAtPoint(CGPointZero)
        
        let textImage = self.imageForText(smiley);
        textImage.drawInRect(faceBounds)
        
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return result
    }
    
    private func imageForText(text: String) -> UIImage {
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(200)];
        let size = text.sizeWithAttributes(attributes);
        
        UIGraphicsBeginImageContext(size);
        let string: NSString = NSString(string: text)
        let bounds = CGRectMake(0, 0, size.width, size.height)
        string.drawInRect(bounds, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return result
    }
    
    public var 😽: UIImage {
        return self.imageWithSmiley("😽")
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image: UIImage = |UIImage(named: "puppeteer")|
        var imageView = UIImageView(image: image)
        imageView.center = self.view.center        
        self.view.addSubview(imageView)
    }
}

