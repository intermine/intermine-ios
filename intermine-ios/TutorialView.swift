//
//  TutorialView.swift
//  intermine-ios
//
//  Created by Nadia on 7/31/17.
//  Copyright © 2017 Nadia. All rights reserved.
//

import UIKit

class TutorialView: BaseView {
    
    enum Stage: Int {
        case One = 0
        case Two
        case Three
        case Four
        case Five
        case Six
    }
    
    private var rotations: [CGFloat] = [-30.0, 20.0, 200.0, 180.0, 170.0, 160.0]
    private var descriptions: [String] = [ String.localize("Tutorial.Description.Menu"),
                                           String.localize("Tutorial.Description.SelectedMine"),
                                           String.localize("Tutorial.Description.Templates"),
                                           String.localize("Tutorial.Description.Lists"),
                                           String.localize("Tutorial.Description.Favs"),
                                           String.localize("Tutorial.Description.Login") ]
    
    private var currentStage: Stage = Stage.One {
        didSet {
            if let arrowImageViews = self.arrowImageViews {
                for imageView in arrowImageViews {
                    if imageView.tag == currentStage.rawValue {
                        if let descriptionLabel = self.descriptionLabel {
                            UIView.transition(with: descriptionLabel,
                                              duration: 0.2,
                                              options: .transitionCrossDissolve,
                                              animations: { [weak self] in
                                                self?.descriptionLabel?.text = self?.descriptions[(self?.currentStage.rawValue)!]
                                }, completion: nil)
                            if currentStage == Stage.Six {
                                self.updateButton(withText: String.localize("Tutorial.Done"))
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.repeatButton?.alpha = 1
                                }, completion: { (done) in
                                    self.repeatButton?.isEnabled = true
                                })
                            } else {
                                self.updateButton(withText: String.localize("Tutorial.Next"))
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.repeatButton?.alpha = 0
                                }, completion: { (done) in
                                    self.repeatButton?.isEnabled = false
                                })
                            }
                        }
                        UIView.animate(withDuration: 0.2, animations: {
                            imageView.alpha = 1
                        })
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            imageView.alpha = 0
                        })
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet var arrowImageViews: [UIImageView]?
    @IBOutlet weak var nextButton: UIButton?
    @IBOutlet weak var repeatButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionLabel?.text = ""
        if let arrowImageViews = self.arrowImageViews {
            for imageView in arrowImageViews {
                imageView.image = Icons.arrow
                imageView.alpha = 0
                let degrees = rotations[imageView.tag]
                rotateView(view: imageView, byDegrees: degrees)
            }
        }
        self.currentStage = Stage.One
        nextButton?.setTitle(String.localize("Tutorial.Next"), for: .normal)
        nextButton?.backgroundColor = .clear
        nextButton?.layer.cornerRadius = 5
        nextButton?.layer.borderWidth = 1
        nextButton?.layer.borderColor = UIColor.white.cgColor
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        repeatButton?.setImage(Icons.refresh, for: .normal)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if let nextStage = Stage(rawValue: self.currentStage.rawValue + 1) {
            self.currentStage = nextStage
        } else {
            // send notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.tutorialFinished), object: self, userInfo: nil)
        }
    }
    
    @IBAction func repeatButtonTapped(_ sender: Any) {
        self.currentStage = Stage.One
    }
    
    private func updateButton(withText: String) {
        if let nextButton = self.nextButton {
            UIView.transition(with: nextButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                nextButton.setTitle(withText, for: .normal)
            }, completion: nil)
        }
    }
    
    private func rotateView(view: UIImageView, byDegrees degrees: CGFloat) {
        let rads = degrees * CGFloat(Double.pi/180)
        view.transform = CGAffineTransform(rotationAngle: rads)
    }

}
