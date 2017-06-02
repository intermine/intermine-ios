//
//  FacetList.swift
//  intermine-ios
//
//  Created by Nadia on 5/19/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation


class FacetList {
    
    private var mine: String? // mineName
    private var categoryFacet: SearchFacet? // categories
    
    init(withMineName: String?, facet: SearchFacet) {
        self.mine = withMineName
        self.categoryFacet = facet
    }
    
    func getMine() -> String? {
        return self.mine
    }
    
    func getCategoryFacet() -> SearchFacet? {
        return self.categoryFacet
    }
    
    func getFormattedFacetsList() -> [FormattedFacet]? {
        return self.categoryFacet?.getFormattedContents()
    }
    
}
