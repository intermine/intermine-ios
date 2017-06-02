//
//  LoginViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/8/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit


class LoginViewController: BaseViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var minePicker: UIPickerView?
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var loginButton: UIButton?
    
    private let itemsCount = CacheDataStore.sharedCacheDataStore.registrySize()
    private let registry = CacheDataStore.sharedCacheDataStore.getMineNames()
    
    private var selectedMine: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        usernameTextField?.returnKeyType = .go
        passwordTextField?.returnKeyType = .go
        loginButton?.setTitle(String.localize("Login.LoginButton"), for: .normal)
        usernameTextField?.delegate = self
        passwordTextField?.delegate = self
        minePicker?.delegate = self
        minePicker?.dataSource = self
        minePicker?.selectRow(self.getInitialSelectedRow(), inComponent: 0, animated: false)
        self.selectedMine = self.registry[self.getInitialSelectedRow()]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Private methods
    
    private func getInitialSelectedRow() -> Int {
        return itemsCount/2
    }
    
    private func login(username: String, password: String) {
        // do login sequence
    }
    
    // MARK: Actions
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.itemsCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return registry[row]
    }
    
    // MARK: Picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMine = registry[row]
    }
    
    // MARK: Keyboard events
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}
