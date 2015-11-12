//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class SplitTotalInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var splitAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var splitAmount0CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount1CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount4CurrencyLabel: WKInterfaceLabel?
    
    private let titleTextAttribute = GratuitousUIColor.WatchFonts.titleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    
    private var applicationPreferences: GratuitousUserDefaults {
        return GratuitousWatchApplicationPreferences.sharedInstance.preferences
    }
    private let currencyFormatter = GratuitousNumberFormatter(style: .RespondsToLocaleChanges)
    
    override func willActivate() {
        super.willActivate()
        // MARK: Configure notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
        
        // MARK: Configure Handoff
        self.updateUserActivity(HandoffTypes.SplitBillInterface.rawValue, userInfo: ["string" : "string"], webpageURL: .None)
        
        // MARK: Configure Title
        self.setTitle(SplitTotalInterfaceController.LocalizedString.CloseSplitBillTitle)
        let titleString = NSAttributedString(string: SplitTotalInterfaceController.LocalizedString.SplitBillTitleLabel, attributes: self.titleTextAttribute)
        self.splitAmountTitleLabel?.setAttributedText(titleString)
        
        // MARK: Configure the labels
        self.updateLabelText()
    }
    
    private func updateLabelText() {
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
    
    @objc private func currencySignChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currencyFormatter.locale = NSLocale.currentLocale()
            self.updateLabelText()
        }
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.invalidateUserActivity()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
