//
//  MineModel+CoreDataProperties.swift
//  intermine-ios
//
//  Created by Nadia on 5/16/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData


extension MineModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MineModel> {
        return NSFetchRequest<MineModel>(entityName: "MineModel")
    }

    @NSManaged public var releaseDate: String?
    @NSManaged public var url: String?
    @NSManaged public var versioned: Bool
    @NSManaged public var xmlFile: String?

}
