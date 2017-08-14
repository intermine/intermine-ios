//
//  ResultsTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/11/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class TemplatesViewController: ResultsTableViewController {
    
    var countLoadedIncreased: Bool = false
    
    private var templates: [Template]? {
        didSet {
            if let templates = self.templates {
                self.data = templates
            }
        }
    }
    
    override var mineUrl: String? {
        willSet(newValue) {
            if newValue != self.mineUrl {
                AppManager.sharedManager.templatesLoadedWithNewMine = true
            }
        }
    }

    override func dataLoading(mineUrl: String, completion: @escaping ([Any]?, NetworkErrorType?) -> ()) {
        IntermineAPIClient.fetchTemplates(mineUrl: mineUrl) { (templatesList, error) in
            super.templatesLoaded = true
            guard let list = templatesList else {
                if let error = error {
                    if let errorMessage = NetworkErrorHandler.getErrorMessage(errorType: error) {
                        self.alert(message: errorMessage)
                    }
                }
                return
            }
            let templates = list.getTemplates()?.sorted { $0.getAuthd() && !$1.getAuthd() }
            self.templates = templates
            completion(templates, error)
        }
    }
    
    override func filterData(searchText: String) -> [Any] {
        var result: [Template] = []
        if let templates = self.templates {
            for template in templates {
                if let title = template.getTitle() {
                    if title.range(of: searchText) != nil {
                        result.append(template)
                    }
                }
            }
        }
        return result
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TemplateTableViewCell.identifier, for: indexPath) as! TemplateTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.template = filtered?[indexPath.row] as? Template
        } else {
            if let templates = self.templates, templates.count > 0 {
                cell.template = templates[indexPath.row]
            }
        }
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let template = self.templates?[indexPath.row],
            let templateDetail = TemplateDetailTableViewController.templateDetailTableViewController(withTemplate: template) {
            self.navigationController?.pushViewController(templateDetail, animated: true)
        }
    }

}
