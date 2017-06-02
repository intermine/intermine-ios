//
//  Constants.swift
//  intermine-ios
//
//  Created by Nadia on 5/7/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

struct Endpoints {
    static let serviceListing = "/service"
    static let modelDescription = "/service/model"
    static let lists = "/service/lists"
    static let templates = "/service/templates"
    static let tokens = "/service/user/token"
    static let templateResults = "/service/template/results"
    static let intermineVersion = "/service/version/intermine"
    static let modelReleased = "/service/version/release"
    static let singleList = "/service/query/results"
    static let search = "/service/search"
    static let report = "/report.do"
}

struct General {
    static let modelName = "Cache"
    static let minesCellHeight = CGFloat(60.0)
    static let pageSize = 15
    static let searchSize = 5
    static let baseVersion = "1.6.5"
    static let descriptionCharactersLimit = 120
    static let defaultMine = "YeastMine"
    static let viewAnimationSpeed = 0.2
}

struct Icons {
    static let search = UIImage.init(icon: .FASearch, size: CGSize(width: 35, height: 35))
    static let templates = UIImage.init(icon: .FATasks, size: CGSize(width: 35, height: 35))
    static let lists = UIImage.init(icon: .FAList, size: CGSize(width: 35, height: 35))
    static let bookmark = UIImage.init(icon: .FABookmark, size: CGSize(width: 35, height: 35))
    static let login = UIImage.init(icon: .FASignIn, size: CGSize(width: 35, height: 35))
    static let close = UIImage.init(icon: .FATimes, size: CGSize(width: 40, height: 40))
    static let menu = UIImage.init(icon: .FABars, size: CGSize(width: 40, height: 40), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let check = UIImage.init(icon: .FACheck, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.tamarillo, backgroundColor: UIColor.clear)
    static let info = UIImage.init(icon: .FAInfo, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let star = UIImage.init(icon: .FAStar, size: CGSize(width: 35, height: 35), orientation: UIImageOrientation.up, textColor: Colors.white, backgroundColor: UIColor.clear)
    static let placeholder = UIImage.init(icon: .FAFile, size: CGSize(width: 500, height: 500), orientation: UIImageOrientation.up, textColor: Colors.gray, backgroundColor: UIColor.clear)
    
}

struct Colors {
    static let chelseaCucumber = UIColor.hexStringToUIColor(hex: "#8CA855")
    static let conifer = UIColor.hexStringToUIColor(hex: "#BED549")
    static let pistachio = UIColor.hexStringToUIColor(hex: "#8CA50B")
    static let eggplant = UIColor.hexStringToUIColor(hex: "#a50b8b") // complementary to pistachio
    static let white = UIColor.white
    static let gray = UIColor.hexStringToUIColor(hex: "#8F8F8F")
    static let greenMeadow = UIColor.hexStringToUIColor(hex: "#1cb25d")
    static let terracota = UIColor.hexStringToUIColor(hex: "#b22d1c")
    static let palma = UIColor.hexStringToUIColor(hex: "#1E9618")
    static let tamarillo = UIColor.hexStringToUIColor(hex: "#96181e")
    static let apple = UIColor.hexStringToUIColor(hex: "#43A047")
}

struct DefaultsKeys {
    static let token = "intermine.defaults.token"
    static let selectedMine = "intermine.defaults.selectedMine"
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
}
