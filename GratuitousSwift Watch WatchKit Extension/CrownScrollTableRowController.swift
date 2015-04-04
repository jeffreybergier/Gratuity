//
//  TipTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollTableRowController: NSObject {
    
    @IBOutlet private weak var outlineGroup: WKInterfaceGroup?
    @IBOutlet private weak var bigCurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var starLabel: WKInterfaceLabel?
    @IBOutlet private weak var smallPercentageLabel: WKInterfaceLabel?
    
    private var currencyAmount: Int?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.smallValueText
    
    func setCurrencyLabels(#bigCurrency: Int, littlePercentage: Double?, starFlag: Bool?) {
        // set the big text label
        self.bigCurrencyLabel?.setAttributedText(NSAttributedString(string: self.dataSource.currencyStringFromInteger(bigCurrency), attributes: self.valueTextAttributes))
        
        // set the property for possible use later
        self.currencyAmount = bigCurrency
        
        // set the star flag if it was given by the controller
        if let starFlag = starFlag {
            self.starLabel?.setHidden(starFlag)
        }
        // set the percentage if its set
        if let littlePercentage = littlePercentage {
            self.smallPercentageLabel?.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(littlePercentage), attributes: self.smallValueTextAttributes))
        } else {
            self.smallPercentageLabel?.setAttributedText(NSAttributedString(string: "– %", attributes: self.smallValueTextAttributes))
            self.starLabel?.setHidden(true)
        }
    }
    
    var interfaceIsConfigured = false
    func configureInterface(#parentInterfaceController: WKInterfaceController) {
//        self.smallPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
//        self.bigCurrencyLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.starLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.outlineGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.interfaceIsConfigured = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySymbolShouldUpdate:", name: WatchNotification.CurrencySymbolShouldUpdate, object: parentInterfaceController)
    }
    
    @objc private func currencySymbolShouldUpdate(notification: NSNotification) {
        if let currencyAmount = self.currencyAmount {
            self.bigCurrencyLabel?.setAttributedText(NSAttributedString(string: self.dataSource.currencyStringFromInteger(currencyAmount), attributes: self.valueTextAttributes))
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}