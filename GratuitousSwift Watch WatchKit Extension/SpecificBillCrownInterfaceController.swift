//
//  SpecificBillCrownInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SpecificBillCrownInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var instructionalTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountTable: WKInterfaceTable?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    
    override func willActivate() {
        super.willActivate()
        
        if let billAmount = self.dataSource.billAmount {
            var lowerTableViewValue: Int = 4
            if billAmount < lowerTableViewValue {
                lowerTableViewValue = billAmount
            }
            let min = billAmount - lowerTableViewValue
            let max = billAmount + 11
            let range = max - min
            for index in 0..<range {
                let math = min + index
                self.data.append(math)
            }
        }
        
        self.reloadBillTableData()
    }
    
    private func reloadBillTableData() {
        self.billAmountTable?.setNumberOfRows(self.data.count, withRowType: "BillAmountTableRowController")
        
        for (index, value) in enumerate(self.data) {
            if let row = self.billAmountTable?.rowControllerAtIndex(index) as? MoneyTableRowController {
                row.updateCurrencyAmountLabel(value)
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let newBillAmount = self.data[rowIndex]
        self.dataSource.billAmount = newBillAmount
        self.pushControllerWithName("TipAmountCrownInterfaceController", context: nil)
    }
    
}
