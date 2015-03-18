//
//  MoneyTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollBillTableRowController: NSObject {
    
    @IBOutlet private weak var moneyAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var outlineGroup: WKInterfaceGroup?
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    
    func updateCurrencyAmountLabel(newAmount: Int) {
        let dollarString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(newAmount), attributes: self.valueTextAttributes)
        self.moneyAmountLabel?.setAttributedText(dollarString)
    }
    
    var interfaceIsConfigured = false
    func configureInterface() {
        self.moneyAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.outlineGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.interfaceIsConfigured = true
    }
}
