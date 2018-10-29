//
//  GratuitousDisclosureTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousDisclosureTableViewCell: GratuitousSelectFadeTableViewCell {
    
    @IBOutlet fileprivate weak var cellTextLabel: UILabel?
    fileprivate weak var disclosureButton: UIButton? {
        didSet {
            if let originalImage = self.disclosureButton?.backgroundImage(for: UIControlState()) {
                let templateImage = originalImage.withRenderingMode(.alwaysTemplate)
                self.disclosureButton?.setBackgroundImage(templateImage, for: UIControlState())
                self.disclosureButton?.setBackgroundImage(templateImage, for: .highlighted)
                self.disclosureButton?.setBackgroundImage(templateImage, for: .disabled)
                self.disclosureButton?.setBackgroundImage(templateImage, for: .selected)
                self.disclosureButton?.setBackgroundImage(templateImage, for: .application)
                self.disclosureButton?.setBackgroundImage(templateImage, for: .reserved)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.animatableTextLabel = self.cellTextLabel
        
        for view in self.subviews {
            if let button = view as? UIButton {
                self.disclosureButton = button
                break
            }
        }
    }
}
