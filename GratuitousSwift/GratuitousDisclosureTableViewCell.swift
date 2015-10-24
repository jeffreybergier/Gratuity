//
//  GratuitousDisclosureTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class GratuitousDisclosureTableViewCell: GratuitousSelectFadeTableViewCell {
    
    @IBOutlet private weak var cellTextLabel: UILabel?
    private weak var disclosureButton: UIButton? {
        didSet {
            if let originalImage = self.disclosureButton?.backgroundImageForState(.Normal) {
                let templateImage = originalImage.imageWithRenderingMode(.AlwaysTemplate)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Normal)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Highlighted)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Disabled)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Selected)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Application)
                self.disclosureButton?.setBackgroundImage(templateImage, forState: .Reserved)
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