//
//  TipTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class TipTableRowController: NSObject {
    
    @IBOutlet private weak var moneyAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var starLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    func setMoneyAmountLabel(newAmount: Int, WithStarFlag star: Bool) {
        self.starLabel?.setHidden(star)
        let dollarString = self.dataSource.dollarStringFromFloat(Float(newAmount))
        self.moneyAmountLabel?.setText(dollarString)
    }
}