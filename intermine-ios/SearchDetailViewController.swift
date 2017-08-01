//
//  SearchDetailViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/25/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    
    static let identifier = "SearchCell"
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    
    var key: String? {
        didSet {
            titleLabel?.text = key
        }
    }
    
    var value: String? {
        didSet {
            detailLabel?.text = value
        }
    }
    
}

class SearchDetailViewController: BaseViewController, UITableViewDataSource, FavoriteButtonDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    private var keys: [String] = []
    
    private var data: SearchResult? {
        didSet {
            if let data = self.data {
                let viewableRepresentation = data.viewableRepresentation()
                self.keys = Array(viewableRepresentation.keys)
            }
        }
    }
    
    // MARK: Private methods
    
    private func addNavbarButtons() {
        let detailsButton = UIBarButtonItem(title: String.localize("General.Details"), style: .plain, target: self, action: #selector(LoadingTableViewController.didTapInfoButton))
        
        if let data = self.data {
            let favButton = FavoriteButton(isFavorite: data.isFavorited())
            favButton.delegate = self
            let favBarButton = UIBarButtonItem(customView: favButton)
            navigationItem.rightBarButtonItems = [detailsButton, favBarButton]
        }
    }
    
    func didTapInfoButton() {
        if let searchResult = self.data,
            let mineName = searchResult.getMineName(),
            let id = searchResult.getId() {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName) {
                if let mineUrl = mine.url {
                    var url = mineUrl + Endpoints.searchResultReport + "?id=\(id)"
                    if let pubmedId = searchResult.getPubmedId() {
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
    
    // MARK: Load from storyboard
    
    class func searchDetailViewController(withData: SearchResult) -> SearchDetailViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchDetailVC") as? SearchDetailViewController
        vc?.data = withData
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = self
        self.addNavbarButtons()
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        let key = self.keys[indexPath.row]
        cell.key = key
        cell.value = self.data?.viewableRepresentation()[key]
        return cell
    }
    
    // MARK: - FavoriteButtonDelegate
    
    func didTapFavoriteButton(favoriteButton: FavoriteButton) {
        guard let searchResult = self.data, let searchId = searchResult.getId() else {
            return
        }
        
        if searchResult.isFavorited() {
            CacheDataStore.sharedCacheDataStore.unsaveSearchResult(withId: searchId)
        } else {
            CacheDataStore.sharedCacheDataStore.saveSearchResult(searchResult: searchResult)
        }
    }

}
