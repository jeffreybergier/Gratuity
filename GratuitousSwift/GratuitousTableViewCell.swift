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
    var textSizeAdjustment: NSNumber = 1.0 {
        didSet {
            if (self.labelTextAttributes["NSFont"] != nil) {
                let originalFont = self.labelTextAttributes["NSFont"] as UIFont
                let updatedFont = originalFont.fontWithSize(originalFont.pointSize * CGFloat(self.textSizeAdjustment.floatValue))
                self.labelTextAttributes["NSFont"] = updatedFont
            }
        }
    }
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
        
        //configure the label to be deselected
        let attributedString = NSAttributedString(string: text!, attributes: self.labelTextAttributes)
        self.dollarTextLabel.attributedText = attributedString
    }
    
}
