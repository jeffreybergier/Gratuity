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
    @IBOutlet private weak var lineFormingGroup: WKInterfaceGroup?
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let fontAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.Headline)]
    
    func updateCurrencyAmountLabel(newAmount: Int) {
        let dollarString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(newAmount), attributes: self.fontAttributes)
        self.moneyAmountLabel?.setAttributedText(dollarString)
    }
    
    var interfaceIsConfigured = false
    func configureInterface() {
        self.moneyAmountLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.lineFormingGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
        self.interfaceIsConfigured = true
    }
}
