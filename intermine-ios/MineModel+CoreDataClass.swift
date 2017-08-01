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
    
    class func createMineModel(url: String, releaseId: String?, xmlFile: String, versionId: String?, context: NSManagedObjectContext) {
        guard let intermineModelEntity = NSEntityDescription.entity(forEntityName: "MineModel", in: context) else {
            return
        }
        var model: MineModel?
        if let existingModel = MineModel.getMineModelByUrl(url: url, context: context) {
            model = existingModel
        } else {
            model = MineModel(entity: intermineModelEntity, insertInto: context)
        }
        var urlCopy = url
        if urlCopy.hasSuffix("/") {
            urlCopy = String(urlCopy.characters.dropLast())
        }
        model?.url = urlCopy
        model?.versionId = versionId
        model?.releaseId = releaseId
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
