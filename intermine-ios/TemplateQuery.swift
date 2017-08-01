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
    private var editable: Bool?
    private var extraValue: String?
    
    init(withValue: String?, code: String?, op: String?, constraint: String?, editable: Bool?, extraValue: String?) {
        self.value = withValue
        self.code = code
        self.op = op
        self.constraint = constraint
        self.editable = editable
        self.extraValue = extraValue
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
        if let extra = self.extraValue {
            params["extra\(gen)"] = extra
        }
        return params
    }
    
    func getExtraValue() -> String? {
        return self.extraValue
    }
    
    func isEditable() -> Bool {
        if let editable = self.editable {
            return editable
        }
        return false
    }
    
    func isLookupQuery() -> Bool {
        return op?.lowercased() == "lookup"
    }
    
    func isOpQuery() -> Bool {
        return op?.lowercased() != "lookup"
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
    
    func changeExtra(extra: String?) {
        self.extraValue = extra
    }
    
    func getPath() -> String? {
        return self.constraint
    }
    
}
