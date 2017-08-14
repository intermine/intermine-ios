//
//  LoadingTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class LoadingTableViewController: UITableViewController {
    
    private var tableOverlay: TableCoverView? = nil
    let interactor = Interactor()
    
    var isLoading: Bool = false {
        didSet {
            showTableOverlay(isLoading: isLoading)
        }
    }
    
    var nothingFound: Bool = false {
        didSet {
            self.showTableOverlay(isLoading: !nothingFound)
        }
    }
    
    var showingResult: Bool = false {
        didSet {
            if showingResult == true {
                self.removeTableOverlay()
            }
        }
    }
    
    var hideMenuButton = false {
        didSet {
            if hideMenuButton {
                if let url = self.mineUrl, let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: url) {
                    self.configureNavBar(mine: mine, shouldShowMenuButton: false)
                }
            }
        }
    }
    
    var showInfoButton = false {
        didSet {
            if showInfoButton {
                let detailsButton = UIBarButtonItem(title: String.localize("General.Details"), style: .plain, target: self, action: #selector(LoadingTableViewController.didTapInfoButton))
                navigationItem.rightBarButtonItems = [detailsButton]
            }
        }
    }
    
    var mineUrl: String? {
        didSet {
            if let url = self.mineUrl, let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: url) {
                self.configureNavBar(mine: mine, shouldShowMenuButton: !self.hideMenuButton)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
    }
    
    func didTapInfoButton() {
        print("tapped")
    }
    
    func mineSelected(_ notification: NSNotification) {
        // To override
        print("super")
    }
    
    func showTableOverlay(isLoading: Bool) {
        if self.tableOverlay == nil {
            self.tableOverlay = TableCoverView.instantiateFromNib()
            if let tableOverlay = self.tableOverlay {
                tableOverlay.frame = self.tableView.frame
                self.tableView.addSubview(tableOverlay)
                tableOverlay.alpha = 0
                tableOverlay.isHidden = false
                if let navbarHeight = self.navigationController?.navigationBar.frame.size.height, let tabbarHeight = self.tabBarController?.tabBar.frame.size.height {
                    tableOverlay.upperOffset = navbarHeight + tabbarHeight
                }
            }
            
            self.tableOverlay?.alpha = 1
            if isLoading {
                self.tableOverlay?.showSpinner()
            } else {
                self.tableOverlay?.showLabel()
            }
            
        } else {
            if self.tableOverlay?.isDescendant(of: self.tableView) == true {
                // the view already in the stack, 
                // swap spinner to label or wise versa
                if !isLoading {
                    self.tableOverlay?.hideSpinner()
                    self.tableOverlay?.showLabel()
                } else {
                    self.tableOverlay?.hideLabel()
                    self.tableOverlay?.showSpinner()
                }
                self.tableOverlay?.frame = self.tableView.bounds
                self.tableOverlay?.alpha = 1
                self.tableOverlay?.isHidden = false
            } else {
                print("table overlay is not descendant")
            }
        }
    }
    
    func removeTableOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableOverlay?.alpha = 0
        }) { (done) in
            self.tableOverlay?.removeFromSuperview()
            self.tableOverlay = nil
        }
    }
    
    func configureNavBar(mine: Mine, shouldShowMenuButton: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: mine.theme)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
        self.navigationController?.navigationBar.topItem?.title = mine.name
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
        
        if shouldShowMenuButton {
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.setImage(Icons.whiteMenu, for: .normal)
            button.addTarget(self, action: #selector(LoadingTableViewController.menuButtonPressed), for: .touchUpInside)
            button.tintColor = Colors.white
            let barButton = UIBarButtonItem()
            barButton.customView = button
            self.navigationItem.leftBarButtonItem = barButton
        }
        
        if shouldShowMenuButton != true {
            if self.navigationItem.leftBarButtonItem != nil {
                self.navigationItem.leftBarButtonItem = nil
            }
        }

    }
    
    func defaultNavbarConfiguration(withTitle: String) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white//Colors.palma
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black//Colors.white
        self.navigationController?.navigationBar.topItem?.title = withTitle//UIImageView(image: Icons.titleBarPlaceholder)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]//Colors.white]
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(Icons.titleBarPlaceholder, for: .normal)
        button.addTarget(self, action: #selector(LoadingTableViewController.menuButtonPressed), for: .touchUpInside)
        button.tintColor = UIColor.black//Colors.white
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func menuButtonPressed() {
        if let menuVC = MenuViewController.menuViewController() {
            menuVC.transitioningDelegate = self
            menuVC.interactor = interactor
            present(menuVC, animated: true, completion: nil)
        }
    }
    
    func processHeaderArray(headerArray: NSArray) -> [String] {
        var processedArray: [String] = []
        for elem in headerArray {
            if let elem = elem as? String {
                let comps = elem.components(separatedBy: " > ")
                if comps.count > 1 {
                    let currentIndex = comps.count - 1
                    if processedArray.contains(comps[currentIndex]) {
                        processedArray.append(comps[currentIndex-1] + comps[currentIndex])
                    } else {
                        processedArray.append(comps[currentIndex])
                    }
                }
            }
        }
        return processedArray
    }
    
    func processDataResult(res: [String: AnyObject]?, data: inout [[String: String]]) {
        if let results = res?["results"] as? NSArray, let headers = res?["columnHeaders"] as? NSArray {
            let processedHeaders = self.processHeaderArray(headerArray: headers)
            for res in results {
                if let res = res as? [Any] {
                    var values: [String] = []
                    for r in res {
                        values.append("\(r)")
                    }
                    let dict = Dictionary(keys: processedHeaders, values: values)
                    data.append(dict)
                }
            }
        }
    }
    
    private func indicatorPadding() -> CGFloat {
        return BaseView.viewWidth(view: self.view) / 2.5
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // To override
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // To override
        return 0
    }
}

extension LoadingTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

