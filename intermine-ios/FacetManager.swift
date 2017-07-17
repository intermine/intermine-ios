//
//  FacetManager.swift
//  intermine-ios
//
//  Created by Nadia on 7/16/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation

class FacetManager {
    
    private var facets: [FacetList]? = []
    
    static let shared : FacetManager = {
        let instance = FacetManager()
        return instance
    }()
    
    func updateFacets(facets: [FacetList]?) {
        self.facets = facets
    }

    
    func getFacets() -> [FacetList]? {
        return self.facets
    }
    
}
