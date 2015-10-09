//
//  PredicatesSetup.swift
//  Sol
//
//  Created by Sash Zats on 10/4/15.
//  Copyright © 2015 Comyar Zaheri. All rights reserved.
//

import Foundation

private let best = 50
private let good = 25
private let notBad = -25
private let worst = -50


class PredicatesSetup: NSObject {
    static let sharedInstance = PredicatesSetup()
    
    let engine = SuggestionEngine.sharedInstance
    
    func setupPredicates() {
        // Finish demo
        engine.register(FinishDemo.self) { states in
            if states.count >= 25 {
                return best
            }
            return nil
        }

        // Preferences
        engine.register(Preferences.self) { states in
            if Array(states[0..<states.count-1]).containsType(Preferences.self) {
                return nil
            }            
            return states.count > 5 ? good : nil
        }
        
        // Change temperature
        engine.register(SwitchUnits.self){ states in
            if Array(states[0..<states.count-1]).containsType(SwitchUnits.self) {
                return nil
            }
            switch states.count {
            case  0...5:
                return best
            default:
                return good
            }
        }
        
        // Add a city
        engine.register(AddCity.self){ states in
            switch states.filter({ $0 is AddCity }).count {
            case 0:
                return best
            case 1...3:
                return good + 1
            default:
                return nil
            }
        }
        
        // Delete a city
        engine.register(DeleteCity.self){ states in
            if Array(states[0..<states.count-1]).containsType(DeleteCity.self) {
                return nil
            }

            if states.filter({ $0 is AddCity }).count > 2 && states.last is DeleteCity {
                return best
            }
            return nil
        }
        
        // Switch city
        engine.register(SwitchCity.self){ states in
            if Array(states[0..<states.count-1]).containsType(SwitchCity.self) {
                return nil
            }
            // we have at least 2 cities to show
            if states.filter({ $0 is AddCity }).count - states.filter({ $0 is DeleteCity }).count > 2 {
               return good + 1
            }
            return nil
        }
    }
}
