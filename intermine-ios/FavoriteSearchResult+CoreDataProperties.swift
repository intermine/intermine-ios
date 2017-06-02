//
//  FavoriteSearchResult+CoreDataProperties.swift
//  intermine-ios
//
//  Created by Nadia on 5/29/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData


extension FavoriteSearchResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteSearchResult> {
        return NSFetchRequest<FavoriteSearchResult>(entityName: "FavoriteSearchResult")
    }

    @NSManaged public var type: String?
    @NSManaged public var fields: NSDictionary?
    @NSManaged public var mineName: String?
    @NSManaged public var id: String?

}
