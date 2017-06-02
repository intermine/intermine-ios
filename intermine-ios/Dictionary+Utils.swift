//
//  Dictionary+Utils.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    init(keys: [Key], values: [Value]) {
        self.init()
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
    
    static func createDict(keys: NSArray, values: NSArray) {
        precondition(keys.count == values.count)
        var dict: [String: String] = [:]
        for (index, keyElem) in keys.enumerated() {
            if let keyString = keyElem as? String, let valueString = values[index] as? String {
                dict[keyString] = valueString
            }
        }
    }
}
