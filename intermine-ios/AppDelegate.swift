//
//  AppDelegate.swift
//  intermine-ios
//
//  Created by Nadia on 4/1/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shouldPresentLaunchScreen = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        CacheDataStore.sharedCacheDataStore.updateRegistryIfNeeded { (mines, error) in
            AppManager.sharedManager.hideLaunchScreen()
            AppManager.sharedManager.showTutorialView()
            if let mines = mines {
                CacheDataStore.sharedCacheDataStore.updateRegistryModelsIfNeeded(mines: mines)
            }
        }
        
        AppManager.sharedManager.retrieveSelectedMine()
        
        BITHockeyManager.shared().configure(withIdentifier: "978f62a7b13a4d5d8d809daeb71e2c12")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CacheDataStore.sharedCacheDataStore.save()
        shouldPresentLaunchScreen = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if shouldPresentLaunchScreen {
            shouldPresentLaunchScreen = false
            AppManager.sharedManager.presentLaunchScreen(rootViewController: self.window?.rootViewController)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CacheDataStore.sharedCacheDataStore.save()
    }


}

