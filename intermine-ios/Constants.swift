//
//  Constants.swift
//  intermine-ios
//
//  Created by Nadia on 5/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

struct Endpoints {
    static let modelDescription = "/service/model"
    static let lists = "/service/lists"
    static let templates = "/service/templates"
    static let tokens = "/service/user/token"
    static let templateResults = "/service/template/results"
    static let intermineVersion = "/service/version/intermine" // version of the intermine software
    static let modelReleased = "/service/version/release" // version of the data *inside* the intermine
    static let singleList = "/service/query/results"
    static let search = "/service/search"
    static let searchResultReport = "/report.do"
    static let registryDomain = "http://registry.intermine.org"
    static let registryInstances = "/service/instances"
    static let listReport = "/bagDetails.do"
    static let pubmed = "https://www.ncbi.nlm.nih.gov/pubmed/?term="
}

struct General {
    static let modelName = "Cache"
    static let minesCellHeight = CGFloat(60.0)
    static let pageSize = 15
    static let searchSize = 5
    static let baseVersion = "1.6.5"
    static let descriptionCharactersLimit = 120
    static let defaultMine = "MouseMine"
    static let viewAnimationSpeed = 0.2
    static let nullValues = ["<null>", "NULL", "-"]
    static let timeoutIntervalForRequest: Double = 1800
    static let timeoutForRegistryUpdate: Double = 30
    static let needUppercase = ["dbid", "id", "ebi"]
}

struct Icons {
    static let search = UIImage.init(icon: .FASearch, size: CGSize(width: 35, height: 35))
    static let templates = UIImage.init(icon: .FATasks, size: CGSize(width: 35, height: 35))
    static let lists = UIImage.init(icon: .FAList, size: CGSize(width: 35, height: 35))
    static let bookmark = UIImage.init(icon: .FABookmark, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let bookmarkEmpty = UIImage.init(icon: .FABookmarkO, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let login = UIImage.init(icon: .FASignIn, size: CGSize(width: 35, height: 35))
    static let close = UIImage.init(icon: .FATimes, size: CGSize(width: 40, height: 40))
    static let menu = UIImage.init(icon: .FABars, size: CGSize(width: 40, height: 40), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let check = UIImage.init(icon: .FACheck, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.tamarillo, backgroundColor: UIColor.clear)
    static let info = UIImage.init(icon: .FAInfo, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let star = UIImage.init(icon: .FAStar, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let placeholder = UIImage.init(icon: .FAFile, size: CGSize(width: 500, height: 500), orientation: UIImageOrientation.up, textColor: Colors.gray56, backgroundColor: UIColor.clear)
    static let titleBarPlaceholder = UIImage.init(icon: .FAChainBroken, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let user = UIImage.init(icon: .FAUserO, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.palma, backgroundColor: UIColor.clear)
    static let arrow = UIImage.init(icon: .FALongArrowUp, size: CGSize(width: 50, height: 70), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let refresh = UIImage.init(icon: .FARefresh, size: CGSize(width: 45, height: 45), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    
}

struct Colors {
    static let white = UIColor.white
    static let gray56 = UIColor.hexStringToUIColor(hex: "#8F8F8F")
    static let palma = UIColor.hexStringToUIColor(hex: "#1E9618")
    static let tamarillo = UIColor.hexStringToUIColor(hex: "#96181e")
    static let apple = UIColor.hexStringToUIColor(hex: "#43A047")
    
    // Search facet colors
    static let sushi = UIColor.hexStringToUIColor(hex: "#8BC34A")
    static let amber = UIColor.hexStringToUIColor(hex: "#FFC107")
    static let dodgerBlue = UIColor.hexStringToUIColor(hex: "#2196F3")
    static let amaranth = UIColor.hexStringToUIColor(hex: "#E91E63")
    static let orange = UIColor.hexStringToUIColor(hex: "#FF5722")
    static let seance = UIColor.hexStringToUIColor(hex: "#9C27B0")
    static let silver = UIColor.hexStringToUIColor(hex: "#CCCCCC")
}

struct DefaultsKeys {
    static let token = "intermine.defaults.token"
    static let selectedMine = "intermine.defaults.selectedMine"
    static let tutorialShown = "intermine.defaults.tutorial.isShown"
}

struct Operations {
    static let equalsEquals = "=="
    static let like = "LIKE"
    static let equals = "="
    static let notEquals = "!="
    static let notLike = "NOT LIKE"
    static let notEqualsEquals = "!=="
    static let doesNotContain = "DOES NOT CONTAIN"
    static let contains = "CONTAINS"
    static let moreOrEqual = ">="
    static let lessOrEqual = "<="
    static let more = ">"
    static let less = "<"
}

struct Notifications {
    static let operationChanged = "notification.operation.changed"
    static let valueChanged = "notification.value.changed"
    static let mineSelected = "notification.mine.selected"
    static let facetsUpdated = "notification.facets.updated"
    static let searchFailed = "notification.search.failed"
    static let registryLoaded = "notification.registry.loaded"
    static let tutorialFinished = "notification.tutorial.finished"
}
