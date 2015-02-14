//
//  TipTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollTipTableRowController: NSObject {
    
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var starLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabelSmall: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    func setMoneyAmountLabel(#tipAmount: Int, billAmount: Int, starFlag: Bool) {
        self.starLabel?.setHidden(starFlag)
        let dollarString = self.dataSource.currencyStringFromInteger(tipAmount)
        let tipAmount = Int(round((Double(tipAmount) / Double(billAmount)) * 100))
        self.tipPercentageLabelSmall?.setText("\(tipAmount)%")
        self.tipAmountLabel?.setText(dollarString)
    }
}