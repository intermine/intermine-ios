//
//  BaseViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let interactor = Interactor()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavBar()
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = Colors.palma
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
    }
    
    func showMenuButton() {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(Icons.menu, for: .normal)
        button.addTarget(self, action: #selector(BaseViewController.menuButtonPressed), for: .touchUpInside)
        button.tintColor = Colors.white
        let barButton = UIBarButtonItem()
        barButton.customView = button
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func setNavBarTitle(title: String) {
        self.navigationController?.navigationBar.topItem?.title = title
    }
    
    func menuButtonPressed() {
        // present VC modaly
        if let menuVC = MenuViewController.menuViewController() {
            menuVC.transitioningDelegate = self
            menuVC.interactor = interactor
            present(menuVC, animated: true, completion: nil)
        }
    }
    
    func indicatorFrame() -> CGRect {
        if let navbarHeight = self.navigationController?.navigationBar.frame.size.height, let tabbarHeight = self.tabBarController?.tabBar.frame.size.height {
            let viewHeight = BaseView.viewHeight(view: self.view)
            let indicatorHeight = viewHeight - (tabbarHeight + navbarHeight)
            let indicatorWidth = BaseView.viewWidth(view: self.view)
            return CGRect(x: 0, y: 0, width: indicatorWidth, height: indicatorHeight)
        } else {
            return self.view.frame
        }
    }
    
    func indicatorPadding() -> CGFloat {
        return BaseView.viewWidth(view: self.view) / 2.5
    }
    
    func defaultNavbarConfiguration(withTitle: String) {
        self.navigationController?.navigationBar.barTintColor = Colors.palma
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
        self.navigationController?.navigationBar.topItem?.title = withTitle
        //self.navigationController?.navigationBar.topItem?.titleView = UIImageView(image: Icons.titleBarPlaceholder)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(Icons.titleBarPlaceholder, for: .normal)
        button.addTarget(self, action: #selector(LoadingTableViewController.menuButtonPressed), for: .touchUpInside)
        button.tintColor = Colors.white
        let barButton = UIBarButtonItem()
        barButton.customView = button
        self.navigationItem.leftBarButtonItem = barButton
    }
}


extension BaseViewController: UIViewControllerTransitioningDelegate {
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
