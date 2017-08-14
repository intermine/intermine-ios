//
//  AppManager.swift
//  intermine-ios
//
//  Created by Nadia on 5/24/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import Foundation
import UIKit


class AppManager {
    
    private var launchVC: UIViewController?
    private var tutorialView: TutorialView?
    private var debugTutorial = false
    
    var mineChanged: Bool = false
    var listsLoadedWithNewMine: Bool = false
    var templatesLoadedWithNewMine: Bool = false
    
    var selectedMine: String = General.defaultMine {
        willSet (newValue) {
            if newValue != self.selectedMine && self.selectedMine != General.defaultMine {
                mineChanged = true
            }
        }
        didSet {
            var info: [String: Any] = [:]
            info = ["mineName": self.selectedMine]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.mineSelected), object: self, userInfo: info)
        }
    }
    
    var cachedCategory: String? = nil
    var cachedMineIndex: Int? = nil
    
    var shouldBreakLoading = false {
        didSet {
            if self.shouldBreakLoading {
                IntermineAPIClient.cancelAllRequests()
            }
        }
    }
    
    var token: String? = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.token)
    
    // MARK: Shared Instance
    
    static let sharedManager : AppManager = {
        let instance = AppManager()
        return instance
    }()
    
    // MARK: Public methods

    func selectMine(mineName: String) {
        self.selectedMine = mineName
    }
    
    func retrieveSelectedMine() {
        if let selectedMine = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.selectedMine) {
            self.selectMine(mineName: selectedMine)
        } else {
            self.selectMine(mineName: General.defaultMine)
        }
    }
    
    func updateToken() {
        self.token = DefaultsManager.fetchFromDefaults(key: DefaultsKeys.token)
    }
    
    func presentLaunchScreen(rootViewController: UIViewController?) {
        if let vc = LaunchViewController.launchViewController() {
            self.launchVC = vc
            vc.modalTransitionStyle = .crossDissolve
            rootViewController?.present(vc, animated: false, completion: nil)
        }
    }
    
    private func shouldShowTutorial() -> Bool {
        if debugTutorial {
            return true
        }
        return !DefaultsManager.keyExists(key: DefaultsKeys.tutorialShown)
    }
    
    func showTutorialView() {
        if shouldShowTutorial() {
            let tutorialView = TutorialView.instantiateFromNib()
            if let window = UIApplication.shared.keyWindow {
                tutorialView.resizeView(toY: 0, toWidth: window.frame.size.width, toHeight: window.frame.size.height)
                tutorialView.tag = 100
                window.addSubview(tutorialView)
            }
            self.tutorialView = tutorialView
            DefaultsManager.storeInDefaults(key: DefaultsKeys.tutorialShown, value: "yes")
        }
    }
    
    func removeTutorialView() {
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.2, animations: { 
                self.tutorialView?.alpha = 0
            }, completion: { (done) in
                window.viewWithTag(100)?.removeFromSuperview()
                self.tutorialView = nil
            })
        }
    }
    
    func hideLaunchScreen() {
        // show when notification is received
        if let launchVC = self.launchVC {
            launchVC.dismiss(animated: true, completion: nil)
        }
    }
}

