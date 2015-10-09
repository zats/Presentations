//
//  Extensions.swift
//  Sol
//
//  Created by Sash Zats on 10/4/15.
//  Copyright © 2015 Comyar Zaheri. All rights reserved.
//


extension Array {
    func containsType(type: AnyClass) -> Bool {
        for elem in self {
            if elem.dynamicType == type {
                return true
            }
        }
        return false
    }
}
