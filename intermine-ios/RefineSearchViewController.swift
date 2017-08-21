//
//  SearchRefineViewController.swift
//  intermine-ios
//
//  Created by Nadia on 5/20/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

struct MineRepresentation {
    let name: String
    var count: Int?
    
    init(name: String, count: Int?) {
        self.name = name
        self.count = count
    }
}

protocol RefineSearchViewControllerDelegate: class {
    func refineSearchViewController(controller: RefineSearchViewController, didSelectFacet: SelectedFacet)
}

class RefineSearchViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource, HeaderViewDelegate, TableContainerDelegate {
    
    @IBOutlet weak var headerView: HeaderView?
    @IBOutlet weak var tableContainer: TableContainer?
    
    private let facetManager = FacetManager.shared
    private var mineToSearch: String?
    
    private var mines: [MineRepresentation] = [] {
        didSet {
            minesPicker?.reloadAllComponents()
        }
    }
    
    private var selectedThemeColor: UIColor?
    private var mineCounts: [Int] = []
    
    weak var delegate: RefineSearchViewControllerDelegate?
    private var spinner: NVActivityIndicatorView?

    private var selectedMine: MineRepresentation? {
        didSet {
            if let selectedMine = self.selectedMine {
                tableContainer?.updateCategories(categories: getCategoriesForMine(mineName: selectedMine.name))
                if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: selectedMine.name), let theme = mine.theme {
                    headerView?.configureUI(colorString: theme)
                }
            }
        }
    }

    private var facets: [FacetList]? {
        didSet {
            self.mines = self.createMines(showAllMines: mineToSearch == nil)
        }
    }
    
    @IBOutlet weak var minesLabel: UILabel?
    @IBOutlet weak var categoriesLabel: UILabel?
    @IBOutlet weak var minesPicker: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        minesLabel?.text = String.localize("Search.Refine.SelectMine")
        if self.mineToSearch != nil {
            minesLabel?.text = String.localize("Search.Refine.SelectedMine")
        }

        minesPicker?.delegate = self
        minesPicker?.dataSource = self
        headerView?.delegate = self
        tableContainer?.delegate = self
        
        if let selectedRow = self.getInitialSelectedRow() {
            minesPicker?.selectRow(selectedRow, inComponent: 0, animated: false)
        }
        
        if let mineToSearch = self.mineToSearch {
            headerView?.configureModeControl(withMode: RefineMode.One, searchableMine: mineToSearch)
        } else {
            headerView?.configureModeControl(withMode: RefineMode.All, searchableMine: nil)
        }

        self.selectedMine = self.getInitialSelectedMine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.facetsUpdated(_:)), name: NSNotification.Name(rawValue: Notifications.facetsUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.searchFailed(_:)), name: NSNotification.Name(rawValue: Notifications.searchFailed), object: nil)
        
        if let selectedMine = self.selectedMine {
            if let mine = CacheDataStore.sharedCacheDataStore.findMineByName(name: selectedMine.name), let theme = mine.theme {
                headerView?.configureUI(colorString: theme)
                tableContainer?.configureUI(colorString: theme)
            }
        }
    }
    
    func facetsUpdated(_ notification: NSNotification) {
        self.facets = FacetManager.shared.getFacets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func searchFailed(_ notification: NSNotification) {
        if let error = notification.userInfo?["errorType"] as? NetworkErrorType {
            if let errorMessage = NetworkErrorHandler.getErrorMessage(errorType: error) {
                self.alert(message: errorMessage)
            }
        }
    }
    
    // MARK: Private methods
    
    private func createMines(showAllMines: Bool) -> [MineRepresentation] {
        guard let facets = self.facets else {
            return self.mines
        }
        
        var mines: [MineRepresentation] = self.mines
        
        for facet in facets {
            if let name = facet.getMine() {
                let count = self.getTotalCountForMine(mineName: name)
                let updatedMine = MineRepresentation(name: name, count: count)
                
                for (i, mine) in mines.enumerated() {
                    if mine.name == updatedMine.name && mine.count != updatedMine.count {
                        mines.remove(at: i)
                    }
                }
                
                if !(mines.contains(where: { rep in rep.name == name && rep.count == count })) {
                    mines.append(updatedMine)
                }
            }
        }
        
        if showAllMines {
            // Padding with mines containing 0 search results
            if let registry = CacheDataStore.sharedCacheDataStore.allRegistry() {
                for mine in registry {
                    if let name = mine.name {
                        let count = self.getTotalCountForMine(mineName: name)
                        let updatedMine = MineRepresentation(name: name, count: count)
                        // test if mines array already has mine with this name
                        if !(mines.contains(where: { rep in rep.name == name })) {
                            mines.append(updatedMine)
                        }
                    }
                }
            }
        } else {
            // Remove "None selected" option
            mines = mines.filter({ (mine) -> Bool in
                return mine.name != String.localize("Search.Refine.NoSelection")
            })
        }

        
        // TODO: - use if mines need to be sorted
        
//        mines = mines.sorted(by: { (mine0, mine1) -> Bool in
//            guard let count0 = mine0.count, let count1 = mine1.count else {
//                return false
//            }
//            return count0 > count1
//        })
        
        return mines
        
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
    
    private func getMinesCount() -> Int {
        return mines.count
    }
    
    private func getInitialSelectedRow() -> Int? {
        if let cachedIndex = AppManager.sharedManager.cachedMineIndex, cachedIndex <= mines.count-1 {
            return AppManager.sharedManager.cachedMineIndex
        } else {
            if mines.count > 1 {
                return 1
            } else if mines.count == 1 {
                return 0
            } else {
                return nil
            }
        }
    }
    
    private func getInitialSelectedMine() -> MineRepresentation? {
        if let index = self.getInitialSelectedRow() {
            return self.mines[index]
        } else {
            return nil
        }
        
    }
    
    private func getTotalCountForMine(mineName: String) -> Int {
        if let facetList = self.getFacetListByName(mineName: mineName) {
            return facetList.getTotalFacetCount()
        }
        return 0
    }
    
    
    // MARK: Load from storyboard
    
    class func refineSearchViewController(withFacets: [FacetList]?, mineToSearch: String?) -> RefineSearchViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RefineSearchVC") as? RefineSearchViewController
        vc?.mineToSearch = mineToSearch
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
        AppManager.sharedManager.cachedCategory = nil
        let selected = self.mines[row]
        self.selectedMine = selected
        if !(mineToSearch != nil) {
            AppManager.sharedManager.cachedMineIndex = row
        } else {
            AppManager.sharedManager.cachedMineIndex = nil
        }
    }
    
        
    // MARK: Header view delegate
    
    func headerViewDidTapRefineSearchButton(headerView: HeaderView) {
        guard let selectedMine = self.selectedMine else {
            return
        }
        let selectedFacet = SelectedFacet(withMineName: selectedMine.name, facetName: String.localize("Search.Refine.AllCategories"), count: nil)
        self.delegate?.refineSearchViewController(controller: self, didSelectFacet: selectedFacet)
        self.navigationController?.popViewController(animated: true)
    }
    
    func headerView(headerView: HeaderView, didSwitchMode mode: RefineMode) {
        self.mines = []
        switch mode {
        case .One:
            self.mines = self.createMines(showAllMines: false)
            break
        default:
            // should show all mines
            self.mines = self.createMines(showAllMines: true)
            break
        }
    }
    
    // MARK: Table container delegate
    
    func tableContainer(tableContainer: TableContainer, didSelectCategory category: FormattedFacet) {
        if let facetName = category.getTitle(), let selectedMine = self.selectedMine {
            AppManager.sharedManager.cachedCategory = facetName
            let selectedFacet = SelectedFacet(withMineName: selectedMine.name, facetName: facetName, count: category.getCount())
            self.delegate?.refineSearchViewController(controller: self, didSelectFacet: selectedFacet)
        }
    }

}
