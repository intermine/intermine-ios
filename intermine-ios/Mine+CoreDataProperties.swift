//
//  Mine+CoreDataProperties.swift
//  intermine-ios
//
//  Created by Nadia on 5/9/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData


extension Mine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mine> {
        return NSFetchRequest<Mine>(entityName: "Mine")
    }

    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var theme: String?

}
