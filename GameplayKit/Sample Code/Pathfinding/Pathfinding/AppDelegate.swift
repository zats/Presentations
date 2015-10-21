//
//  AppDelegate.swift
//  Pathfinding
//
//  Created by Sash Zats on 9/13/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import UIKit
import GameplayKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var automationEnabled: Bool = false

    var window: UIWindow?
    
    let graph = GKGraph()
    var targetNode: Node!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupGraph()
        setupDelegate()
        return true
    }

    @IBAction func favoriteButtonAction(sender: AnyObject) {
        guard let nc = self.window?.rootViewController as? UINavigationController,
            controller = nc.viewControllers.last as? ViewController else {
                assertionFailure("Unexpected view controller")
                return
        }
        AppDelegate.automationEnabled = true
        performAutomaticNavigationStep(controller)
    }
}


extension AppDelegate: UINavigationControllerDelegate {
    
    private func setupDelegate() {
        (window?.rootViewController as? UINavigationController)?.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        guard let viewController = viewController as? ViewController, nodes = graph.nodes as? [Node] else {
            assertionFailure("Unexpected view controller or nodes")
            return
        }
        viewController.node = nodes.filter{ viewController.id == $0.id }.first
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if AppDelegate.automationEnabled {
            performAutomaticNavigationStep(viewController)
        }
    }
    
    private func performAutomaticNavigationStep(fromViewController: UIViewController) {
        guard let viewController = fromViewController as? ViewController, navigationController = viewController.navigationController else {
            assertionFailure("Unexpected view controller or nodes")
            return
        }
        guard let path = graph.findPathFromNode(viewController.node, toNode: targetNode) as? [Node] else {
            fatalError("path contains unexpected node types")
        }
        let nextNode: Node
        switch path.count {
        case 0:
            fatalError("Empty path")
        case 1:
            assert(viewController.node.id == "facebook-location")
            AppDelegate.automationEnabled = false
            return
        default:
            nextNode = path[1]
        }
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2))
        dispatch_after(time, dispatch_get_main_queue()){
            let vcs = navigationController.viewControllers
            if vcs.count > 1 && (vcs[vcs.count - 2] as? ViewController)?.node.id == nextNode.id {
                navigationController.popViewControllerAnimated(true)
            } else {
                let segue = "\(viewController.node.id) → \(nextNode.id)"
                viewController.performSegueWithIdentifier(segue, sender: self)
            }
        }
    }
}

// Graph setup
extension AppDelegate {
    private func setupGraph() {
        let root = Node(id: "root")
        let privacy = Node(id: "privacy")
        let location = Node(id: "location")
        let bluetooth = Node(id: "bluetooth")
        let facebook = Node(id: "facebook")
        let facebookSettings = Node(id: "facebook-settings")
        let facebookLocation = Node(id: "facebook-location")
        let facebookAccount = Node(id: "facebook-account")

        targetNode = facebookLocation

        root.addConnectionsToNodes([privacy, facebook], bidirectional: true)
        facebook.addConnectionsToNodes([facebookSettings, facebookAccount], bidirectional: true)
        facebookSettings.addConnectionsToNodes([facebookLocation], bidirectional: true)
        privacy.addConnectionsToNodes([bluetooth, location], bidirectional: true)
        location.addConnectionsToNodes([facebookLocation], bidirectional: true)
        graph.addNodes([
            root,
                privacy,
                    bluetooth,
                    location,
                facebook,
                    facebookSettings,
                    facebookLocation,
                    facebookAccount
        ])
    }
}


class Node: GKGraphNode {
    let id: String

    required init(id: String) {
        self.id = id
        super.init()
    }
    
    override var description: String {
        return "Node \"\(id)\""
    }
}
