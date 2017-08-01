//
//  ResultsTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 7/27/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ResultsTableViewController: LoadingTableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filtered: [Any]?
    var controllerName: String = "" // to override this variable
    
    var data: [Any]? = [] {
        didSet {
            if let data = self.data {
                if data.count > 0 {
                    UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.tableView.reloadData()
                    }, completion: nil)
                    self.showingResult = true
                } else {
                    self.nothingFound = true
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if  let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: AppManager.sharedManager.selectedMine), let mineUrl = mine.url  {
            self.mineUrl = mineUrl
            self.fetchData(mineUrl: mineUrl)
        } else {
            self.defaultNavbarConfiguration(withTitle: self.controllerName)
            let failedView = FailedRegistryView.instantiateFromNib()
            self.tableView.addSubview(failedView)
        }

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func mineSelected(_ notification: NSNotification) {
        self.data = []
        self.isLoading = true
        IntermineAPIClient.cancelListsRequest()
        if let mineName = notification.userInfo?["mineName"] as? String {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                self.configureNavBar(mine: mine, shouldShowMenuButton: true)
                if let mineUrl = mine.url {
                    self.mineUrl = mineUrl
                    self.fetchData(mineUrl: mineUrl)
                }
            }
        }
    }
    
    func dataLoading(mineUrl: String, completion: @escaping (_ result: [Any]?, _ error: NetworkErrorType?) -> ()) {
        // to override
        // to fetch lists or templates based on VC
    }
    
    func filterData(searchText: String) -> [Any] {
        // to override
        return []
    }
    
    private func fetchData(mineUrl: String) {
        self.isLoading = true
        self.dataLoading(mineUrl: mineUrl) { (result, error) in
            self.data = result
        }
    }
    
    private func filterDataForSearchText(searchText: String?) {
        guard let searchText = searchText else {
            return
        }
        self.filtered = []
        self.filtered = self.filterData(searchText: searchText)
        UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            if let filtered = self.filtered {
                return filtered.count
            }
        } else {
            if let data = self.data {
                return data.count
            }
        }
        return 0
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterDataForSearchText(searchText: searchController.searchBar.text)
    }
    

}
