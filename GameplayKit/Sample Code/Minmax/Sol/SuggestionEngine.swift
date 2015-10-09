//
//  Suggestions.swift
//  Sol
//
//  Created by Sash Zats on 10/3/15.
//  Copyright © 2015 Comyar Zaheri. All rights reserved.
//

import GameplayKit


protocol SuggestionPredicate {
    func score(states states: [GKState]) -> Int?
}

private class BlockSuggestionPredicate: SuggestionPredicate {
    let block: [GKState] -> Int?
    init(block: [GKState] -> Int?) {
        self.block = block
    }
    
    private func score(states states: [GKState]) -> Int? {
        return block(states)
    }
}

class SuggestionEngine: NSObject  {
    static let sharedInstance = SuggestionEngine()
    
    private static let AllStates: [GKState] = [Idle(), SwitchCity(), AddCity(), DeleteCity(), SwitchUnits(), FinishDemo(), Preferences()]

    private(set) var players: [GKGameModelPlayer]?
    private(set) var activePlayer: GKGameModelPlayer?
    private let player: Player = Player()

    private let stateMachine: StateMachine = StateMachine(states: SuggestionEngine.AllStates)
    
    private var predicates: [SuggestionPredicate] = []
    
    var allStates: [GKState] = []
    
    private let minmax: GKMinmaxStrategist = GKMinmaxStrategist()
    required override init() {
        players = [player]
        activePlayer = player
        super.init()
        minmax.gameModel = self
        minmax.maxLookAheadDepth = 1
        minmax.randomSource = GKARC4RandomSource()
    }
    
    func enterState(type: AnyClass) -> Bool {
        if stateMachine.enterState(type) {
            allStates.append(stateMachine.currentState!)
            return true
        }
        return false
    }
    
    func suggest() -> Suggestion? {
        if let x = (minmax.bestMoveForPlayer(player) as? Update)?.state as? Suggestion {
            return x
        }
        assertionFailure()
        return nil
    }
    
    func register(type: AnyClass, predicate: [GKState] -> Int?) {
        register(BlockSuggestionPredicate{ states in
            if states.last?.dynamicType != type {
                return nil
            }
            return predicate(states)
        })
    }
    
    func register(predicate: SuggestionPredicate) {
        predicates.append(predicate)
    }
    
    private func scoreForStates(states: [GKState]) -> Int {
        var maxScore: Int?
        for predicate in predicates {
            if let result = predicate.score(states: states) {
                if maxScore < result {
                   maxScore = result
                }
            }
        }
        return maxScore ?? .min
    }
}

// MARK: GKGameModel
extension SuggestionEngine: GKGameModel {
    func setGameModel(gameModel: GKGameModel) {
        guard let gameModel = gameModel as? SuggestionEngine else {
            assertionFailure()
            return
        }
        allStates = gameModel.allStates
        activePlayer = gameModel.activePlayer
        players = gameModel.players
        predicates = gameModel.predicates
    }
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let result = SuggestionEngine.AllStates.filter{
            stateMachine.canEnterState($0.dynamicType)
        }
        return result.map{
            Update(state: $0)
        }
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        if let update = gameModelUpdate as? Update {
            stateMachine.enterState(update.state.dynamicType)
            allStates.append(update.state)
        } else {
            assertionFailure()
        }
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        return scoreForStates(allStates)
    }
}

// MARK: NSCopying
extension SuggestionEngine {
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init()
        copy.setGameModel(self)
        return copy
    }
}

class StateMachine: GKStateMachine {
}

class Update: NSObject, GKGameModelUpdate {
    var value: Int = 0
    let state: GKState
    
    init(state: GKState) {
        self.state = state
    }
}

private class Player: NSObject, GKGameModelPlayer {
    @objc var playerId: Int { return 42 }
}
