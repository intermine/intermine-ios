//
//  SearchViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    private var scopes: [String] = [String.localize("Search.Refine.AllMines"), AppManager.sharedManager.selectedMine]
    
    private var selectedMine: String = "" {
        didSet {
            scopes.remove(at: 1)
            scopes.append(selectedMine)
            self.searchBar?.scopeButtonTitles = scopes
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setNavBarTitle(title: String.localize("Search.All"))
        self.descriptionLabel?.text = String.localize("Search.AppDescription")
        self.searchBar?.placeholder = String.localize("Search.Placeholder")
        self.searchBar?.delegate = self
        
        self.searchBar?.showsScopeBar = true
        self.searchBar?.scopeButtonTitles = scopes
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.showMenuButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.mineSelected(_:)), name: NSNotification.Name(rawValue: Notifications.mineSelected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideTutorial(_:)), name: NSNotification.Name(rawValue: Notifications.tutorialFinished), object: nil)
        
        self.selectedMine = AppManager.sharedManager.selectedMine
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func mineSelected(_ notification: NSNotification) {
        if let mineName = notification.userInfo?["mineName"] as? String {
            self.selectedMine = mineName
        }
    }
    
    func hideTutorial(_ notification: NSNotification) {
        AppManager.sharedManager.removeTutorialView()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        let params: [String: String] = self.formParams(query: searchBar.text)
        
        var mineToSearch: String? = nil
        if let selectedIndex = self.searchBar?.selectedScopeButtonIndex {
            switch selectedIndex {
            case 0:
                //all mines selected, don't pass mine to next vc
                break
            default:
                mineToSearch = scopes[selectedIndex]
            }
        }
        
        if let fetchedSearchesVC = FetchedSearchesViewController.fetchedSearchesViewController(withParams: params, forMine: mineToSearch) {
            self.navigationController?.pushViewController(fetchedSearchesVC, animated: true)
        }
    }
    
    // MARK: Private methods

    private func formParams(query: String?) -> [String: String] {
        var params: [String: String] = ["format": "json", "start": "0", "size": "\(General.searchSize)"]
        if let query = query {
            params["q"] = query
        } else {
            params["q"] = ""
        }
        return params
    }

}
