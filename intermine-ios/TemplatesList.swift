//
//  TemplatesList.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class TemplatesList {
    
    private var templates: [Template]?
    private let mine: String?
    
    init(withTemplates: [Template]?, mine: String?) {
        self.templates = withTemplates
        self.mine = mine
    }
    
    func getTemplates() -> [Template]? {
        return self.templates
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
    
    func filterTemplates(searchText: String?) -> [Template] {
        guard let searchText = searchText else {
            return []
        }
        var filteredTemplates: [Template] = []
        if let templates = self.templates {
            for template in templates {
                if let title = template.getTitle() {
                    if title.range(of: searchText) != nil {
                        filteredTemplates.append(template)
                    }
                }
            }
        }
        return filteredTemplates
    }
    
}
