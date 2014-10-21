//
//  BillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTableViewCell: UITableViewCell {

    @IBOutlet weak private var dollarTextLabel: UILabel!
    
    private var labelTextAttributes = [NSString(): NSObject()]
    private var selectedLabelTextAttributes = [NSString(): NSObject()]
    var billAmount: NSNumber = Double(0) {
        didSet {
            self.dollarTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.billAmount.doubleValue), attributes: self.labelTextAttributes)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.dollarTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    private func prepareLabelTextAttributes() {
        //configure the not selected text attributes
        let font = self.dollarTextLabel.font
        let textColor = self.dollarTextLabel.textColor
        let text = self.dollarTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 1.5
        shadow.shadowOffset = CGSizeMake(0.5, 0.5)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.labelTextAttributes = attributes
        
        //configure the selected text attributes
        let selectedTextColor = GratuitousColorSelector.darkTextColor()
        let selectedAttributes = [
            NSForegroundColorAttributeName : selectedTextColor,
            NSFontAttributeName : font
        ]
        self.selectedLabelTextAttributes = selectedAttributes
        
        //configure the label to be deselected
        let attributedString = NSAttributedString(string: text!, attributes: self.labelTextAttributes)
        self.dollarTextLabel.attributedText = attributedString
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                self.dollarTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.billAmount.doubleValue), attributes: self.selectedLabelTextAttributes)
            })
        } else {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.dollarTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.billAmount.doubleValue), attributes: self.labelTextAttributes)
            })
        }
    }
    
}
