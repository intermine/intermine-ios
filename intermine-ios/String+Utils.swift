//
//  File.swift
//  intermine-ios
//
//  Created by Nadia on 5/9/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

extension String {
    
    public static func localize(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    public static func localizeWithArg(_ key: String, arg: String) -> String {
        return String(format: NSLocalizedString(key, comment: ""), arg)
    }
    
    static func findMatches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isAboveVersion(version: String) -> Bool {
        
        // compares versions with format x.x.x
        // "1.7.1".isAboveVersion(version: "1.6.6") -> True
        // "1.6.6".isAboveVersion(version: "1.7.1") -> False
        
        let baseArray = self.components(separatedBy: ".")
        let arrayToCompare = version.components(separatedBy: ".")
        assert(baseArray.count == arrayToCompare.count)
        for i in 0..<baseArray.count {
            if let baseElem = Int(baseArray[i]), let comparedElem = Int(arrayToCompare[i]) {
                if baseElem >= comparedElem {
                    return true
                }
            }
        }
        return false
    }
}
