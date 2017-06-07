//
//  LoadingTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingTableViewController: UITableViewController {
    
    private var spinner: NVActivityIndicatorView?
    private var nothingFoundView: BaseView? = nil
    let interactor = Interactor()
    
    var mineUrl: String? {
        didSet {
            if let url = self.mineUrl, let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: url) {
                self.configureNavBar(mine: mine)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nothingFoundView = TableCoverView.instantiateFromNib()
        if let nothingFoundView = self.nothingFoundView {
            nothingFoundView.frame = self.tableView.frame
            self.tableView.addSubview(nothingFoundView)
            nothingFoundView.isHidden = true
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        self.spinner = NVActivityIndicatorView(frame: self.indicatorFrame(), type: .ballSpinFadeLoader, color: Colors.apple, padding: self.indicatorPadding())
        if let spinner = self.spinner {
            self.view.addSubview(spinner)
            self.view.bringSubview(toFront: spinner)
        }
        self.startSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.mineSelected(_:)), name: NSNotification.Name(rawValue: Notifications.mineSelected), object: nil)
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func mineSelected(_ notification: NSNotification) {
        // To override
        print("super")
    }
    

    func stopSpinner() {
        self.spinner?.stopAnimating()
    }
    
    func startSpinner() {
        self.spinner?.startAnimating()
    }
    
    func showNothingFoundView() {
        self.nothingFoundView?.isHidden = false
    }
    
    func hideNothingFoundView() {
        self.nothingFoundView?.isHidden = true
    }
    
    private func indicatorFrame() -> CGRect {
        if let navbarHeight = self.navigationController?.navigationBar.frame.size.height, let tabbarHeight = self.tabBarController?.tabBar.frame.size.height {
            let viewHeight = BaseView.viewHeight(view: self.view)
            let indicatorHeight = viewHeight - (tabbarHeight + navbarHeight)
            let indicatorWidth = BaseView.viewWidth(view: self.view)
            return CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorHeight)
        } else {
            return self.view.frame
        }
    }
    
    func configureNavBar(mine: Mine) {
        self.navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: mine.theme)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
        self.navigationController?.navigationBar.topItem?.title = mine.name
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(Icons.menu, for: .normal)
        button.addTarget(self, action: #selector(LoadingTableViewController.menuButtonPressed), for: .touchUpInside)
        button.tintColor = Colors.white
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
                    let title = comps[1]
                    processedArray.append(title)
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

