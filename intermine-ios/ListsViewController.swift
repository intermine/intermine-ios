//
//  ListsViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class ListsViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        controllerType = .Lists
    }
    
    // MARK: Mines table view delegate
    
    override func minesTableView(tableView: MinesTableView, didDetectUrlSelection: String?) {
        // TODO: To implement
    }


}
