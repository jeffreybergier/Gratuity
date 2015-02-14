//
//  MoneyTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class MoneyTableRowController: NSObject {
    
    @IBOutlet private weak var moneyAmountLabel: WKInterfaceLabel?
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    func updateCurrencyAmountLabel(newAmount: Int) {
        let dollarString = self.dataSource.currencyStringFromInteger(newAmount)
        self.moneyAmountLabel?.setText(dollarString)
    }
}
