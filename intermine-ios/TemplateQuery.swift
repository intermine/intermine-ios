//
//  TemplateQuery.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class TemplateQuery {
    
    private var value: String?
    private let code: String?
    private var op: String?
    private let constraint: String? // "path"
    
    init(withValue: String?, code: String?, op: String?, constraint: String?) {
        self.value = withValue
        self.code = code
        self.op = op
        self.constraint = constraint
    }
    
    func constructDictForGen(gen: Int) -> [String: String] {
        var params: [String: String] = [:]
        if let constraint = self.constraint {
            params["constraint\(gen)"] = constraint
        }
        if let value = self.value {
            params["value\(gen)"] = value
        }
        if let code = self.code {
            params["code\(gen)"] = code
        }
        if let op = self.op {
            params["op\(gen)"] = op
        }
        return params
    }
    
    func isLookupQuery() -> Bool {
        return value?.lowercased() == "lookup"
    }
    
    func isOpQuery() -> Bool {
        if let value = self.value {
            return value.lowercased() != "lookup"
        }
        return false
    }
    
    func getOperation() -> String? {
        return self.op
    }
    
    func getValue() -> String? {
        return self.value
    }
    
    func changeOperation(operation: String?) {
        self.op = operation
    }
    
    func changeValue(value: String?) {
        self.value = value
    }
    
}
