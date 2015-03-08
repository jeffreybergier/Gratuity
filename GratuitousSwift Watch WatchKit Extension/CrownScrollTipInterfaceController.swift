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
    private var currentContext = InterfaceControllerContext.NotSet
    private var interfaceControllerIsConfigured = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentContext: InterfaceControllerContext
        //let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.CrownScrollTipChooser
        } else {
            fatalError("CrownScrollTipInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            self.configureInterfaceController()
            self.interfaceControllerIsConfigured = true
        }
    }
    
    private func configureInterfaceController() {
        switch self.currentContext {
        case .CrownScrollTipChooser:
            self.setTitle(NSLocalizedString("Tip", comment: ""))
            self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to the choose your desired Tip Amount", comment: ""))
            self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            let billAmount = self.dataSource.billAmount !! 0
            let suggestedTipPercentage = self.dataSource.tipPercentage !! 0.2
            let tipAmount = Int(round(Double(billAmount) * suggestedTipPercentage))
            let offset = 5
            var cellBeginIndex: Int
            //let cellBeginIndex: Int
            if tipAmount >= offset {
                cellBeginIndex = tipAmount - offset
            } else {
                cellBeginIndex = tipAmount
            }
            let numberOfRowsInTable = cellBeginIndex + offset * 3
            
            self.data = []
            for index in cellBeginIndex ..< numberOfRowsInTable {
                self.data.append(index)
            }
            self.reloadTipTableData(idealTip: tipAmount, billAmount: billAmount)
        default:
            break
        }
    }
    
    private func reloadTipTableData(#idealTip: Int, billAmount: Int) {
        if let tableView = self.tipAmountTable {
            tableView.setNumberOfRows(self.data.count, withRowType: "CrownScrollTipTableRowController")
            
            for (index, value) in enumerate(self.data) {
                let star = idealTip == value ? false : true
                if let row = tableView.rowControllerAtIndex(index) as? CrownScrollTipTableRowController {
                    if row.interfaceIsConfigured == false {
                        row.configureInterface()
                    }
                    row.setMoneyAmountLabel(tipAmount: value, billAmount: billAmount, starFlag: star)
                }
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let newTipAmount = self.data[rowIndex]
        self.dataSource.tipAmount = newTipAmount
        switch self.currentContext {
        case .CrownScrollTipChooser:
            self.pushControllerWithName("TotalAmountInterfaceController", context: InterfaceControllerContext.TotalAmountInterfaceController.rawValue)
        default:
            break
        }
    }
    
}
