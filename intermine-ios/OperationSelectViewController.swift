//
//  OperationSelectTableViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/12/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol OperationSelectViewControllerDelegate: class {
    func operationSelectViewControllerDidTapClose(controller: OperationSelectViewController)
}


class OperationSelectViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var picker: UIPickerView?
    
    weak var delegate: OperationSelectViewControllerDelegate?
    
    private let operations = [Operations.equalsEquals, Operations.like, Operations.equals,
                              Operations.notEquals, Operations.notLike, Operations.notEqualsEquals,
                              Operations.doesNotContain, Operations.contains, Operations.moreOrEqual,
                              Operations.lessOrEqual, Operations.more, Operations.less]
    
    var cellIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton?.setTitle(String.localize("Templates.OperationSelect.Done"), for: .normal)
        self.picker?.delegate = self
        self.picker?.dataSource = self
    }
    
    // MARK: Load from storyboard
    
    class func operationSelectViewController(forCellIndex: Int?) -> OperationSelectViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OperationSelectVC") as? OperationSelectViewController
        vc?.cellIndex = forCellIndex
        return vc
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.delegate?.operationSelectViewControllerDidTapClose(controller: self)
    }
    
    // MARK: Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return operations.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return operations[row]
    }
    
    // MARK: Picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = operations[row]
        guard let index = self.cellIndex else {
            return
        }
        let info = ["op": selectedValue, "index": index] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.operationChanged), object: self, userInfo: info)
    }

}
