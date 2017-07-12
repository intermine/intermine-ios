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
    
    func getTotalFacetCount() -> Int {
        var count = 0
        if let formattedFacets = self.getFormattedFacetsList() {
            for facet in formattedFacets {
                if let num = facet.getNumericCount() {
                    count += num
                }
            }
        }
        return count
    }
    
}
