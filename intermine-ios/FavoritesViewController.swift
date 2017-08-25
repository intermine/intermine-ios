//
//  FavoritesViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import StoreKit

class FavoritesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
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
                failedView.frame = self.view.bounds
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
        tableView?.delegate = self
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 140
        tableView?.allowsMultipleSelectionDuringEditing = true
        let fetchedCellNib = UINib(nibName: "FetchedCell", bundle: nil)
        self.tableView?.register(fetchedCellNib, forCellReuseIdentifier: FetchedCell.identifier)
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
            cell.typeColor = TypeColorDefine.getBackgroundColor(categoryType: search.type)
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
                var info: [String: Any] = [:]
                info = ["id": id]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.unfavorited), object: self, userInfo: info)
            }
            
            self.savedSearches?.remove(at: indexPath.row)
        }
    }
    
    // Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searches = self.savedSearches {
            let search = searches[indexPath.row]
            if let mineName = search.mineName, let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName), let mineUrl = mine.url, let id = search.id {
                var url = mineUrl + Endpoints.searchResultReport + "?id=\(id)"
                if let pubmedId = search.getPubmedId() {
                    url = Endpoints.pubmed + pubmedId
                }
                if let webVC = WebViewController.webViewController(withUrl: url) {
                    AppManager.sharedManager.shouldBreakLoading = true
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            }
        }
    }
}
