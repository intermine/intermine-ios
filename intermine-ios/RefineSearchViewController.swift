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
    @IBOutlet weak var refineSearchButton: BaseButton?
    
    private var mines: [MineRepresentation] = [MineRepresentation(name: String.localize("Search.Refine.NoSelection"), count: nil)]//[String] = [String.localize("Search.Refine.NoSelection")]
    
    private struct MineRepresentation {
        let name: String
        let count: Int?
        
        init(name: String, count: Int?) {
            self.name = name
            self.count = count
        }
    }
    
    private var mineCounts: [Int] = []
    
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

    private var selectedMine: MineRepresentation? {
        didSet {
            if let selectedMine = self.selectedMine {
                self.categories = self.getCategoriesForMine(mineName: selectedMine.name)
                if let catsTable = self.categoriesTable {
                    if selectedMine.name == String.localize("Search.Refine.NoSelection") {
                        BaseView.animateView(view: catsTable, animateIn: false)
                        refineSearchButton?.isEnabled = false
                    } else {
                        if let count = selectedMine.count, count > 0 {
                            BaseView.animateView(view: catsTable, animateIn: true)
                        } else {
                            BaseView.animateView(view: catsTable, animateIn: false)
                        }
                    }
                }
            }
        }
    }
    
    private var facets: [FacetList]? {
        didSet {
            self.mines = self.createMines()
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
        
        //TODO: - refine search button should be grayed out until some selection is performed
        refineSearchButton?.setTitle(String.localize("Search.Refine.CTA"), for: .normal)
        refineSearchButton?.isEnabled = false
        
        minesPicker?.delegate = self
        minesPicker?.dataSource = self
        categoriesTable?.delegate = self
        categoriesTable?.dataSource = self
        minesPicker?.selectRow(self.getInitialSelectedRow(), inComponent: 0, animated: false)
        self.selectedMine = self.getInitialSelectedMine()
        self.placeholderImageView?.image = Icons.placeholder
    }
    
    // MARK: Actions
    
    @IBAction func refineSearchButtonTapped(_ sender: Any) {
        // Go to prev vc with reload
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Private methods
    
    private func createMines() -> [MineRepresentation] {
        guard let facets = self.facets else {
            return self.mines
        }
        
        var mines: [MineRepresentation] = self.mines
        
        for facet in facets {
            if let name = facet.getMine() {
                let count = self.getTotalCountForMine(mineName: name)
                let mine = MineRepresentation(name: name, count: count)
                
                // test if mines array already has mine with this name
                if !(mines.contains(where: { rep in rep.name == name })) {
                    mines.append(mine)
                }
            }
        }
        
        // Padding with mines containing 0 search results
        if let registry = CacheDataStore.sharedCacheDataStore.allRegistry() {
            for mine in registry {
                if let name = mine.name {
                    let count = self.getTotalCountForMine(mineName: name)
                    let mine = MineRepresentation(name: name, count: count)
                    
                    // test if mines array already has mine with this name
                    if !(mines.contains(where: { rep in rep.name == name })) {
                        mines.append(mine)
                    }
                }
            }
        }
        
        return mines
    }

    
    private func changeStateRefineSearchButton(enabled: Bool) {
        refineSearchButton?.isEnabled = enabled
    }
    
    private func getMinesCount() -> Int {
        return mines.count
    }
    
    private func getInitialSelectedRow() -> Int {
        return 1
    }
    
    private func getInitialSelectedMine() -> MineRepresentation? {
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
    
    private func getTotalCountForMine(mineName: String) -> Int {
        if let facetList = self.getFacetListByName(mineName: mineName) {
            return facetList.getTotalFacetCount()
        }
        return 0
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
        if let mineCount = mines[row].count {
            return mines[row].name + " (\(mineCount))"
        } else {
            return mines[row].name
        }
    }
    
    // MARK: Picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMine = self.mines[row]
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
                let selectedFacet = SelectedFacet(withMineName: selectedMine.name, facetName: facetName, count: facetCount)
                refineSearchButton?.isEnabled = true
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
