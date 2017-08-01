//
//  Mine+CoreDataProperties.swift
//  intermine-ios
//
//  Created by Nadia on 7/30/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData


extension Mine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mine> {
        return NSFetchRequest<Mine>(entityName: "Mine")
    }

    @NSManaged public var lastTimeUpdated: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var releaseVersion: String?
    @NSManaged public var theme: String?
    @NSManaged public var url: String?
    @NSManaged public var organisms: NSArray?

}
