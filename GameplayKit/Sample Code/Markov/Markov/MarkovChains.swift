//
//  MarkovChains.swift
//  Markov
//
//  Created by Sash Zats on 8/25/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation
import GameplayKit


class MarkovChainMachine: GKStateMachine {
    let random: GKRandom = GKARC4RandomSource()
    let mapping: [NSArray: [[Double: GKState]]]
    private(set) var stateBuffer: [GKState] = []
    
    /*
    mapping: [stateA, stateB, stateC]: [[0.6: stateA], [0.4: stateB]]
     */
    required init(initialStates: [GKState], mapping:[NSArray : [[Double: GKState]]]) {
        let lookbehind = initialStates.count
        self.mapping = mapping
        var states: Set<GKState> = []
        var counter = 0
        for (key, value) in mapping {
            print("\(counter++) / \(mapping.count)")
            assert(key.count == lookbehind, "Number of elements in prbability tables must be the same as number of initial states")
            let keysSet = Set(key as! [GKState])
            states.unionInPlace(keysSet)
            assert(round(value.reduce(0){$0 + $1.keys.first!} * 100)/100 == 1, "Probabilities must add up to 1")
            value.forEach{
                states.insert($0.values.first!)
            }
        }
        super.init(states: Array(states))
        stateBuffer = initialStates
        super.enterState(initialStates.last!.dynamicType)
    }
    
    func enterNextState() -> Bool {
        if let state = nextState() {
            return self.enterState(state)
        }
        return false
    }
    
    func nextState() -> AnyClass? {
        return stateForStateBuffer(stateBuffer)?.dynamicType
    }
    
    override final func canEnterState(stateClass: AnyClass) -> Bool {
        if currentState == nil {
            return true
        }
        
        guard let states = possibleStatesForBuffer(stateBuffer) else {
            return false
        }
        let clss = states.reduce(Array<AnyClass>()){ $0 + [$1.values.first!.dynamicType] }
        return clss.contains{$0 == stateClass}
    }
    
    override final func enterState(stateClass: AnyClass) -> Bool {
        guard super.enterState(stateClass) else {
            return false
        }
        guard let currentState = currentState else {
            fatalError()
        }
        stateBuffer.removeFirst()
        stateBuffer.append(currentState)
        return true
    }
    
    func reset() {
        let index = Int(arc4random_uniform(UInt32(mapping.keys.count)))
        let states = Array(mapping.keys)[index]
        stateBuffer = states as! [GKState]
        self.enterState(stateBuffer.first!.dynamicType)
    }
    
    // MARK: - Private
    
    private func possibleStatesForBuffer(buffer: [GKState]) -> [[Double: GKState]]? {
        return mapping[NSArray(array: buffer)]
    }
    
    private func stateForStateBuffer(buffer: [GKState]) -> GKState? {
        guard let probabilities = possibleStatesForBuffer(buffer) else {
            return nil
        }
        let random = Double(self.random.nextUniform())
        var runningMax: Double = 0
        for probability in probabilities {
            let value = probability.keys.first!
            if random >= runningMax && random < runningMax + value {
                return probability.values.first!
            }
            runningMax += value
        }
        
        return nil
    }

    required convenience init?(coder aDecoder: NSCoder) {
        print("decoding...")
        if let initialState = aDecoder.decodeObjectForKey("stateBuffer") as? [GKState],
            mapping = aDecoder.decodeObjectForKey("mapping") as? [NSArray: [[Double: GKState]]] {
                print("init...")
            self.init(initialStates: initialState, mapping: mapping)
        } else {
            return nil
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(stateBuffer, forKey: "stateBuffer")
        aCoder.encodeObject(mapping, forKey: "mapping")
    }
}
