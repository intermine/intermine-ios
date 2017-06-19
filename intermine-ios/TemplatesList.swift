//
//  TemplatesList.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class TemplatesList {
    
    // TODO: Should it be cached in CD?
    
    private var templates: [Template]?
    private let mine: String?
    
    init(withTemplates: [Template]?, mine: String?) {
        self.templates = withTemplates
        self.mine = mine
    }
    
    func size() -> Int {
        if let templates = self.templates {
            return templates.count
        } else {
            return 0
        }
    }
    
    func removeAllItems() {
        self.templates = []
    }
    
    func templateAtIndex(index: Int) -> Template? {
        if let templates = self.templates {
            if index < self.size() {
                return templates[index]
            }
        }
        return nil
    }
    
}
