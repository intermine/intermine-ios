//
//  AllListsViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ListsViewController: ResultsTableViewController {
    
    private var lists: [List]? = [] {
        didSet {
            if let lists = self.lists {
                self.data = lists
            }
        }
    }
    
    override var mineUrl: String? {
        willSet(newValue) {
            if newValue != self.mineUrl {
                AppManager.sharedManager.listsLoadedWithNewMine = true
            }
        }
    }
    
    override func dataLoading(mineUrl: String, completion: @escaping ([Any]?, NetworkErrorType?) -> ()) {
        IntermineAPIClient.fetchLists(mineUrl: mineUrl, completion: { (lists, error) in
            super.listsLoaded = true
            guard let lists = lists else {
                if let error = error {
                    if let errorMessage = NetworkErrorHandler.getErrorMessage(errorType: error) {
                        self.alert(message: errorMessage)
                    }
                }
                return
            }
            // Sort list objects by "authorized"
            let sortedLists = lists.sorted { $0.getAuthd() && !$1.getAuthd() }
            self.lists = sortedLists
            completion(sortedLists, error)
        })
    }
    
    override func filterData(searchText: String) -> [Any] {
        var result: [List] = []
        if let lists = self.lists {
            for list in lists {
                if let title = list.getTitle() {
                    if title.range(of: searchText) != nil {
                        result.append(list)
                    }
                }
            }
        }
        return result
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if let filtered = self.filtered as? [List] {
                cell.list = filtered[indexPath.row]
            }
        } else {
            if let lists = self.lists, lists.count > 0 {
                cell.list = lists[indexPath.row]
            }
        }
        return cell
    }
    
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lists = self.lists {
            let selectedList = lists[indexPath.row]
            if let selectedType = selectedList.getType(), let selectedValue = selectedList.getValue() {
                
                // Based on type, find the views from xml file
                // set value and make request
                
                if let mineUrl = self.mineUrl {
                    if let views = CacheDataStore.sharedCacheDataStore.getParamsForListCall(mineUrl: mineUrl, type: selectedType) {
                        if let viewsQuery = QueryBuilder.buildQuery(views: views, type: selectedType, value: selectedValue) {
                            
                            if let fetchedListsCV = FetchedListsViewController.fetchedListsViewController(withMineUrl: mineUrl, viewsQuery: viewsQuery, type: selectedType, listTitle: selectedList.getName()) {
                                self.navigationController?.pushViewController(fetchedListsCV, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }

}
