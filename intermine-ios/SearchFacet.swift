//
//  SearchFacet.swift
//  intermine-ios
//
//  Created by Nadia on 5/19/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class SelectedFacet {
    
    private var mineName: String?
    private var facetName: String?
    private var count: String?
    
    init(withMineName: String?, facetName: String?, count: String?) {
        self.mineName = withMineName
        self.facetName = facetName
        self.count = count
    }
    
    func getFacetName() -> String? {
        return self.facetName
    }
    
    func getMineName() -> String? {
        return self.mineName
    }
    
    func getCount() -> Int? {
        guard let count = self.count else {
            return nil
        }
        return Int(count)
    }
}

class FormattedFacet {
    
    private var title: String?
    private var count: String?
    
    init(withTitle: String?, count: String) {
        self.title = withTitle
        self.count = count
    }
    
    func getTitle() -> String? {
        return self.title
    }
    
    func getCount() -> String? {
        return self.count
    }
    
    func getNumericCount() -> Int? {
        if let count = self.count {
            return Int(count)
        }
        return 0
    }
    
}


class SearchFacet {
    
    private var type: String?
    private var contents: [String: Int]?
    
    init(withType: String?, contents: [String: Int]) {
        self.type = withType // Category
        self.contents = contents // ["ProteinDomain": 1]
    }
    
    func getType() -> String? {
        return self.type
    }
    
    func getContents() -> [String: Int]? {
        return self.contents
    }
    
    func getFormattedContents() -> [FormattedFacet]? {
        // list of formatted facets
        guard let contents = self.contents else {
            return nil
        }
        var formattedFacets: [FormattedFacet] = []
        for (key, value) in contents {
            formattedFacets.append(FormattedFacet(withTitle: key, count: "\(value)"))
        }
        return formattedFacets
    }

}
