//
//  SearchRefineViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/20/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var checkImageView: UIImageView?
    static let identifier = "CategoryCell"
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var countLabel: UILabel?
    
    var index: Int = 0
    
    var formattedFacet: FormattedFacet? {
        didSet {
            titleLabel?.text = formattedFacet?.getTitle()
            countLabel?.text = formattedFacet?.getCount()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView?.image = Icons.check
    }
    
    func hideCheck() {
        checkImageView?.isHidden = true
    }
    
    func showCheck() {
        checkImageView?.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hideCheck()
    }
}

protocol RefineSearchViewControllerDelegate: class {
    func refineSearchViewController(controller: RefineSearchViewController, didSelectFacet: SelectedFacet)
}

class RefineSearchViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var placeholderImageView: UIImageView?
    
    private var mines: [String] = [String.localize("Search.Refine.NoSelection")]
    var allCells = Set<CategoryCell>()
    
    private var categories: [FormattedFacet]? {
        didSet {
            if let catsTable = self.categoriesTable {
                UIView.transition(with: catsTable, duration: General.viewAnimationSpeed, options: .transitionCrossDissolve, animations: {
                    self.categoriesTable?.reloadData()
                })
            }
        }
    }
    
    weak var delegate: RefineSearchViewControllerDelegate?

    private var selectedMine: String? {
        didSet {
            if let selectedMine = self.selectedMine {
                self.categories = self.getCategoriesForMine(mineName: selectedMine)
                if let catsTable = self.categoriesTable {
                    if selectedMine == String.localize("Search.Refine.NoSelection") {
                        BaseView.animateView(view: catsTable, animateIn: false)
                    } else {
                        BaseView.animateView(view: catsTable, animateIn: true)
                    }
                }
            }
        }
    }
    
    private var facets: [FacetList]? {
        didSet {
            self.mines = self.listMineNames()
        }
    }
    
    @IBOutlet weak var minesLabel: UILabel?
    @IBOutlet weak var categoriesLabel: UILabel?
    
    @IBOutlet weak var minesPicker: UIPickerView?
    @IBOutlet weak var categoriesTable: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        minesLabel?.text = String.localize("Search.Refine.SelectMine")
        categoriesLabel?.text = String.localize("Search.Refine.SelectCategory")
        minesPicker?.delegate = self
        minesPicker?.dataSource = self
        categoriesTable?.delegate = self
        categoriesTable?.dataSource = self
        minesPicker?.selectRow(self.getInitialSelectedRow(), inComponent: 0, animated: false)
        self.selectedMine = self.getInitialSelectedMine()
        self.placeholderImageView?.image = Icons.placeholder
    }
    
    // MARK: Private methods
    
    private func listMineNames() -> [String] {
        guard let facets = self.facets else {
            return self.mines
        }
        
        var mineNames: [String] = self.mines
        for facet in facets {
            if let name = facet.getMine() {
                if !(mineNames.contains(name)) {
                    mineNames.append(name)
                }
            }
        }
        return mineNames
    }
    
    private func getMinesCount() -> Int {
        return mines.count
    }
    
    private func getInitialSelectedRow() -> Int {
        return self.getMinesCount()/2
    }
    
    private func getInitialSelectedMine() -> String? {
        let index = self.getInitialSelectedRow()
        return self.mines[index]
    }
    
    private func getFacetListByName(mineName: String) -> FacetList? {
        guard let facets = self.facets else {
            return nil
        }
        for facet in facets {
            if facet.getMine() == mineName {
                return facet
            }
        }
        return nil
    }
    
    private func getCategoriesForMine(mineName: String) -> [FormattedFacet]? {
        // FacetList has mineName and categoryFacet as SearchFacet object
        // SearchFacet object has instance method getFormattedContents() -> [FormattedFacet]
        
        if let facetList = self.getFacetListByName(mineName: mineName) {
            return facetList.getFormattedFacetsList()
        }
        return nil
    }
    
    private func getCategoriesCount() -> Int {
        if let categories = self.categories {
            return categories.count
        }
        return 0
    }
    
    // MARK: Load from storyboard
    
    class func refineSearchViewController(withFacets: [FacetList]?) -> RefineSearchViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RefineSearchVC") as? RefineSearchViewController
        vc?.facets = withFacets
        return vc
    }
    
    // MARK: Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.getMinesCount()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mines[row]
    }
    
    // MARK: Picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMine = self.mines[row]
    }
    
    // MARK: - Table view data source
    
    // TODO: this needs to be in sync w/mine selection from picker
    // when certain mine is selected in picker -->
    // table view shows categories for this mine
    // when different mine is selected -->
    // table view reloads
    
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
        }
        cell.index = indexPath.row
        if !allCells.contains(cell) { allCells.insert(cell) }
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let categories = self.categories, let selectedMine = self.selectedMine {
            let category = categories[indexPath.row]
            if let facetName = category.getTitle(), let facetCount = category.getCount() {
                let selectedFacet = SelectedFacet(withMineName: selectedMine, facetName: facetName, count: facetCount)
                self.delegate?.refineSearchViewController(controller: self, didSelectFacet: selectedFacet)
            }
        }
        for cell in allCells {
            if cell.index != indexPath.row {
                cell.hideCheck()
            } else {
                cell.showCheck()
            }
        }
    }

    
}
