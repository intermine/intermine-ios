//
//  AllSearchesViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/17/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class FetchedSearchesViewController: LoadingTableViewController, UIGestureRecognizerDelegate, RefineSearchViewControllerDelegate {
    
    @IBOutlet weak var refineButton: UIButton?
    @IBOutlet weak var buttonView: UIView?
    @IBOutlet weak var categoryLabel: UILabel?
    @IBOutlet weak var mineLabel: UILabel?
    
    private var currentOffset: Int = 0
    private var params: [String: String]?
    private var facets: [FacetList]?
    
    private var lockData = false {
        didSet {
            if lockData == true {
                AppManager.sharedManager.shouldBreakLoading = true
            }
        }
    }
    
    private var selectedFacet: SelectedFacet? {
        didSet {
            if let selectedFacet = self.selectedFacet {
                categoryLabel?.text = selectedFacet.getFacetName()
                mineLabel?.text = selectedFacet.getMineName()
            }
        }
    }
    
    // TODO: Make thread save array
    // When loading refined search, self.data only written from refine search calls
    
    private var data: [SearchResult] = [] {
        didSet {
            self.tableView.reloadData()
            if data.count > 0 {
                self.hideNothingFoundView()
                self.buttonView?.isHidden = false
                self.stopSpinner()
            } else {
                if self.selectedFacet == nil {
                    self.showNothingFoundView()
                    self.buttonView?.isHidden = true
                }
            }
        }
    }
    
    // MARK: View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavbar()
        self.loadSearchResultsWithOffset(offset: self.currentOffset)
        refineButton?.setTitle(String.localize("Search.Refine"), for: .normal)
        buttonView?.isHidden = true
        mineLabel?.text = String.localize("Search.Refine.NoSelection")
        categoryLabel?.text = String.localize("Search.Refine.NoSelection")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppManager.sharedManager.shouldBreakLoading = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let query = self.params?["query"] {
            navigationItem.title = String.localizeWithArg("Search.Header", arg: query)
        }
    }
    
    // MARK: Load from storyboard
    
    class func fetchedSearchesViewController(withParams: [String: String]?) -> FetchedSearchesViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FetchedSearchVC") as? FetchedSearchesViewController
        vc?.params = withParams
        return vc
    }
    
    // MARK: Private methods
    
    private func configureNavbar() {
        self.navigationController?.navigationBar.barTintColor = Colors.palma
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
    }
    
    private func loadSearchResultsWithOffset(offset: Int) {
        self.params?["start"] = "\(offset)"
        if let params = self.params {
            IntermineAPIClient.makeSearchOverAllMines(params: params) { (searchResults, facetLists) in
                // Transform into [String: String] dict
                if let searchResults = searchResults {
                    for res in searchResults {
                        if !self.lockData {
                            self.data.append(res)
                            self.stopSpinner()
                        }
                    }
                }
                
                if let facets = facetLists {
                    // To later show facets on refine search VC
                    if !self.lockData {
                        self.facets = facets
                    }
                }
            }
        }
    }
    
    private func loadRefinedSearchWithOffset(offset: Int, selectedFacet: SelectedFacet) {
        self.params?["facet_Category"] = selectedFacet.getFacetName()
        self.params?["size"] = "\(General.pageSize)"
        self.params?["start"] = "\(offset)"

        if let mineName = selectedFacet.getMineName(), let params = self.params {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: mineName), let mineUrl = mine.url {
                IntermineAPIClient.makeSearchInMine(mineUrl: mineUrl, params: params, completion: { (searchRes, facetList) in
                    if let res = searchRes {
                        self.data.append(res)
                    }
                })
            }
        }
    }
    
    // MARK: Refine search controller delegate
    
    func refineSearchViewController(controller: RefineSearchViewController, didSelectFacet: SelectedFacet) {
        // reload table view with new data
        self.selectedFacet = didSelectFacet
        self.data = []
        self.lockData = true
        self.startSpinner()
        //IntermineAPIClient.cancelAllRequests()
        self.loadRefinedSearchWithOffset(offset: self.currentOffset, selectedFacet: didSelectFacet)
    }
    
    // MARK: Action
    
    @IBAction func refineSearchTapped(_ sender: Any) {
        if let refineVC = RefineSearchViewController.refineSearchViewController(withFacets: self.facets) {
            refineVC.delegate = self
            self.navigationController?.pushViewController(refineVC, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedCell.identifier, for: indexPath) as! FetchedCell
        cell.data = self.data[indexPath.row]
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.data[indexPath.row]
        if let searchDetailVC = SearchDetailViewController.searchDetailViewController(withData: data) {
            self.navigationController?.pushViewController(searchDetailVC, animated: true)
        }
    }
    
    // MARK: Scroll view delegate
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 10.0) {
            if let selectedFacet = self.selectedFacet, let count = selectedFacet.getCount() {
                if count > General.pageSize, self.currentOffset + General.pageSize < count {
                    self.currentOffset += General.pageSize
                    self.loadRefinedSearchWithOffset(offset: self.currentOffset, selectedFacet: selectedFacet)
                }
            }
        }
    }

}
