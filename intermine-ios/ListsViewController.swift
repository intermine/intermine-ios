//
//  AllListsViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/14/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ListsViewController: LoadingTableViewController {
    
    private var lists: [List]? = [] {
        didSet {
            if let lists = self.lists {
                if lists.count > 0 {
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
            self.fetchLists(mineUrl: mineUrl)
        } else {
            self.defaultNavbarConfiguration(withTitle: "Lists")
            let failedView = FailedRegistryView.instantiateFromNib()
            self.tableView.addSubview(failedView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func mineSelected(_ notification: NSNotification) {
        self.lists = []
        self.isLoading = true
        IntermineAPIClient.cancelListsRequest()
        if let mineName = notification.userInfo?["mineName"] as? String {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                self.configureNavBar(mine: mine, shouldShowMenuButton: true)
                if let mineUrl = mine.url {
                    self.mineUrl = mineUrl
                    self.fetchLists(mineUrl: mineUrl)
                }
            }
        }
    }
    
    private func fetchLists(mineUrl: String) {
        self.isLoading = true
        IntermineAPIClient.fetchLists(mineUrl: mineUrl, completion: { (lists, error) in
            guard let lists = lists else {
                if let error = error {
                    self.alert(message: NetworkErrorHandler.getErrorMessage(errorType: error))
                }
                return
            }
            // Sort list objects by "authorized"
            self.lists = lists.sorted { $0.getAuthd() && !$1.getAuthd() }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lists = self.lists else {
            return 0
        }
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        if let lists = self.lists, lists.count > 0 {
            cell.list = lists[indexPath.row]
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
