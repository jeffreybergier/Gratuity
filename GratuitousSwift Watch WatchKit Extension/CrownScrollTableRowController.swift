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
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    
    func setCurrencyLabels(#bigCurrency: Int, littlePercentage: Double?, starFlag: Bool?) {
        // set the big text label
        self.bigCurrencyLabel?.setAttributedText(NSAttributedString(string: self.dataSource.currencyStringFromInteger(bigCurrency), attributes: self.valueTextAttributes))
        
        // set the star flag if it was given by the controller
        if let starFlag = starFlag {
            self.starLabel?.setHidden(starFlag)
        }
        // set the percentage if its set
        if let littlePercentage = littlePercentage {
            self.smallPercentageLabel?.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(littlePercentage), attributes: self.titleTextAttributes))
        }
    }
    
    var interfaceIsConfigured = false
    func configureInterface() {
        self.smallPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.bigCurrencyLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.starLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.outlineGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.interfaceIsConfigured = true
    }
}