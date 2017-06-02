//
//  ViewController.swift
//  intermine-ios
//
//  Created by Nadia on 4/1/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class MainTabController: UITabBarController {

    @IBOutlet weak var bar: UITabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
    }

    // MARK: Private methods
    
    private func setupTabBar() {
        
        guard let items = bar?.items else {
            return
        }
        let icons = [Icons.search, Icons.templates, Icons.lists, Icons.bookmark, Icons.login]
        
        let titles = [String.localize("Tabs.Search"),
                      String.localize("Tabs.Templates"),
                      String.localize("Tabs.Lists"),
                      String.localize("Tabs.Favorites"),
                      String.localize("Tabs.Login")]
        
        for i in 0..<items.count {
            items[i].image = icons[i]
            items[i].title = titles[i]
        }
    }

}

