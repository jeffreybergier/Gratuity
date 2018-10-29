//
//  BillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var dollarTextLabel: UILabel?
    fileprivate var labelTextAttributes = [String(): NSObject()]
    fileprivate let originalFont = UIFont(name: "Futura-Medium", size: 35.0)
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    fileprivate var currentCurrencySign: CurrencySign {
        return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences.overrideCurrencySymbol
    }
    var textSizeAdjustment: CGFloat = 1.0 {
        didSet {
            if (self.labelTextAttributes["NSFont"] != nil) {
                if let originalFont = self.originalFont {
                    let updatedFont = originalFont.withSize(originalFont.pointSize * self.textSizeAdjustment)
                    self.labelTextAttributes["NSFont"] = updatedFont
                }}}}
    var billAmount: Int = 0 {
        didSet {
            self.didSetBillAmount()
        }}
    
    func setInterfaceRefreshNeeded() {
        self.didSetBillAmount()
    }
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.currencyFormatter.locale = Locale.current
            self.setInterfaceRefreshNeeded()
        }
    }
    
    fileprivate func didSetBillAmount() {
        let currencyFormattedString: String
        if self.billAmount != 0 {
            currencyFormattedString = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: self.billAmount)
        } else {
            currencyFormattedString = ""
        }
        let stringForLabel = NSAttributedString(string: currencyFormattedString, attributes: self.labelTextAttributes)
        self.dollarTextLabel?.attributedText = stringForLabel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
        
        //configure the font
        if let font = GratuitousUIConstant.originalFontForTableViewCellTextLabels() {
            self.dollarTextLabel?.font = font
        }
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.dollarTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    fileprivate func prepareLabelTextAttributes() {
        //configure the not selected text attributes
        let textColor = GratuitousUIConstant.lightTextColor()
        let text = self.dollarTextLabel?.text !! "Label" //Label string is what comes out of the NIB
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousUIConstant.textShadowColor()
        shadow.shadowBlurRadius = 1.5
        shadow.shadowOffset = CGSize(width: 0.5, height: 0.5)
        if let font = self.originalFont {
            let attributes = [
                NSForegroundColorAttributeName : textColor,
                NSFontAttributeName : font.withSize(font.pointSize * self.textSizeAdjustment),
                NSShadowAttributeName : shadow
            ]
            self.labelTextAttributes = attributes
            
            //configure the label to be deselected
            let attributedString = NSAttributedString(string: text, attributes: self.labelTextAttributes)
            self.dollarTextLabel?.attributedText = attributedString
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
