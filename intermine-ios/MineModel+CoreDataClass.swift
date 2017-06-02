//
//  MineModel+CoreDataClass.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData

@objc(MineModel)
public class MineModel: NSManagedObject {
    
    class func createMineModel(url: String, date: String, xmlFile: String, versioned: Bool, context: NSManagedObjectContext) {
        guard let intermineModelEntity = NSEntityDescription.entity(forEntityName: "MineModel", in: context) else {
            return
        }
        var model: MineModel?
        if let existingModel = MineModel.getMineModelByUrl(url: url, context: context) {
            model = existingModel
        } else {
            model = MineModel(entity: intermineModelEntity, insertInto: context)
        }
        model?.url = url
        model?.versioned = versioned // if Intermine backend is > 1.6.6
        model?.releaseDate = date // should come from separate call
        model?.xmlFile = xmlFile
    }
    
    class func getMineModelByUrl(url: String, context: NSManagedObjectContext) -> MineModel? {
        let request = NSFetchRequest<MineModel>(entityName: "MineModel")
        request.predicate =  NSPredicate(format: "url == %@", url)
        if let models = try? context.fetch(request) {
            if models.count > 0 {
                return models.first
            }
        }
        return nil
    }

}
