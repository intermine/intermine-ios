//
//  ImageBarItem.swift
//  intermine-ios
//
//  Created by Nadia on 7/1/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

protocol FavoriteButtonDelegate: class {
    func didTapFavoriteButton(favoriteButton: FavoriteButton)
}

class FavoriteButton: UIButton {
    
    private let selectedImage: UIImage = Icons.bookmark
    private let deselectedImage: UIImage = Icons.bookmarkEmpty
    
    weak var delegate: FavoriteButtonDelegate?
    
    private var isFavorite: Bool {
        didSet {
            if self.isFavorite {
                self.setImage(selectedImage, for: .normal)
            } else {
                self.setImage(deselectedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isFavorite = false
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(FavoriteButton.tapped), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        isFavorite = false
        super.init(frame: frame)
        self.addTarget(self, action: #selector(FavoriteButton.tapped), for: .touchUpInside)
    }
    
    convenience init(isFavorite: Bool) {
        self.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        changeSelectedState(isFavorite: isFavorite)
    }

    func changeSelectedState(isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
    
    func tapped() {
        isFavorite = !isFavorite
        self.delegate?.didTapFavoriteButton(favoriteButton: self)
    }

}
