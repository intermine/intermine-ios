//
//  IntermineAPIClient.swift
//  intermine-ios
//
//  Created by Nadia on 4/25/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import Alamofire

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        if let reachable = NetworkReachabilityManager()?.isReachable {
            return reachable
        } else {
            return false
        }
    }
}

class Counter: NSObject {
    
    private var currentMineCount = 0
    
    override init() {
        super.init()
        self.currentMineCount = 0
    }
    
    func incrementMineCount() {
        self.currentMineCount += 1
    }
    
    func resetMineCount() {
        self.currentMineCount = 0
    }
    
    func getCurrentMineCount() -> Int {
        return self.currentMineCount
    }
}



class IntermineAPIClient: NSObject {
    
    static let jsonParams = ["format": "json"]
    static let manager = Alamofire.SessionManager.default
    static let counter = Counter()
    static let useDebugServer = false
    
    static var listsRequest: Request?
    static var templatesRequest: Request?
    
    // MARK: Private methods

    private class func sendJSONRequest(url: String, method: HTTPMethod, params: [String: String]?, timeOutInterval: Double?, shouldUseAuth: Bool, completion: @escaping (_ result: [String: AnyObject]?, _ error: NetworkErrorType?) -> ()) -> Request {
        var interval = General.timeoutIntervalForRequest
        if !(timeOutInterval == nil) {
            interval = timeOutInterval!
        }
        manager.session.configuration.timeoutIntervalForRequest = interval
        var paramsToUse = params
        if shouldUseAuth {
            paramsToUse = IntermineAPIClient.updateParamsWithAuth(params: params)
        }
        return manager.request(url, method: method, parameters: paramsToUse)
            .responseJSON {
                response in
                switch (response.result) {
                case .success:
                    if let JSON = response.result.value as? [String: AnyObject] {
                        completion(JSON, nil)
                    } else {
                        completion(nil, nil)
                    }
                    break
                case .failure(let error):
                    let errorType = NetworkErrorHandler.processError(error: error)
                    completion(nil, errorType)
                    print("\n\nRequest failed with error:\n \(error)")
                    break
                }
        }
    }
    
    private class func sendStringRequest(url: String, method: HTTPMethod, params: [String: String]?, shouldUseAuth: Bool, completion: @escaping (_ result: String?, _ error: NetworkErrorType?) -> ()) {
        manager.session.configuration.timeoutIntervalForRequest = General.timeoutIntervalForRequest
        var paramsToUse = params
        if shouldUseAuth {
            paramsToUse = IntermineAPIClient.updateParamsWithAuth(params: params)
        }
        manager.request(url, method: method, parameters: paramsToUse)
            .responseString {
                response in
                switch (response.result) {
                case .success:
                    completion(response.value, nil)
                    break
                case .failure(let error):
                    let errorType = NetworkErrorHandler.processError(error: error)
                    completion(nil, errorType)
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
    
    private class func fetchIntermineVersion(mineUrl: String, completion: @escaping (_ result: String?, _ error: NetworkErrorType?) -> ()) {
        // TODO: - remove method if not needed
        let url = mineUrl + Endpoints.intermineVersion
        var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams, timeOutInterval: nil, shouldUseAuth: false) { (result, error) in
            if let result = result {
                if let versionString = result["version"] {
                    completion("\(versionString)", nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    private class func fetchReleaseId(mineUrl: String, completion: @escaping (_ result: String?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.modelReleased
        var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams, timeOutInterval: nil, shouldUseAuth: false) { (result, error) in
            if let result = result {
                if let releaseString = result["version"] {
                    completion("\(releaseString)", nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    // MARK: Public methods
    
    class func fetchOrganismsForMine(mineUrl: String, completion: @escaping (_ result: [String?], _ error: NetworkErrorType?) -> ()) {
        let query = "<query model=\"genomic\" view=\"Organism.shortName\" sortOrder=\"Organism.shortName ASC\"></query>"
        let params = ["query": query, "format": "json"]
        let urlString = mineUrl + Endpoints.singleList
        
        _ = IntermineAPIClient.sendJSONRequest(url: urlString, method: .get, params: params, timeOutInterval: General.timeoutIntervalForRequest, shouldUseAuth: false) { (result, error) in
            var organisms: [String] = []
            if let results = result?["results"] as? [[Any]] {
                for organism in results {
                    if organism.count > 0 {
                        if let o = organism[0] as? String {
                            organisms.append(o)
                        }
                    }
                }
            }
            completion(organisms, error)
        }
    }
    
    class func cancelAllRequests() {
        manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
    class func cancelListsRequest() {
        IntermineAPIClient.listsRequest?.cancel()
    }
    
    class func cancelTemplatesRequest() {
        IntermineAPIClient.templatesRequest?.cancel()
    }
    
    class func makeSearchInMine(mineUrl: String, params: [String: String], completion: @escaping (_ result: SearchResult?, _ facets: FacetList?, _ error: NetworkErrorType?) -> ()) {
        
        let url = mineUrl + Endpoints.search
        var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: params, timeOutInterval: nil, shouldUseAuth: false) { (res, error) in
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
                    if result.count == 0 {
                        completion(nil, nil, nil)
                        return
                    }
                    
                    for r in result {
                        if let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: mineUrl) {
                            
                            if let mineName = mine.name {
                                let resObj = SearchResult(withType: r["type"] as? String, fields: r["fields"] as? [String: AnyObject], mineName: mineName, id: r["id"] as? Int)
                                
                                completion(resObj, facetList, nil)
                            }
                        }
                    }
                    
                } else {
                    completion(nil, nil, error)
                }
            } else {
                 completion(nil, nil, error)
            }
        }
    }
    
    class func makeSearchOverAllMines(params: [String: String], completion: @escaping (_ result: [SearchResult]?, _ facetList: [FacetList]?, _ error: NetworkErrorType?) -> ()) {
        guard let registry = CacheDataStore.sharedCacheDataStore.allRegistry() else {
            completion(nil, nil, NetworkErrorType.Unknown)
            return
        }
        
        AppManager.sharedManager.cachedMineIndex = nil
        
        var results: [SearchResult] = []
        var facetLists: [FacetList] = []
        let totalMineCount = CacheDataStore.sharedCacheDataStore.registrySize()

        for mine in registry {
            
            if let mineUrl = mine.url {
                
                IntermineAPIClient.makeSearchInMine(mineUrl: mineUrl, params: params, completion: { (searchResObj, facetList, error) in
                    
                    IntermineAPIClient.counter.incrementMineCount()
                    
                    if let resObj = searchResObj {
                        results.append(resObj)
                    }
                    
                    if let facetList = facetList {
                        facetLists.append(facetList)
                    }

                    if IntermineAPIClient.counter.getCurrentMineCount() == totalMineCount {
                        IntermineAPIClient.counter.resetMineCount()
                        completion(results, facetLists, nil)
                    }
                })
            } else {
                completion(nil, nil, NetworkErrorType.Unknown)
            }
        }
    }

    
    class func fetchSingleList(mineUrl: String, queryString: String, completion: @escaping (_ result: [String: AnyObject]?, _ params: [String: String], _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.singleList
        let params: [String: String] = ["format": "json", "query": queryString, "start": "0", "size": "15"]
        var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .post, params: params, timeOutInterval: nil, shouldUseAuth: true) { (res, error) in
            completion(res, params, error)
        }
    }
    
    class func fetchRegistry(completion: @escaping (_ result: [String: AnyObject]?, _ error: NetworkErrorType?) -> ()) {
        if useDebugServer {
            // TODO: make changes in debug server
        } else {
            let url = Endpoints.registryDomain + Endpoints.registryInstances
            var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: nil, timeOutInterval: General.timeoutForRegistryUpdate, shouldUseAuth: false) { (res, error) in
                completion(res, error)
            }
        }
    }
    
    class func fetchVersioning(mineUrl: String, completion: @escaping (_ releaseId: String?, _ error: NetworkErrorType?) -> ()) {
        // TODO: - check do I need to use version id or release id will change when version id changes?
        IntermineAPIClient.fetchReleaseId(mineUrl: mineUrl) { (releaseId, error) in
            completion(releaseId, error)
        }
    }
    
    class func fetchModel(mineUrl: String, completion: @escaping (_ result: String?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.modelDescription
        IntermineAPIClient.sendStringRequest(url: url, method: .get, params: nil, shouldUseAuth: false) { (xmlString, error) in
            completion(xmlString, error)
        }
    }
    
    class func fetchLists(mineUrl: String, completion: @escaping (_ result: [List]?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.lists
        IntermineAPIClient.listsRequest = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams, timeOutInterval: nil, shouldUseAuth: true) { (result, error) in
            var listObjects: [List] = []
            if let result = result {
                if let lists = result["lists"] as? [[String: AnyObject]] {
                    for list in lists {
                        let listObj = List(withTitle: list["title"] as? String,
                                           info: list["description"] as? String,
                                           size: list["size"] as? Int,
                                           type: list["type"] as? String,
                                           name: list["name"] as? String,
                                           status: list["status"] as? String,
                                           authorized: list["authorized"] as? Bool)
                        listObjects.append(listObj)
                    }
                    completion(listObjects, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func fetchTemplates(mineUrl: String, completion: @escaping (_ result: TemplatesList?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.templates
        IntermineAPIClient.templatesRequest = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: jsonParams, timeOutInterval: nil, shouldUseAuth: true) { (result, error) in
            if let result = result {
                if let templates = result["templates"] as? [String: AnyObject] {
                    var templateList: [Template] = []
                    for (_, template) in templates {
                        var queryList: [TemplateQuery] = []
                        if let queries = template["where"] as? [[String: AnyObject]] {
                            for query in queries {
                                var valueString = ""
                                if let value = query["value"] as? String {
                                    valueString = value
                                }
                                if let valueArray = query["values"] as? [String] {
                                    valueString = valueArray.joined(separator: ",")
                                }
                                
                                let queryObj = TemplateQuery(withValue: valueString, code: query["code"] as? String, op: query["op"] as? String, constraint: query["path"] as? String, editable: query["editable"] as? Bool, extraValue: query["extraValue"] as? String)
                                if queryObj.getOperation() != nil {
                                    queryList.append(queryObj)
                                }
                            }
                        }
                        var authd = false
                        var templateTags: [String] = []
                        if let tags = template["tags"] as? [String] {
                            if !tags.contains("im:public") {
                                authd = true
                            }
                            for tag in tags {
                                if tag.contains("im:aspect") {
                                    let tagElements = tag.components(separatedBy: ":")
                                    if tagElements.count >= 3 {
                                        let tagName = tagElements[2]
                                        templateTags.append(tagName)
                                    }
                                }
                            }
                        }
                        let templateObj = Template(withTitle: template["title"] as? String, description: template["description"] as? String, queryList: queryList, name: template["name"] as? String, mineUrl: mineUrl, authorized: authd, tags: templateTags)
                        templateList.append(templateObj)
                    }
                    let templatesListObj = TemplatesList(withTemplates: templateList, mine: mineUrl)
                    completion(templatesListObj, nil)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func fetchTemplateResults(mineUrl: String, queryParams: [String: String], completion: @escaping (_ res: [String: AnyObject]?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.templateResults
        var _ = IntermineAPIClient.sendJSONRequest(url: url, method: .get, params: queryParams, timeOutInterval: nil, shouldUseAuth: true) { (res, error) in
            completion(res, error)
        }
    }
    
    class func getTemplateResultsCount(mineUrl: String, queryParams: [String: String], completion: @escaping (_ res: String?, _ error: NetworkErrorType?) -> ()) {
        let url = mineUrl + Endpoints.templateResults
        var countParams = queryParams
        countParams["format"] = "count"
        IntermineAPIClient.sendStringRequest(url: url, method: .get, params: countParams, shouldUseAuth: true) { (res, error) in
            completion(res, error)
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
