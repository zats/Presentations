//
//  Markov.swift
//  Markov
//
//  Created by Sash Zats on 8/29/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation
import GameplayKit

public class MarkovChainMachine: GKStateMachine {
    let random: GKRandom
    let mapping: [NSArray: [[Double: GKState]]]
    private(set) var stateBuffer: [GKState] = []
    
    required public init(initialStates: [GKState], mapping:[NSArray : [[Double: GKState]]], random: GKRandom = GKARC4RandomSource()) {
        let lookbehind = initialStates.count
        self.mapping =  mapping
        self.random = random
        var states: Set<GKState> = []
        for (key, value) in mapping {
            assert(key.count == lookbehind, "Number of elements in prbability tables must be the same as number of initial states")
            let keysSet = Set(Array(key) as! [GKState])
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
    
    public func enterNextState() -> Bool {
        if let state = nextState() {
            return self.enterState(state)
        }
        return false
    }
    
    public func nextState() -> AnyClass? {
        return stateForStateBuffer(stateBuffer)?.dynamicType
    }
    
    override final public func canEnterState(stateClass: AnyClass) -> Bool {
        if currentState == nil {
            return true
        }
        
        guard let states = possibleStatesForBuffer(stateBuffer) else {
            return false
        }
        let clss = states.reduce(Array<AnyClass>()){ $0 + [$1.values.first!.dynamicType] }
        return clss.contains{$0 == stateClass}
    }
    
    override final public func enterState(stateClass: AnyClass) -> Bool {
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
}
