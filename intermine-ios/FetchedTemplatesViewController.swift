//
//  FetchedTemplatesViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class FetchedTemplatesViewController: LoadingTableViewController {
    
    var params: [String: String]?
    
    private var templatesCount: Int? {
        didSet {
            if self.templatesCount == 0 {
                self.showNothingFoundView()
            }
        }
    }
    
    private var currentOffset: Int = 0

    var templates: [[String:String]] = [] {
        didSet {
            if self.templates.count > 0 {
                self.tableView.reloadData()
                self.hideNothingFoundView()
            } else {
                self.showNothingFoundView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideMenuButton = true
        self.loadTemplateResultsWithOffset(offset: self.currentOffset)
        
        if let mineUrl = self.mineUrl, let params = self.params {
            IntermineAPIClient.getTemplateResultsCount(mineUrl: mineUrl, queryParams: params, completion: { (res) in
                if let countString = res, let count = Int(countString.trim()) {
                    self.templatesCount = count
                }
            })
        }
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
    
    private func loadTemplateResultsWithOffset(offset: Int) {
        if let mineUrl = self.mineUrl, let params = self.params {
            var correctedParams = params
            correctedParams["start"] = "\(offset)"
            IntermineAPIClient.fetchTemplateResults(mineUrl: mineUrl, queryParams: correctedParams, completion: { (res) in
                self.processDataResult(res: res, data: &self.templates)
                if self.currentOffset == 0 {
                    self.stopSpinner()
                } 
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.templates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FetchedCell.identifier, for: indexPath) as! FetchedCell
        cell.representedData = templates[indexPath.row]
        return cell
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

}
