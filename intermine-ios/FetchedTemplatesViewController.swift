//
//  FetchedTemplatesViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class FetchedTemplatesViewController: LoadingTableViewController, UISearchResultsUpdating, FetchedTemplatesHeaderCellDelegate {

    var params: [String: String]?
    var summaryCell: FetchedTemplatesHeaderCell?
    let searchController = UISearchController(searchResultsController: nil)

    private var templatesCount: Int? {
        didSet {
            if self.templatesCount == 0 {
                self.nothingFound = true
            } else {
                self.summaryCell?.templatesCount = self.templatesCount
                self.tableView.reloadData()
            }
        }
    }
    
    private var currentOffset: Int = 0
    
    var filteredTemplates: [[String:String]] = []

    var templates: [[String:String]] = [] {
        didSet {
            if self.templates.count > 0 {
                self.tableView.reloadData()
                self.showingResult = true
            } else {
                self.nothingFound = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideMenuButton = true
        self.loadTemplateResultsWithOffset(offset: self.currentOffset)
        
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 60

        if let mineUrl = self.mineUrl, let params = self.params {
            IntermineAPIClient.getTemplateResultsCount(mineUrl: mineUrl, queryParams: params, completion: { (res, error) in
                if let countString = res, let count = Int(countString.trim()) {
                    self.templatesCount = count
                }
            })
        }
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
    }
    
    // MARK: Load from storyboard
    
    class func fetchedTemplatesViewController(withMineUrl: String, params: [String: String]) -> FetchedTemplatesViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FetchedTemplatesVC") as? FetchedTemplatesViewController
        vc?.mineUrl = withMineUrl
        vc?.params = params
        return vc
    }
    
    // MARK: Private methods
    
    private func templateParams() -> String? {
        guard let params = self.params else {
            return nil
        }
        var searchValues: [String] = []
        let keys = params.keys
        for key in keys {
            if key.hasPrefix("value") {
                if let value = params[key] {
                    searchValues.append(value)
                }
            }
        }
        return searchValues.joined(separator: ", ")
    }
    
    private func loadTemplateResultsWithOffset(offset: Int) {
        if let mineUrl = self.mineUrl, let params = self.params {
            var correctedParams = params
            correctedParams["start"] = "\(offset)"
            self.isLoading = true
            IntermineAPIClient.fetchTemplateResults(mineUrl: mineUrl, queryParams: correctedParams, completion: { (res, error) in
                self.processDataResult(res: res, data: &self.templates)
                if self.currentOffset == 0 {
                    // FIXME: 
                }
                if let error = error {
                    if let errorMessage = NetworkErrorHandler.getErrorMessage(errorType: error) {
                        self.alert(message: errorMessage)
                    }
                }
            })
        }
    }
    
    private func makeUrlStringFromParams() -> String? {
        //name=Feature_overlapping&value1=Pentose+phosphate
        guard let params = self.params else {
            return nil
        }
        print(params)
        let serviceParams = ["format", "start", "size"]
        var url = ""
        for (key, value) in params {
            if !serviceParams.contains(key) {
                if url.characters.count == 0 {
                    url = "?" + key + "=" + value
                } else {
                    url = url + "&" + key + "=" + value
                }
            }
        }
        return url
    }
    
    private func filterTemplatesForSearchText(searchText: String?) {
        guard let searchText = searchText else {
            return
        }
        self.filteredTemplates = []
        for template in self.templates {
            let itemExists =  Array(template.values).contains(where: {
                $0.range(of: searchText, options: .caseInsensitive) != nil
            })
            if itemExists == true {
                self.filteredTemplates.append(template)
            }
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredTemplates.count
        } else {
            return self.templates.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedCell.identifier, for: indexPath) as! FetchedCell
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.representedData = filteredTemplates[indexPath.row]
        } else {
            cell.representedData = templates[indexPath.row]
        }
        return cell
    }
    
    // MARK: Header and footer
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedTemplatesHeaderCell.identifier) as! FetchedTemplatesHeaderCell
        cell.templatesCount = self.templatesCount
        cell.params = self.templateParams()
        cell.delegate = self
        self.summaryCell = cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: Fetched templates header cell delegate
    
    func fetchTemplatesHeaderCellDidTapDetailsButton(cell: FetchedTemplatesHeaderCell) {
        // show web w/template detail
        if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: AppManager.sharedManager.selectedMine), let mineURL = mine.url, let urlParams = makeUrlStringFromParams() {
            let url = mineURL + Endpoints.templateReport + urlParams + Endpoints.templateReportPostfix
            if let webVC = WebViewController.webViewController(withUrl: url) {
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    
    // MARK: Scroll view delegate
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 10.0) {
            if let templatesCount = self.templatesCount, templatesCount > General.pageSize, self.currentOffset + General.pageSize < templatesCount {
                self.currentOffset += General.pageSize
                self.loadTemplateResultsWithOffset(offset: self.currentOffset)
            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterTemplatesForSearchText(searchText: searchController.searchBar.text)
    }

}
