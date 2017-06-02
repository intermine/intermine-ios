//
//  Mine+CoreDataClass.swift
//  intermine-ios
//
//  Created by Nadia on 5/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData

@objc(Mine)
public class Mine: NSManagedObject {
    
    class func createMineFromJson(json: Dictionary<String, String>, context: NSManagedObjectContext) -> Mine? {
        guard let mineEntiry = NSEntityDescription.entity(forEntityName: "Mine", in: context) else {
            return nil
        }
        var mine: Mine?
        if let name = json["name"], let existingMine = Mine.getMineByName(name: name, context: context) {
            mine = existingMine
        } else {
            mine = Mine(entity: mineEntiry, insertInto: context)
        }
        mine?.name = json["name"]
        mine?.url = json["url"]
        mine?.theme = json["theme"]
        mine?.lastUpdated = NSDate()
        return mine
    }
    
    class func getMineByName(name: String, context: NSManagedObjectContext) -> Mine? {
        let request = NSFetchRequest<Mine>(entityName: "Mine")
        request.predicate =  NSPredicate(format: "name == %@", name)
        if let mines = try? context.fetch(request) {
            if mines.count > 0 {
                return mines.first
            }
        }
        return nil
    }
    
    class func getMineByUrl(url: String, context: NSManagedObjectContext) -> Mine? {
        let request = NSFetchRequest<Mine>(entityName: "Mine")
        request.predicate =  NSPredicate(format: "url == %@", url)
        if let mines = try? context.fetch(request) {
            if mines.count > 0 {
                return mines.first
            }
        }
        return nil
    }
    
    class func getAllMines(context: NSManagedObjectContext) -> [Mine]? {
        let request = NSFetchRequest<Mine>(entityName: "Mine")
        if let mines = try? context.fetch(request) {
            if mines.count > 0 {
                return mines
            }
        }
        return nil
    }

}
