//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 12/3/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation

class TotalAmountInterfaceController: WKInterfaceController {
   
    @IBOutlet private weak var totalAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.billAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount))
        self.tipAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.tipAmount))
        self.tipPercentageLabel?.setText(self.dataSource.percentStringFromFloat(self.dataSource.tipPercentage * 100))
        self.totalAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount + self.dataSource.tipAmount))
    }
}
