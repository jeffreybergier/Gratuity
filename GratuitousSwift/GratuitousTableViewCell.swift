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
    
    weak var currencyFormatter: GratuitousCurrencyFormatter?
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
            self.didSetBillAmount()
        }
    }
    
    func localeDidChangeUpdateTextField(notification: NSNotification) {
        self.didSetBillAmount()
    }
    
    func invertColorsDidChange(notification: NSNotification) {
        self.contentView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.prepareLabelTextAttributes()
    }
    
    private func didSetBillAmount() {
        let currencyFormattedString = self.currencyFormatter?.currencyFormattedString(self.billAmount)
        var stringForLabel = NSAttributedString()
        if let currencyFormattedString = currencyFormattedString {
            stringForLabel = NSAttributedString(string: currencyFormattedString, attributes: self.labelTextAttributes)
        } else {
            println("GratuitousTableViewCell: Failure to unwrap optional currentFormattedString. You should never see this warning.")
            stringForLabel = NSAttributedString(string: NSString(format: "$%.0f", self.billAmount.doubleValue), attributes: self.labelTextAttributes)
        }
        self.dollarTextLabel.attributedText = stringForLabel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeUpdateTextField:", name: "currencyFormatterReadyReloadView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invertColorsDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
        //configure the font
        if let font = GratuitousUIConstant.originalFontForTableViewCellTextLabels() {
            self.dollarTextLabel.font = font
        }
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.dollarTextLabel.textColor = GratuitousUIConstant.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    private func prepareLabelTextAttributes() {
        //configure the not selected text attributes
        let font = self.dollarTextLabel.font
        let textColor = GratuitousUIConstant.lightTextColor()
        let text = self.dollarTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousUIConstant.textShadowColor()
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
