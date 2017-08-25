//
//  Template.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class Template {
    
    private let title: String?
    private let name: String?
    private let description: String?
    private let queryList: [TemplateQuery]?
    private let mineUrl: String?
    private let authorized: Bool?
    private let tags: [String]
    
    init(withTitle: String?, description: String?, queryList: [TemplateQuery]?, name: String?, mineUrl: String, authorized: Bool?, tags: [String]) {
        self.title = withTitle
        self.description = description
        self.queryList = queryList
        self.name = name
        self.mineUrl = mineUrl
        self.authorized = authorized
        self.tags = tags
    }
    
    // MARK: Public methods
    
    func getAuthd() -> Bool {
        if let authd = self.authorized {
            return authd
        } else {
            return false
        }
    }
    
    func getMineUrl() -> String? {
        return self.mineUrl
    }
    
    func getInfo() -> String? {
        return self.description
    }
    
    func getTitle() -> String? {
        return self.title
    }
    
    func getName() -> String {
        guard let name = self.name else {
            return ""
        }
        return name
    }
    
    func getTags() -> [String]? {
        return self.tags
    }
    
    func lookupQueryCount() -> Int {
        guard let list = queryList else {
            return 0
        }
        return list.filter({ (query: TemplateQuery) -> Bool in
            return query.isLookupQuery()
        }).count
    }
    
    func opQueryCount() -> Int {
        guard let list = queryList else {
            return 0
        }
        return list.filter({ (query: TemplateQuery) -> Bool in
            return query.isOpQuery()
        }).count
    }
    
    func totalQueryCount() -> Int {
        guard let list = queryList else {
            return 0
        }
        return list.count
    }
    
    func getLookupQueries() -> [TemplateQuery] {
        guard let list = queryList else {
            return []
        }
        return list.filter({ (query: TemplateQuery) -> Bool in
            return query.isLookupQuery()
        })
    }
    
    func getOpQueries() -> [TemplateQuery] {
        guard let list = queryList else {
            return []
        }
        return list.filter({ (query: TemplateQuery) -> Bool in
            return query.isOpQuery()
        })
    }
    
    func getQueriesSortedByType() -> [TemplateQuery] {
        return self.getLookupQueries() + self.getOpQueries()
    }
    
}
