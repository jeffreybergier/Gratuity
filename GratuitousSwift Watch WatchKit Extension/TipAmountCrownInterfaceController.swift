//
//  TipAmountCrownInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class TipAmountCrownInterfaceController: WKInterfaceController {
    @IBOutlet private weak var tipAmountTable: WKInterfaceTable?
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    
    override func willActivate() {
        super.willActivate()
        
        if let billAmountFloat = self.dataSource.billAmount {
            if let suggestedTipPercentage = self.dataSource.tipPercentage {
                let idealTipAmount = billAmountFloat * suggestedTipPercentage
                let idealTipAmountInt = Int(roundf(idealTipAmount))
                var minusAmount: Int = 10
                if idealTipAmountInt < minusAmount {
                    minusAmount = idealTipAmountInt
                }
                let min = idealTipAmountInt - minusAmount
                let max = idealTipAmountInt + 11
                let range = max - min
                self.data = []
                for index in 0..<range {
                    let math = min + index
                    self.data.append(math)
                }
                self.reloadBillTableDataWithIdealTip(idealTipAmountInt)
            }
        }
        
    }
    
    private func reloadBillTableDataWithIdealTip(idealTip: Int) {
        self.tipAmountTable?.setNumberOfRows(self.data.count, withRowType: "TipTableRowController")
        
        for (index, value) in enumerate(self.data) {
            let star = idealTip == value ? false : true
            if let row = self.tipAmountTable?.rowControllerAtIndex(index) as? TipTableRowController {
                row.setMoneyAmountLabel(value, WithStarFlag: star)
            }
        }
    }
}
