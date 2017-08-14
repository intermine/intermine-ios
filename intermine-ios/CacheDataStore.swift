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

    func updateRegistryIfNeeded(completion: @escaping (_ mines: [Mine]?, _ error: NetworkErrorType?) -> ()) {
        
        if Connectivity.isConnectedToInternet() {
            if registryNeedsUpdate() {
                IntermineAPIClient.fetchRegistry { (jsonRes, error) in
                    guard let jsonRes = jsonRes else {
                        completion(nil, error)
                        return
                    }
                    // update registry in Core Data
                    self.eraseRegistry()
                    var mineObjects: [Mine] = []
                    if let instances = jsonRes["instances"] as? [[String: AnyObject]] {
                        for instance in instances {
                            if let mineObj = Mine.createMineFromJson(json: instance, context: self.managedContext), let mineUrl = mineObj.url {
                                IntermineAPIClient.fetchOrganismsForMine(mineUrl: mineUrl, completion: { (res, error) in
                                    mineObj.organisms = res as NSArray
                                })
                                mineObjects.append(mineObj)
                            }
                        }
                        self.save()
                        completion(mineObjects, error)
                    } else {
                        completion(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    let mines = Mine.getAllMines(context: self.managedContext)
                    completion(mines, nil)
                })
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                let mines = Mine.getAllMines(context: self.managedContext)
                completion(mines, nil)
            })
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
    
    func unsaveSearchResult(withId: String) {
        if let searchResult = getSavedSearchById(id: withId) {
            delete(obj: searchResult)
        }
    }
    
    func getSavedSearchResults() -> [FavoriteSearchResult]? {
        return FavoriteSearchResult.getAllSavedSearches(context: self.managedContext)
    }
    
    func getSavedSearchById(id: String) -> FavoriteSearchResult? {
        return FavoriteSearchResult.getFavoriteSearchResultById(id: id, context: self.managedContext)
    }
    
    // MARK: Private methods
    
    private func delete(obj: NSManagedObject) {
        self.managedContext.delete(obj)
        save()
    }
    
    private func updateModelIfNeeded(mineUrl: String) {
        
        if debug {
            self.createMineModel(mineUrl: mineUrl)
            return
        }
        
        // check if xml is present, get MineModel by url
        if let model = MineModel.getMineModelByUrl(url: mineUrl, context: self.managedContext) {
            
            // check if model.xmlFile is a valid url to existing resource
            if let fileName = model.xmlFile {
                if FileHandler.doesFileExist(fileName: fileName) {
                    
                    // since it is called after mines version is uptated
                    // we can use mines version
                    if let mine = Mine.getMineByUrl(url: mineUrl, context: self.managedContext) {
                        if let releaseId = mine.releaseVersion {
                            if !(releaseId.isEqualTo(comparedTo: model.releaseId)) {
                                // release ids differ, needs an update
                                self.updateMineModel(model: model, releaseId: releaseId, xmlFile: nil)
                                return
                            }
                        }
                    }
                } else {
                    // xml does not exist in documents directory, model needs an udpate with new xml
                    self.delete(obj: model)
                    self.createMineModel(mineUrl: mineUrl)
                    return
                }
            }
        } else {
            // no model found, create mine model
            self.createMineModel(mineUrl: mineUrl)
            return
        }
        return
    }

    
    private func createMineModel(mineUrl: String) {
        if let mine = Mine.getMineByUrl(url: mineUrl, context: self.managedContext), let mineName = mine.name {
            let fileName = mineName + ".xml"
            IntermineAPIClient.fetchModel(mineUrl: mineUrl, completion: { (xmlString, error) in
                if let xmlString = xmlString as String? {
                    FileHandler.writeToFile(fileName: fileName, contents: xmlString)
                    if let releaseId = mine.releaseVersion {
                        MineModel.createMineModel(url: mineUrl, releaseId: releaseId, xmlFile: fileName, versionId: nil, context: self.managedContext)
                        self.save()
                    }
                }
            })
        }
    }
    
    private func updateMineModel(model: MineModel, releaseId: String?, xmlFile: String?) {
        var changeCount = 0
        if let releaseId = releaseId {
            model.releaseId = releaseId
            changeCount += 1
        }
        if let xmlFile = xmlFile {
            model.xmlFile = xmlFile
            changeCount += 1
        }
        if changeCount >= 1 {
            self.save()
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
        if let registry = fetchCachedRegistry(), registry.count > 0 {
            if let mine: Mine = registry.first, let lastUpdated = mine.lastTimeUpdated {
                return NSDate.hasIntervalPassed(lastUpdated: lastUpdated, timeInterval: minesUpdateInterval)
            }
            return true
        } else {
            return true
        }
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
