//
//  MarkovTextGenerator.swift
//  Markov
//
//  Created by Sash Zats on 8/27/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Foundation
import GameplayKit


enum Split {
    case ByWords
    case ByCharacters
}

class MarkovGenerator {
    
    static func processText(text: String, lookbehind: Int = 2, splitBy: Split) -> [NSArray: [[Double: GKState]]] {
        var substringsToCountedSets: [NSArray: CountedSet<StringState>] = [:]
        var buffer: [String] = []
        var counter = 0
        
        func process(substring: String?) {
            guard let substring = substring else {
                return
            }
            if buffer.count < lookbehind {
                buffer.append(substring)
                return
            }
            let substringState = StringState.instanceForString(substring)
            let bufferArray = NSArray(array: buffer.map{ StringState.instanceForString($0) })
            if let countedSet = substringsToCountedSets[bufferArray] {
                countedSet.addObject(substringState)
            } else {
                substringsToCountedSets[bufferArray] = CountedSet(value: substringState)
            }
            
            buffer.append(substring)
            if buffer.count > lookbehind {
                buffer.removeFirst()
            }
        }
        
        switch splitBy {
        case .ByWords:
            text.characters.split(" ").forEach{ process(String($0)) }
        case .ByCharacters:
            text.characters.forEach{ process(String($0)) }
        }

        var result: [NSArray: [[Double: GKState]]] = [:]
        counter = 0
        for (bufferArray, countedSet) in substringsToCountedSets {
            print("\(counter++) / \(substringsToCountedSets.count)")
            var probabilities: [[Double: GKState]] = []
            for obj in countedSet.allObjects {
                guard let count = countedSet.countForObject(obj) else {
                    continue
                }
                let probability = Double(count) / Double(countedSet.totalCount)
                assert(probability <= 1)
                probabilities.append([probability: obj])
            }
            result[bufferArray] = probabilities
        }
        return result
    }
    
    private static func statesArrayFromString(string: String, lookup: [Character: StringState]) -> NSArray {
        return string.characters.map{ lookup[$0]! }
    }
    
    private static func outcomesToMap(set: NSCountedSet) -> [[Double: String]] {
        var result: [[Double: String]] = []
        for string in set {
            let probability = round(set.uniformCountForObject(string) * 100) / 100
            result.append([probability: string as! String])
        }
        result = result.sort{ $0.0.keys.first! < $0.1.keys.first! }
        let remainder: Double = result.reduce(1){ $0 - $1.keys.first! }
        if remainder != 0 {
            let lastIndex = result.count - 1
            let lastObject = result[lastIndex]
            let lastProbability = lastObject.keys.first!
            result[lastIndex] = [round((lastProbability + remainder) * 100) / 100: lastObject.values.first!]
        }
        return result
    }
    
    private static func prefixToContedSetOfChars(string string: String, lookbehind: Int) -> [String: NSCountedSet] {
        var prefixToCounts: [String: NSCountedSet] = [:]
        for i in lookbehind..<string.characters.count {
            let start = string.startIndex.advancedBy(i - lookbehind)
            let end = string.startIndex.advancedBy(i)
            let prefix = string.substringWithRange(Range(start: start, end: end))
            
            print("\(i) / \(string.characters.count) \"\(prefix)\"")
            
            let countedSet: NSCountedSet
            if prefixToCounts[prefix] != nil {
                countedSet = prefixToCounts[prefix]!
            } else {
                countedSet = NSCountedSet()
                prefixToCounts[prefix] = countedSet
            }
            let next = string.substringWithRange(Range(start: end, end: end.advancedBy(1)))
            countedSet.addObject(next)
        }
        return prefixToCounts
    }
}

extension NSCountedSet {
    func uniformCountForObject(a: AnyObject) -> Double {
        let total = reduce(0){ $0 + countForObject($1) }
        return Double(countForObject(a)) / Double(total)
    }
}

class StringState: GKState, NSCoding {
    private(set) var string: String = "" {
        didSet {
            hashString = string
        }
    }
    private var hashString: String = ""
    static func classNameForString(string: String) -> String {
        return "StringState_\(string)"
    }
    
    static var classesCount = 0
    static func classForString(string: String) -> AnyClass {
        let name = classNameForString(string)
        if let cls = objc_lookUpClass(name) {
            return cls
        } else {
            let cls: AnyClass = objc_allocateClassPair(StringState.self, name, 0)
            objc_registerClassPair(cls)
            return cls
        }
    }

    static func instanceForString(string: String) -> StringState {
        let cls: AnyClass = classForString(string)
        let instance = InstantiateClass(cls) as! StringState
        instance.string = string
        return instance
    }
    
    override var description: String {
        return "StringState_\(self.string)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        if let x = aDecoder.decodeObjectForKey("string") as? String {
            self.string = x
        } else {
            return nil
        }
    }
    
    override init() {
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(string, forKey: "string")
    }
    
    override var hash: Int {
        return self.hashString.hash
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let o = object as? StringState {
            return o.hashString == self.hashString
        }
        return super.isEqual(object)
    }
}

class CountedSet<T: Hashable> {
    private(set) var totalCount: Int = 0
    private var objectToCount: [T: Int] = [:]
    
    var allObjects: [T] {
        return Array(objectToCount.keys)
    }
    
    init(value: T) {
        addObject(value)
    }
    
    func addObject(value: T) {
        if let count = objectToCount[value] {
            objectToCount[value] = count + 1
        } else {
            objectToCount[value] = 1
        }
        totalCount++
    }
    
    func countForObject(value: T) -> Int? {
        return objectToCount[value]
    }
}
