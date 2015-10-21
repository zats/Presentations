//
//  ViewController.swift
//  Markov
//
//  Created by Sash Zats on 8/25/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import UIKit
import GameplayKit
import ObjectiveC


typealias BogusMethod = (name: String, description: String)

class ViewController: UIViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var descriptions: MarkovChainMachine!
    private var names: MarkovChainMachine!
    var elements: [BogusMethod] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.generateRecipes()
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    private func generateRecipes() {
        self.descriptions = markov(named: "swift_descriptions", splitBy: .ByWords, lookbehind: 1)
        self.names = markov(named: "swift_names", splitBy: .ByCharacters, lookbehind: 3)
    }
    
    private func markov(named filename: String, splitBy: Split, lookbehind: Int) -> MarkovChainMachine {
        let source = try! String(contentsOfURL: NSBundle.mainBundle().URLForResource(filename, withExtension: "txt")!)
        let outcomes = MarkovGenerator.processText(source, lookbehind: lookbehind, splitBy: splitBy)
        let random = arc4random_uniform(UInt32(outcomes.keys.count))
        let index = outcomes.keys.startIndex.advancedBy(Int(random))
        let initialState = outcomes.keys[index] as! [GKState]
        return MarkovChainMachine(initialStates: initialState, mapping: outcomes)
    }

    @IBAction func generateElement(sender: AnyObject) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let className = self.className()
            let classDescription = self.classDescription()
            dispatch_async(dispatch_get_main_queue()) {
                self.elements.insert(BogusMethod(name: className, description: classDescription), atIndex: 0)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
            }
        }
    }
    
    private func className() -> String {
        if names == nil { return ""}
        names.reset()
        var name = names.stateBuffer.reduce(""){ $0 + ($1 as! StringState).string }
        while true {
            let x = names.enterNextState()
            if !x { break }
            let state = names.currentState as! StringState
            name += state.string
            if name.characters.count > 20 && name.characters.last == " " {
                break
            }
        }
        let range = Range(start: name.startIndex, end: name.startIndex.advancedBy(1))
        let firstChar = String(name.characters.first!)
        name.replaceRange(range, with: firstChar.capitalizedString)
        return name.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    private func classDescription() -> String {
        if descriptions == nil { return ""}
        descriptions.reset()
        var description = descriptions.stateBuffer.reduce(""){ $0 + ($1 as! StringState).string + " " }
        while true {
            let x = descriptions.enterNextState()
            if !x { break }
            let state = descriptions.currentState as! StringState
            description += state.string + " "
            if description.characters.count > 70 && state.string.characters.last == "." {
                break
            }
        }
        let range = Range(start: description.startIndex, end: description.startIndex.advancedBy(1))
        let firstChar = String(description.characters.first!)
        description.replaceRange(range, with: firstChar.capitalizedString)
        return description
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TweetCell
        let tweet = elements[indexPath.row]
        cell.nameLabel.text = tweet.name
        cell.descriptionLabel.text = tweet.description
        return cell
    }
}

class TweetCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}

private class MarkovUnarchiver: NSKeyedUnarchiver {
    private override func classForClassName(codedName: String) -> AnyClass? {
        if let c = NSClassFromString(codedName) {
            return c
        }
        if let r = codedName.rangeOfString("_") {
            let s = codedName.substringFromIndex(r.endIndex)
            return StringState.classForString(s)
        }
        return StringState.self
    }
}

