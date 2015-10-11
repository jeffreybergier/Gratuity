//
//  BillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousTableViewCell: UITableViewCell {

    @IBOutlet weak private var dollarTextLabel: UILabel?
    private var labelTextAttributes = [String(): NSObject()]
    private let originalFont = UIFont(name: "Futura-Medium", size: 35.0)
    weak var dataSource: GratuitousiOSDataSource?
    var textSizeAdjustment: CGFloat = 1.0 {
        didSet {
            if (self.labelTextAttributes["NSFont"] != nil) {
                if let originalFont = self.originalFont {
                    let updatedFont = originalFont.fontWithSize(originalFont.pointSize * self.textSizeAdjustment)
                    self.labelTextAttributes["NSFont"] = updatedFont
                }}}}
    var billAmount: Int = 0 {
        didSet {
            self.didSetBillAmount()
        }}
    
    func setInterfaceRefreshNeeded() {
        self.didSetBillAmount()
    }
    
    @objc private func invertColorsDidChange(notification: NSNotification) {
        self.contentView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.prepareLabelTextAttributes()
    }
    
    private func didSetBillAmount() {
        let currencyFormattedString: String
        if self.billAmount != 0 {
            currencyFormattedString = self.dataSource?.currencyFormattedString(self.billAmount) !! ""
        } else {
            currencyFormattedString = ""
        }
        let stringForLabel = NSAttributedString(string: currencyFormattedString, attributes: self.labelTextAttributes)
        self.dollarTextLabel?.attributedText = stringForLabel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invertColorsDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
        //configure the font
        if let font = GratuitousUIConstant.originalFontForTableViewCellTextLabels() {
            self.dollarTextLabel?.font = font
        }
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.dollarTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    private func prepareLabelTextAttributes() {
        //configure the not selected text attributes
        let textColor = GratuitousUIConstant.lightTextColor()
        let text = self.dollarTextLabel?.text !! "Label" //Label string is what comes out of the NIB
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousUIConstant.textShadowColor()
        shadow.shadowBlurRadius = 1.5
        shadow.shadowOffset = CGSizeMake(0.5, 0.5)
        if let font = self.originalFont {
            let attributes = [
                NSForegroundColorAttributeName : textColor,
                NSFontAttributeName : font.fontWithSize(font.pointSize * self.textSizeAdjustment),
                //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
                NSShadowAttributeName : shadow
            ]
            self.labelTextAttributes = attributes
            
            //configure the label to be deselected
            let attributedString = NSAttributedString(string: text, attributes: self.labelTextAttributes)
            self.dollarTextLabel?.attributedText = attributedString
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
