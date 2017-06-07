//
//  IntermineAPIClient.swift
//  intermine-ios
//
//  Created by Nadia on 4/25/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import Alamofire

class IntermineAPIClient: NSObject {
    
    static let jsonParams = ["format": "json"]
    static let manager = Alamofire.SessionManager.default
    
    // MARK: Private methods
    
    private class func sendJSONRequest(url: String, method: HTTPMethod, params: [String: String]?, completion: @escaping (_ result: [String: AnyObject]?) -> ()) {
        manager.session.configuration.timeoutIntervalForRequest = 120
        let updatedParams = IntermineAPIClient.updateParamsWithAuth(params: params)
        manager.request(url, method: method, parameters: updatedParams)
            .responseJSON {
                response in
                switch (response.result) {
                case .success:
                    if let JSON = response.result.value as? [String: AnyObject] {
                        completion(JSON)
                    } else {
                        completion(nil)
                    }
                    break
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        // timeout
                        completion(nil)
                    }
                    completion(nil)
                    print("\n\nRequest failed with error:\n \(error)")
                    break
                }
        }
    }
    
    private class func sendStringRequest(url: String, method: HTTPMethod, params: [String: String]?, completion: @escaping (_ result: String?) -> ()) {
        manager.session.configuration.timeoutIntervalForRequest = 120
        let updatedParams = IntermineAPIClient.updateParamsWithAuth(params: params)
        manager.request(url, method: method, parameters: updatedParams)
            .responseString {
                response in
                switch (response.result) {
                case .success:
                    completion(response.value)
                    break
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        // timeout
                        completion(nil)
                    }
                    completion(nil)
                    print("\n\nRequest failed with error:\n \(error)")
                    break
                }
        }
    }
    
    private class func updateParamsWithAuth(params: [String: String]?) -> [String: String]? {
        var mineName = ""
        if let selectedMine = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.selectedMine) {
            mineName = selectedMine
        } else {
            mineName = General.defaultMine
        }
        
        if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName), let mineUrl = mine.url {
            if let token = DefaultsManager.fetchFromDefaults(key: mineUrl) {
                var updatedParams = params
                updatedParams?["token"] = token
                return updatedParams
            }
        }
        return params
    }
    
    // MARK: Public methods
    
    class func cancelAllRequests() {
        manager.session.invalidateAndCancel()
    }
    
    class func makeSearchInMine(mineUrl: String, params: [String: String], completion: @escaping (_ result: SearchResult?, _ facets: FacetList?) -> ()) {
        
        let url = mineUrl + Endpoints.search
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: params) { (res) in
            if let res = res {
                var facetList: FacetList?
                if let facets = res["facets"] as? [String: AnyObject] {
                    
                    var categoryFacet: SearchFacet?
                    if let category = facets["Category"] as? [String: Int] {
                        
                        categoryFacet = SearchFacet(withType: "Category", contents: category)
                    }
                    
                    if let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: mineUrl), let mineName = mine.name, let categoryFacet = categoryFacet {
                        facetList = FacetList(withMineName: mineName, facet: categoryFacet)
                    }
                }
                
                if let result = res["results"] as? [[String: AnyObject]] {
                    for r in result {
                        if let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: mineUrl) {
                            if let mineName = mine.name {
                                let resObj = SearchResult(withType: r["type"] as? String, fields: r["fields"] as? [String: AnyObject], mineName: mineName, id: r["id"] as? Int)
                                completion(resObj, facetList)
                            }
                        }
                    }
                } else {
                    completion(nil, nil)
                }
            } else {
                 completion(nil, nil)
            }
        }
    }
    
    class func makeSearchOverAllMines(params: [String: String], completion: @escaping (_ result: [SearchResult]?, _ facetList: [FacetList]?) -> ()) {
        guard let registry = CacheDataStore.sharedCacheDataStore.allRegistry() else {
            completion(nil, nil)
            return
        }
        
        var results: [SearchResult] = []
        var facetLists: [FacetList] = []
        let totalMineCount = CacheDataStore.sharedCacheDataStore.registrySize()
        var currentMineCount = 0
        for mine in registry {
            currentMineCount += 1
            if let mineUrl = mine.url {
                if AppManager.sharedManager.shouldBreakLoading {
                    break
                }
                IntermineAPIClient.makeSearchInMine(mineUrl: mineUrl, params: params, completion: { (searchResObj, facetList) in
                    //
                    if let resObj = searchResObj {
                        results.append(resObj)
                    }
                    
                    if let facetList = facetList {
                        facetLists.append(facetList)
                    }

                    if currentMineCount == totalMineCount {
                        completion(results, facetLists)
                    }
                })
            } else {
                completion(nil, nil)
            }
        }
    }

    
    class func fetchSingleList(mineUrl: String, queryString: String, completion: @escaping (_ result: [String: AnyObject]?, _ params: [String: String]) -> ()) {
        let url = mineUrl + Endpoints.singleList
        let params: [String: String] = ["format": "json", "query": queryString, "start": "0", "size": "15"]
        IntermineAPIClient.sendJSONRequest(url: url, method: .post, params: params) { (res) in
            completion(res, params)
        }
    }
    
    class func fetchRegistry(completion: (_ result: NSDictionary?) -> ()) {
        // TODO: Use registry endpoint
        // for now: read registry from .json file
        let registryPath = Bundle.main.path(forResource: "registry", ofType: ".json")
        
        guard let jsonData = try? NSData(contentsOfFile: registryPath!, options: NSData.ReadingOptions.mappedIfSafe) else {
            completion(nil)
            return
        }
        
        if let jsonResult = try? JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
            completion(jsonResult)
        } else {
            completion(nil)
        }
    }
    
    class func fetchIntermineVersion(mineUrl: String, completion: @escaping (_ result: String?) -> ()) {
        let url = mineUrl + Endpoints.intermineVersion
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams) { (result) in
            if let result = result {
                if let versionString = result["version"] as? String {
                    completion(versionString)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    class func fetchReleaseDate(mineUrl: String, completion: @escaping (_ result: String?) -> ()) {
        let url = mineUrl + Endpoints.modelReleased
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams) { (result) in
            if let result = result {
                if let releaseString = result["version"] as? String {
                    completion(releaseString)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
        }
    }
    
    class func fetchModel(mineUrl: String, completion: @escaping (_ result: String?) -> ()) {
        let url = mineUrl + Endpoints.modelDescription
        IntermineAPIClient.sendStringRequest(url: url, method: .get, params: nil) { (xmlString) in
            completion(xmlString)
        }
    }
    
    class func fetchLists(mineUrl: String, completion: @escaping (_ result: [List]?) -> ()) {
        let url = mineUrl + Endpoints.lists
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams) { (result) in
            var listObjects: [List] = []
            if let result = result {
                if let lists = result["lists"] as? [[String: AnyObject]] {
                    for list in lists {
                        let listObj = List(withTitle: list["title"] as? String,
                                           info: list["description"] as? String,
                                           size: list["size"] as? Int,
                                           type: list["type"] as? String,
                                           name: list["name"] as? String,
                                           status: list["status"] as? String)
                        listObjects.append(listObj)
                    }
                    completion(listObjects)
                }
            } else {
                completion(nil)
            }
        }
        
    }
    
    class func fetchTemplates(mineUrl: String, completion: @escaping (_ result: TemplatesList?) -> ()) {
        let url = mineUrl + Endpoints.templates
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams) { (result) in
            if let result = result {
                if let templates = result["templates"] as? [String: AnyObject] {
                    var templateList: [Template] = []
                    for (_, template) in templates {
                        var queryList: [TemplateQuery] = []
                        if let queries = template["where"] as? [[String: AnyObject]] {
                            for query in queries {
                                let queryObj = TemplateQuery(withValue: query["value"] as? String, code: query["code"] as? String, op: query["op"] as? String, constraint: query["path"] as? String)
                                queryList.append(queryObj)
                            }
                        }
                        let templateObj = Template(withTitle: template["title"] as? String, description: template["description"] as? String, queryList: queryList, name: template["name"] as? String, mineUrl: mineUrl)
                        templateList.append(templateObj)
                    }
                    let templatesListObj = TemplatesList(withTemplates: templateList, mine: mineUrl)
                    completion(templatesListObj)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    class func fetchTemplateResults(mineUrl: String, queryParams: [String: String], completion: @escaping (_ res: [String: AnyObject]?) -> ()) {
        let url = mineUrl + Endpoints.templateResults
        IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: queryParams) { (res) in
            completion(res)
        }
    }
    
    class func getTemplateResultsCount(mineUrl: String, queryParams: [String: String], completion: @escaping (_ res: String?) -> ()) {
        let url = mineUrl + Endpoints.templateResults
        var countParams = queryParams
        countParams["format"] = "count"
        IntermineAPIClient.sendStringRequest(url: url, method: .get, params: countParams) { (res) in
            completion(res)
        }
    }
    
    class func getToken(mineUrl: String, username: String, password: String, completion: @escaping (_ success: Bool) -> ()) -> () {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        Alamofire.request(mineUrl + Endpoints.tokens, headers: headers)
            .responseJSON { (response) in
                if let JSON = response.result.value as? [String: AnyObject] {
                    if let successful = JSON["wasSuccessful"] as? Bool {
                        if successful {
                            // store token in nsuserdefaults
                            if let token = JSON["token"] as? String {
                                DefaultsManager.storeInDefaults(key: mineUrl, value: token)
                                completion(true)
                            }
                        } else {
                            // create token
                            self.createToken(mineUrl: mineUrl, username: username, password: password, completion: { (success) in
                                completion(success)
                            })
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
        }
    }
    
    
    class func createToken(mineUrl: String, username: String, password: String, completion: @escaping (_ success: Bool) -> ()) -> () {

        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: username, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let params = ["type": "perm", "message": "iOS client"]
        
        Alamofire.request(mineUrl + Endpoints.tokens, method: .post, parameters: params, headers: headers)
            .responseJSON { (response) in
                if let JSON = response.result.value as? [String: AnyObject] {
                    if let successful = JSON["wasSuccessful"] as? Bool {
                        if successful {
                            // store token in nsuserdefaults
                            if let token = JSON["token"] as? String {
                                DefaultsManager.storeInDefaults(key: mineUrl, value: token)
                                completion(true)
                            }
                        } else {
                            // TODO: user is not auth'd, show message
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
        }
    }
    
}
