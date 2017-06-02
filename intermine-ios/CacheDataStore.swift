//
//  CacheDataStore.swift
//  intermine-ios
//
//  Created by Nadia on 5/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import CoreData

class CacheDataStore {
    
    private let modelName = General.modelName
    private let debug = true
    
    // TODO: compare versions instead using:
//    GET /version/release which tells you the version of the data *inside* the intermine
//    GET /version/intermine, which gives you the version of the intermine software that you're communicating with.
    private let minesUpdateInterval: Double = 432000 //5 days, TODO: -change this value to less often
    
    // MARK: Shared Instance
    
    static let sharedCacheDataStore : CacheDataStore = {
        let instance = CacheDataStore()
        return instance
    }()
    
    // MARK: Public methods
    
    func getParamsForListCall(mineUrl: String, type: String) -> [String]? {
        if let model = MineModel.getMineModelByUrl(url: mineUrl, context: self.managedContext) {
            if let fileName = model.xmlFile {
                let modelParser = MineModelParser(fromFileWithName: fileName)
                return modelParser.getViewNames(forType: type)
            }
        }
        return nil
    }

    func updateRegistryIfNeeded(completion: @escaping (_ mines: [Mine]?) -> ()) {
        if registryNeedsUpdate() {
            IntermineAPIClient.fetchRegistry { (jsonRes) in
                guard let jsonRes = jsonRes else {
                    completion(nil)
                    return
                }
                // update registry in Core Data
                eraseRegistry()
                if let registryDict = jsonRes as? [String: AnyObject] {
                    if let mines = registryDict["mines"] as? Array<[String: String]> {
                        var mineObjects: [Mine] = []
                        for mine in mines {
                            if let mineObj = Mine.createMineFromJson(json: mine, context: self.managedContext) {
                                mineObjects.append(mineObj)
                            }
                        }
                        save()
                        completion(mineObjects)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            let mines = Mine.getAllMines(context: self.managedContext)
            completion(mines)
        }
    }
    
    func save() {
        saveContext()
    }
    
    func registrySize() -> Int {
        if let registry = self.fetchCachedRegistry() {
            return registry.count
        } else {
            return 0
        }
    }
    
    func allRegistry() -> Array<Mine>? {
        return self.fetchCachedRegistry()?.sorted(by: { (mine0, mine1) -> Bool in
            guard let name0 = mine0.name, let name1 = mine1.name else {
                return false
            }
            return name0 < name1
        })
    }
    
    func findMineByUrl(url: String) -> Mine? {
        return Mine.getMineByUrl(url: url, context: self.managedContext)
    }
    
    func findMineByName(name: String) -> Mine? {
        return Mine.getMineByName(name: name, context: self.managedContext)
    }
    
    func updateRegistryModelsIfNeeded(mines: [Mine]) {
        for mine in mines {
            if let mineUrl = mine.url {
                self.updateModelIfNeeded(mineUrl: mineUrl)
            }
        }
    }
    
    func getMineNames() -> [String] {
        var mineNames: [String] = []
        if let registry = self.fetchCachedRegistry() {
            for mine in registry {
                if let mineName = mine.name {
                    mineNames.append(mineName)
                }
            }
        }
        mineNames.sort { (name1, name2) -> Bool in
            return name1 < name2
        }
        return mineNames
    }
    
    func saveSearchResult(searchResult: SearchResult) {
        if let type = searchResult.getType(), let id = searchResult.getId(), let mineName = searchResult.getMineName() {
            FavoriteSearchResult.createFavoriteSearchResult(type: type, fields: searchResult.viewableRepresentation() as NSDictionary, mineName: mineName, id: id, context: self.managedContext)
            save()
        }
    }
    
    func getSavedSearchResults() -> [FavoriteSearchResult]? {
        return FavoriteSearchResult.getAllSavedSearches(context: self.managedContext)
    }
    
    // MARK: Private methods
    
    private func updateModelIfNeeded(mineUrl: String) {
        
        if debug {
            self.updateMineModel(mineUrl: mineUrl)
            return
        }
        
        // 1. To check if xml is present, get MineModel by url
        if let model = MineModel.getMineModelByUrl(url: mineUrl, context: self.managedContext) {
            
            // 2. check if model.xmlFile is a valid url to existing resource
            if let fileName = model.xmlFile {
                if FileHandler.doesFileExist(fileName: fileName) {
                    
                    // 3. check intermine software version
                    IntermineAPIClient.fetchIntermineVersion(mineUrl: mineUrl, completion: { (versionString) in
                        if let versionString = versionString {
                            if versionString.isAboveVersion(version: General.baseVersion) {
                                
                                // 4. fetch last updated date
                                IntermineAPIClient.fetchReleaseDate(mineUrl: mineUrl, completion: { (date) in
                                    
                                    // 5. compare date of the mine object and fetched date
                                    if let fetchedReleaseDate = date, let storedReleaseDate = model.releaseDate {
                                        
                                        if !(fetchedReleaseDate.isEqual(storedReleaseDate)) {
                                            // needs update!
                                            self.updateMineModel(mineUrl: mineUrl)
                                        }
                                    }
                                })
                            } else {
                                // there is no way to tell if model has changed, fetch a new one
                                // this condition should always be false, other than on very old
                                // versions of backend
                                // needs update!
                                self.updateMineModel(mineUrl: mineUrl)
                            }
                        }
                    })
                } else {
                    // xml does not exist in documents directory, needs update!
                    self.updateMineModel(mineUrl: mineUrl)
                }
            }
        } else {
            // no model found, needs update!
            self.updateMineModel(mineUrl: mineUrl)
        }
    }

    
    private func updateMineModel(mineUrl: String) {
        //FIXME: use versioning flag?
        
        if let mine = Mine.getMineByUrl(url: mineUrl, context: self.managedContext), let mineName = mine.name {
            let fileName = mineName + ".xml"
            IntermineAPIClient.fetchModel(mineUrl: mineUrl, completion: { (xmlString) in
                FileHandler.writeToFile(fileName: fileName, contents: xmlString)
                IntermineAPIClient.fetchIntermineVersion(mineUrl: mineUrl, completion: { (versionString) in
                    if let versionString = versionString {
                        if versionString.isAboveVersion(version: General.baseVersion) {
                            IntermineAPIClient.fetchReleaseDate(mineUrl: mineUrl, completion: { (date) in
                                if let fetchedReleaseDate = date {
                                    MineModel.createMineModel(url: mineUrl, date: fetchedReleaseDate, xmlFile: fileName, versioned: true, context: self.managedContext)
                                } else {
                                    MineModel.createMineModel(url: mineUrl, date: "", xmlFile: fileName, versioned: false, context: self.managedContext)
                                }
                            })
                        } else {
                            // there is no way to tell if model has changed, fetch a new one
                            // this condition should always be false, other than on very old
                            // versions of backend
                            // needs update!
                            IntermineAPIClient.fetchReleaseDate(mineUrl: mineUrl, completion: { (date) in
                                if let fetchedReleaseDate = date {
                                    MineModel.createMineModel(url: mineUrl, date: fetchedReleaseDate, xmlFile: fileName, versioned: false, context: self.managedContext)
                                }
                            })
                        }
                    }
                })
            })
        }
    }

    private func fetchCachedRegistry() -> Array<Mine>? {
        do {
            if let registry = try self.managedContext.fetch(Mine.fetchRequest()) as? Array<Mine> {
                return registry
            } else {
                return []
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    private func registryNeedsUpdate() -> Bool {
        if debug == true {
            return true
        }
        
        if let registry = fetchCachedRegistry() {
            if let mine: Mine = registry.first, let lastUpdated = mine.lastUpdated {
                return NSDate.hasIntervalPassed(lastUpdated: lastUpdated, timeInterval: minesUpdateInterval)
            }
            return true
        }
        // TODO: handle this better!
        // if there was an error fetching
        return false
    }
    
    private func eraseRegistry() {
        if let registry = fetchCachedRegistry() {
            for mine in registry {
                self.managedContext.delete(mine)
            }
        }
    }
    
    // MARK: Core Data stack
    
    private lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }

}
