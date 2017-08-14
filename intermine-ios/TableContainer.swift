//
//  TableContainer.swift
//  intermine-ios
//
//  Created by Nadia on 8/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol TableContainerDelegate: class {
    func tableContainer(tableContainer: TableContainer, didSelectCategory: FormattedFacet)
}

class TableContainer: BaseView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var placeholderImageView: UIImageView?
    @IBOutlet weak var nothingFoundView: UIView?
    @IBOutlet weak var categoriesTable: UITableView?
    @IBOutlet weak var categoriesLabel: UILabel?
    
    weak var delegate: TableContainerDelegate?
    
    var allCells = Set<CategoryCell>()
    
    private var colorString: String?
    
    func configureUI(colorString: String) {
        self.colorString = colorString
    }
    
    private var categories: [FormattedFacet]? {
        didSet {
            if let catsTable = self.categoriesTable {
                UIView.transition(with: catsTable, duration: General.viewAnimationSpeed, options: .transitionCrossDissolve, animations: {
                    self.categoriesTable?.reloadData()
                })
            }
        }
    }
    
    // MARK: UIView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoriesTable?.delegate = self
        categoriesTable?.dataSource = self
        placeholderImageView?.image = Icons.placeholder
        placeholderImageView?.isHidden = true
    }

    // MARK: Public

    func updateCategories(categories: [FormattedFacet]?) {
        self.categories = categories
        guard let catsTable = self.categoriesTable else {
            return
        }
        if let categories = self.categories, categories.count > 0 {
            placeholderImageView?.isHidden = true
            categoriesLabel?.text = String.localize("Search.Refine.SelectCategory")
            categoriesTable?.reloadData()
            BaseView.animateView(view: catsTable, animateIn: true)
        } else {
            categoriesLabel?.text = String.localize("Search.Refine.NoCategoriesLoaded")
            placeholderImageView?.isHidden = false
            BaseView.animateView(view: catsTable, animateIn: false)
        }
    }
    
    func indicatorPadding() -> CGFloat {
        if let nothingFoundView = self.nothingFoundView {
            return BaseView.viewWidth(view: nothingFoundView) / 3
        }
        return 0
    }
    
    func reloadCategories() {
        categoriesTable?.reloadData()
    }
    
    // MARK: Private
    
    private func getCategoriesCount() -> Int {
        if let categories = self.categories {
            return categories.count
        }
        return 0
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        if let categories = self.categories {
            let category = categories[indexPath.row]
            cell.formattedFacet = category
            if let cached = AppManager.sharedManager.cachedCategory, category.getTitle() == cached {
                cell.showCheck()
            }
        }
        cell.index = indexPath.row
        if !allCells.contains(cell) { allCells.insert(cell) }
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let categories = self.categories else {
            return
        }
        let category = categories[indexPath.row]
        self.delegate?.tableContainer(tableContainer: self, didSelectCategory: category)
        for cell in allCells {
            if cell.index != indexPath.row {
                cell.hideCheck()
            } else {
                cell.showCheck()
            }
        }
    }
    
    // MARK: Scroll view delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalIndicator = scrollView.subviews.last as? UIImageView
        verticalIndicator?.backgroundColor = UIColor.hexStringToUIColor(hex: self.colorString)
    }


}
