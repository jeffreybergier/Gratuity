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
    private var data = [Float]()
    
    override func willActivate() {
        super.willActivate()
        
        if let billAmountFloat = self.dataSource.billAmount {
            let billAmountInt = Int(roundf(billAmountFloat))
            var minusAmount: Int = 4
            if billAmountInt < minusAmount {
                minusAmount = billAmountInt
            }
            let min = billAmountInt - minusAmount
            let max = billAmountInt + 11
            let range = max - min
            for index in 0..<range {
                let math = min + index
                self.data.append(Float(math))
            }
        }
        
        self.reloadBillTableData()
    }
    
    private func reloadBillTableData() {
        self.billAmountTable?.setNumberOfRows(self.data.count, withRowType: "BillAmountTableRowController")
        
        for (index, value) in enumerate(self.data) {
            if let row = self.billAmountTable?.rowControllerAtIndex(index) as? MoneyTableRowController {
                row.updateMoneyAmountLabel(value)
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let newBillAmount = self.data[rowIndex]
        self.dataSource.billAmount = newBillAmount
        self.pushControllerWithName("TipAmountCrownInterfaceController", context: nil)
    }
    
}
