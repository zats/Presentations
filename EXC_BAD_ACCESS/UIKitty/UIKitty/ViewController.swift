//
//  ViewController.swift
//  UIKitty
//
//  Created by Sash Zats on 6/27/15.
//  Copyright (c) 2015 Sash Zats. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPopoverControllerDelegate {
    var catController: CatViewController!
    var popoverController: UIPopoverController?
    var acitivityController: UIActivityViewController?
        
    // MARK: - Actions

    @IBAction func _shareButtonAction(sender: UIBarButtonItem) {
        let catImage = self.catController.catImageView.image!
        let catURL = NSURL(string: "https://edudated.files.wordpress.com/2014/12/image.jpg")!        
        let controller = UIActivityViewController(activityItems: [catImage, catURL], applicationActivities: nil)
        let popoverController = UIPopoverController(contentViewController: controller)
        popoverController.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: .Any, animated: true)
        popoverController.delegate = self
        self.popoverController = popoverController
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "catController" {
            self.catController = segue.destinationViewController as! CatViewController
        }
    }

    // MARK: - UIPopoverControllerDelegate
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.popoverController = nil
    }
}


class CatViewController: UIViewController {
    @IBOutlet weak var catImageView: UIImageView!
}
