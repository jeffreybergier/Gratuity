//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class SplitTotalInterfaceController: WKInterfaceController {
    
    @IBOutlet fileprivate weak var splitAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet fileprivate weak var splitAmount0CurrencyLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var splitAmount1CurrencyLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var splitAmount2CurrencyLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var splitAmount3CurrencyLabel: WKInterfaceLabel?
    @IBOutlet fileprivate weak var splitAmount4CurrencyLabel: WKInterfaceLabel?
    
    fileprivate let titleTextAttribute = GratuitousUIColor.WatchFonts.titleText
    fileprivate let valueTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        return GratuitousWatchApplicationPreferences.sharedInstance.preferences
    }
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    
    override func willActivate() {
        super.willActivate()
        // MARK: Configure notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
        
        // MARK: Configure Handoff
        self.updateUserActivity(HandoffTypes.SplitBillInterface.rawValue, userInfo: ["string" : "string"], webpageURL: .none)
        
        // MARK: Configure Title
        self.setTitle(SplitTotalInterfaceController.LocalizedString.CloseSplitBillTitle)
        let titleString = NSAttributedString(string: SplitTotalInterfaceController.LocalizedString.SplitBillTitleLabel, attributes: self.titleTextAttribute)
        self.splitAmountTitleLabel?.setAttributedText(titleString)
        
        // MARK: Configure the labels
        self.updateLabelText()
    }
    
    fileprivate func updateLabelText() {
        // MARK: Calculate Total Amount
        let billAmount = self.applicationPreferences.billIndexPathRow
        let tipAmount: Int
        if self.applicationPreferences.tipIndexPathRow != 0 {
            tipAmount = self.applicationPreferences.tipIndexPathRow
        } else {
            tipAmount = Int(round(self.applicationPreferences.suggestedTipPercentage * Double(billAmount)))
        }
        let totalAmount = billAmount + tipAmount
        
        // MARK: Divide up Total Amount
        let zero = totalAmount
        let one = Int(round(Double(totalAmount) /? 2))
        let two = Int(round(Double(totalAmount) /? 3))
        let three = Int(round(Double(totalAmount) /? 4))
        let four = Int(round(Double(totalAmount) /? 5))
        
        // prepare the attributed text
        let zeroString = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: zero), attributes: self.valueTextAttributes)
        let oneString = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: one), attributes: self.valueTextAttributes)
        let twoString = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: two), attributes: self.valueTextAttributes)
        let threeString = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: three), attributes: self.valueTextAttributes)
        let fourString = NSAttributedString(string: self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.applicationPreferences.overrideCurrencySymbol, amount: four), attributes: self.valueTextAttributes)
        
        // populate the labels
        self.splitAmount0CurrencyLabel?.setAttributedText(zeroString)
        self.splitAmount1CurrencyLabel?.setAttributedText(oneString)
        self.splitAmount2CurrencyLabel?.setAttributedText(twoString)
        self.splitAmount3CurrencyLabel?.setAttributedText(threeString)
        self.splitAmount4CurrencyLabel?.setAttributedText(fourString)
    }
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.currencyFormatter.locale = Locale.current
            self.updateLabelText()
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
        NotificationCenter.default.removeObserver(self)
    }
}
