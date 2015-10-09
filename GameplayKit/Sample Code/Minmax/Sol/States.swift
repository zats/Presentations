//
//  States.swift
//  Sol
//
//  Created by Sash Zats on 10/4/15.
//  Copyright © 2015 Comyar Zaheri. All rights reserved.
//

import GameplayKit


class Idle: State, Suggestion {
    var allowedStates: [AnyClass] = [AddCity.self, Preferences.self, SwitchCity.self]
    var title: String = "No place like home"
}

class SwitchCity: State, Suggestion {
    var allowedStates: [AnyClass] = [Idle.self]
    var title: String = "You have more locations to check out, swipe horizontally!"
}

class AddCity: State, Suggestion {
    var allowedStates: [AnyClass] = [Idle.self]
    var title: String = "It looks empty here, how about adding some cities?"
}

class DeleteCity: State, Suggestion {
    var allowedStates: [AnyClass] = [Preferences.self]
    var title: String = "If you have too many cities, delete some"
}

class SwitchUnits: State, Suggestion {
    var allowedStates: [AnyClass] = [Preferences.self]
    var title: String = "Did you know you can switch temperature units?"
}

class FinishDemo: State, Suggestion {
    static let numberOfStates = 30
    
    var allowedStates: [AnyClass] = []
    var title: String = "You should get back to your slides😽"
}

class Preferences: State, Suggestion {
    var allowedStates: [AnyClass] = [SwitchUnits.self, DeleteCity.self, Idle.self]
    var title: String = "How about some preferences?"
}

@objc protocol Suggestion: NSObjectProtocol {
    var title: String { get }
    var allowedStates: [AnyClass] { get }
}

class State: GKState {
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        guard let x = self as? Suggestion else {
            assertionFailure("Class does not implement Suggestion protocol")
            return false
        }
        return x.allowedStates.contains({$0 == stateClass}) || stateClass == FinishDemo.self
    }
    
    override var description: String {
        let type = NSStringFromClass(self.dynamicType)
        return type.substringFromIndex(type.startIndex.advancedBy("Sol.".characters.count))
    }
}