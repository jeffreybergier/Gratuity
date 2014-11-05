//
//  GratuitousContactButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/4/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousContactButtons: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.tintColor = GratuitousColorSelector.lightTextColor()
        self.adjustsImageWhenHighlighted = false
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 3
        self.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
    }
}
