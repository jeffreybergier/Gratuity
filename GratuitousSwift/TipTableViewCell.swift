//
//  TipTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class TipTableViewCell: UITableViewCell {
    
    @IBOutlet weak internal var tipAmountTextLabel: UILabel!
    
    internal var labelTextAttributes = [NSString(): NSObject()]
    var tipAmount: NSNumber = Double(0) {
        didSet {
            self.tipAmountTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.tipAmount.doubleValue), attributes: self.labelTextAttributes)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    internal func prepareLabelTextAttributes() {
        let font = self.tipAmountTextLabel.font
        let textColor = self.tipAmountTextLabel.textColor
        let text = self.tipAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 1.0
        shadow.shadowOffset = CGSizeMake(0.5, 0.5)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.labelTextAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.labelTextAttributes)
        self.tipAmountTextLabel.attributedText = attributedString
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                self.tipAmountTextLabel.textColor = GratuitousColorSelector.darkTextColor()
            })
        } else {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.tipAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
            })
        }
    }
    
}
