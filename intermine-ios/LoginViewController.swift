//
//  LoginViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var coverView: UIView?
    @IBOutlet weak var loggedInLabel: UILabel?
    @IBOutlet weak var logoutButton: UIButton!
    
    private let itemsCount = CacheDataStore.sharedCacheDataStore.registrySize()
    private let registry = CacheDataStore.sharedCacheDataStore.getMineNames()
    
    private var mineUrl: String? {
        didSet {
            if let mineUrl = self.mineUrl {
                self.showLoggedinState(isLogged: DefaultsManager.keyExists(key: mineUrl))
            }
        }
    }
    
    private var isKeyboardShown = false
    private var initialViewY: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        usernameTextField?.returnKeyType = .go
        passwordTextField?.returnKeyType = .go
        loginButton?.setTitle(String.localize("Login.LoginButton"), for: .normal)
        logoutButton?.setTitle(String.localize("Login.LogoutButton"), for: .normal)
        usernameTextField?.delegate = self
        passwordTextField?.delegate = self
        initialViewY = self.view.frame.origin.y
        descriptionLabel?.text = String.localize("Login.CredsPrompt")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if let mineUrl = self.mineUrl {
            self.showLoggedinState(isLogged: DefaultsManager.keyExists(key: mineUrl))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func configureNavBar() {
        let selectedMine = AppManager.sharedManager.selectedMine
        if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: selectedMine) {
            
            self.mineUrl = mine.url
            
            self.navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: mine.theme)
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.tintColor = Colors.white
            self.navigationController?.navigationBar.topItem?.title = mine.name
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.white]
            
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.setImage(Icons.whiteMenu, for: .normal)
            button.addTarget(self, action: #selector(BaseViewController.menuButtonPressed), for: .touchUpInside)
            button.tintColor = Colors.white
            let barButton = UIBarButtonItem()
            barButton.customView = button
            
            self.navigationItem.leftBarButtonItem = barButton
            
            if let mineUrl = self.mineUrl, let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: mineUrl), let mineName = mine.name {
                loggedInLabel?.text = String.localizeWithArg("Login.Loggedin", arg: mineName)
            }
        } else {
            self.defaultNavbarConfiguration(withTitle: "Login")
            let failedView = FailedRegistryView.instantiateFromNib()
            self.view.addSubview(failedView)
        }
    }
   
    // MARK: Private methods
    
    private func showLoggedinState(isLogged: Bool) {
        if isLogged {
            // logged in, no need to show prompt
            self.coverView?.isHidden = false
        } else {
            // show login prompt
            self.coverView?.isHidden = true
        }
    }
    
    private func getInitialSelectedRow() -> Int {
        return itemsCount/2
    }
    
    private func login() {
        if let userName = self.usernameTextField?.text, let pwd = self.passwordTextField?.text, let mineUrl = self.mineUrl {
            if userName != "", pwd != "" {
                IntermineAPIClient.getToken(mineUrl: mineUrl, username: userName, password: pwd, completion: { (success) in
                    if success {
                        self.showLoggedinState(isLogged: true)
                        self.sendUpdatedMineNotification(mineUrl: mineUrl)
                    } else {
                        self.alert(message: String.localize("Login.AuthError"))
                    }
                })
            } else {
                self.alert(message: String.localize("Login.EmptyCreds"))
            }
        }
    }
    
    private func logout() {
        if let mineUrl = self.mineUrl {
            DefaultsManager.removeFromDefaults(key: mineUrl)
            self.showLoggedinState(isLogged: false)
            self.sendUpdatedMineNotification(mineUrl: mineUrl)
        }
    }
    
    private func sendUpdatedMineNotification(mineUrl: String) {
        if let mine = CacheDataStore.sharedCacheDataStore.findMineByUrl(url: mineUrl), let mineName = mine.name {
            var info: [String: Any] = [:]
            info = ["mineName": mineName]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.mineSelected), object: self, userInfo: info)
        }
    }
    
    // MARK: Actions
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.login()
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.logout()
    }
    
    // MARK: Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.login()
        return true
    }
    
    // MARK: Keyboard events
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if isKeyboardShown == false {
                guard let loginButton = self.loginButton else {
                    return
                }
                
                let loginButtonCoord = loginButton.frame.origin.y + loginButton.frame.size.height
                let heightDifference = self.view.frame.size.height - keyboardSize.height - loginButtonCoord
                if heightDifference < 0 {
                    self.view.frame.origin.y -= abs(heightDifference) + 10
                }

                isKeyboardShown = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShown == true {
            if let navbarHeight = self.navigationController?.navigationBar.frame.size.height {
                self.view.frame.origin.y = navbarHeight + 20
            }
            
            isKeyboardShown = false
        }
    }

}
