//
//  FavoriteSearchResult+CoreDataClass.swift
//  intermine-ios
//
//  Created by Nadia on 5/29/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData

@objc(FavoriteSearchResult)
public class FavoriteSearchResult: NSManagedObject {
    
    class func getFavoriteSearchResultById(id: String, context: NSManagedObjectContext) -> FavoriteSearchResult? {
        let request = NSFetchRequest<FavoriteSearchResult>(entityName: "FavoriteSearchResult")
        request.predicate =  NSPredicate(format: "id == %@", id)
        if let results = try? context.fetch(request) {
            if results.count > 0 {
                return results.first
            }
        }
        return nil
    }
    
    class func getAllSavedSearches(context: NSManagedObjectContext) -> [FavoriteSearchResult]? {
        let request = NSFetchRequest<FavoriteSearchResult>(entityName: "FavoriteSearchResult")
        if let res = try? context.fetch(request) {
            if res.count > 0 {
                return res
            }
        }
        return nil
    }
    
    class func getFavoriteSearchById(id: String, context: NSManagedObjectContext) -> FavoriteSearchResult? {
        let request = NSFetchRequest<FavoriteSearchResult>(entityName: "FavoriteSearchResult")
        request.predicate =  NSPredicate(format: "id == %@", id)
        if let res = try? context.fetch(request) {
            if res.count > 0 {
                return res.first
            }
        }
        return nil
    }
    
    class func createFavoriteSearchResult(type: String, fields: NSDictionary, mineName: String, id: String, context: NSManagedObjectContext) {
        guard let favSearchResult = NSEntityDescription.entity(forEntityName: "FavoriteSearchResult", in: context) else {
            return
        }
        var result: FavoriteSearchResult?
        if let existingResult = FavoriteSearchResult.getFavoriteSearchResultById(id: id, context: context) {
            result = existingResult
        } else {
            result = FavoriteSearchResult(entity: favSearchResult, insertInto: context)
        }
        result?.id = id
        result?.type = type
        result?.fields = fields
        result?.mineName = mineName
    }
    
    func getPubmedId() -> String? {
        if self.type == CategoryType.Publication.rawValue {
            if let pubmedId = self.fields?["pubMedId"] as? String {
                return pubmedId
            }
        }
        return nil
    }
    
    func viewableRepresentation() -> [String: String] {
        var representation: [String: String] = [:]
        if let type = self.type {
            representation["type"] = type
        }
        if let mineName = self.mineName {
            representation["mine"] = mineName
        }
        if let fields = self.fields as? [String: String] {
            for (key, value) in fields {
                representation[key] = "\(value)"
            }
        }
        return representation
    }

}
