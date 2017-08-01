//
//  FavoritesViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import StoreKit

class FavoritesViewController: BaseViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    private var failedView: FailedRegistryView?
    
    private var savedSearches: [FavoriteSearchResult]? {
        didSet {
            if let savedSearches = self.savedSearches, savedSearches.count > 0 {
                self.tableView?.reloadData()
                if let failedView = self.failedView {
                    failedView.removeFromSuperview()
                    self.failedView = nil
                }
            } else {
                let failedView = FailedRegistryView.instantiateFromNib()
                failedView.messageText = String.localize("Favorites.NothingFound")
                self.tableView?.addSubview(failedView)
                self.failedView = failedView
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.setNavBarTitle(title: String.localize("Favorites.Title"))
        super.showMenuButton()
        tableView?.dataSource = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 140
        tableView?.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateSavedSearches()
    }
    
    // MARK: Private methods
    
    private func updateSavedSearches() {
        self.savedSearches = CacheDataStore.sharedCacheDataStore.getSavedSearchResults()
        if let savedSearches = self.savedSearches, savedSearches.count >= 5 {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searches = self.savedSearches {
            return searches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedCell.identifier, for: indexPath) as! FetchedCell
        if let searches = self.savedSearches {
            let search = searches[indexPath.row]
            cell.representedData = search.viewableRepresentation()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let savedSearches = self.savedSearches else {
                return
            }

            let removingSearch = savedSearches[indexPath.row]
            if let id = removingSearch.id {
                CacheDataStore.sharedCacheDataStore.unsaveSearchResult(withId: id)
            }
            
            self.savedSearches?.remove(at: indexPath.row)
        }
    }
    
}
