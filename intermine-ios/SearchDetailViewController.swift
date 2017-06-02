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

class SearchDetailViewController: BaseViewController, UITableViewDataSource {
    
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
        let infoButton = UIBarButtonItem(image: Icons.info,  style: .plain, target: self, action: #selector(SearchDetailViewController.didTapInfoButton))
        let favButton = UIBarButtonItem(image: Icons.star,  style: .plain, target: self, action: #selector(SearchDetailViewController.didTapFavButton))
        navigationItem.rightBarButtonItems = [infoButton, favButton]
    }
    
    func didTapInfoButton() {
        if let data = self.data, let webVC = WebViewController.webViewController(withSearchResult: data) {
            AppManager.sharedManager.shouldBreakLoading = true
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
    
    func didTapFavButton() {
        if let data = self.data {
            CacheDataStore.sharedCacheDataStore.saveSearchResult(searchResult: data)
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

}
