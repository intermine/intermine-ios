//
//  MineModel+CoreDataProperties.swift
//  intermine-ios
//
//  Created by Nadia on 6/23/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData


extension MineModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MineModel> {
        return NSFetchRequest<MineModel>(entityName: "MineModel")
    }

    @NSManaged public var releaseId: String?
    @NSManaged public var url: String?
    @NSManaged public var xmlFile: String?
    @NSManaged public var versionId: String?

}
