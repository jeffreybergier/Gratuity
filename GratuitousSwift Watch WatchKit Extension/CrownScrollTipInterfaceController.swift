//
//  TipAmountCrownInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollTipInterfaceController: WKInterfaceController {
    @IBOutlet private weak var tipAmountTable: WKInterfaceTable?
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    
    override func willActivate() {
        super.willActivate()
        
        if let billAmount = self.dataSource.billAmount,
           let suggestedTipPercentage = self.dataSource.tipPercentage
        {
            let tipAmount = Int(round(Double(billAmount) * suggestedTipPercentage))
            var minusAmount: Int = 10
            if tipAmount < minusAmount {
                minusAmount = tipAmount
            }
            let min = tipAmount - minusAmount
            let max = tipAmount + 11
            let range = max - min
            self.data = []
            for index in 0..<range {
                let math = min + index
                self.data.append(math)
            }
            self.reloadBillTableDataWithIdealTip(tipAmount, billAmount: billAmount)
        }
        
    }
    
    private func reloadBillTableDataWithIdealTip(idealTip: Int, billAmount: Int) {
        self.tipAmountTable?.setNumberOfRows(self.data.count, withRowType: "TipTableRowController")
        
        for (index, value) in enumerate(self.data) {
            let star = idealTip == value ? false : true
            if let row = self.tipAmountTable?.rowControllerAtIndex(index) as? TipTableRowController {
                row.setMoneyAmountLabel(tipAmount: value, billAmount: billAmount, starFlag: star)
            }
        }
    }
}
