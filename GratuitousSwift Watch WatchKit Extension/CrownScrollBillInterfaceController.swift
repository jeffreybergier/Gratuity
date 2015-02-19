//
//  CrownScrollInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollBillInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountTable: WKInterfaceTable?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    private var cellValueMultiplier = 1
    private var currentContext: InterfaceControllerContext = .NotSet
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.CrownScrollTipChooser
        } else {
            fatalError("CrownScrollBillInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        let numberOfRowsInTable: Int
        let cellBeginIndex: Int
        switch self.currentContext {
        case .CrownScrollInfinite:
            self.setTitle(NSLocalizedString("Bill", comment: ""))
            self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to choose the Bill Amount", comment: ""))
            cellBeginIndex = 1
            numberOfRowsInTable = 500
            self.cellValueMultiplier = 1
        case .CrownScrollPagedOnes:
            self.setTitle(NSLocalizedString("Refine", comment: ""))
            self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to refine the Bill Amount", comment: ""))
            let billAmount = self.dataSource.billAmount !! 0
            let offset = 3
            cellBeginIndex = billAmount >= offset ? billAmount - offset : billAmount
            numberOfRowsInTable = billAmount + 10
            self.cellValueMultiplier = 1
        case .CrownScrollPagedTens:
            self.setTitle(NSLocalizedString("Bill", comment: ""))
            self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to the number closest to the Bill Amount", comment: ""))
            cellBeginIndex = 1
            numberOfRowsInTable = 50
            self.cellValueMultiplier = 10
        default:
            fatalError("CrownScrollBillInterfaceController: Context not set")
        }
        
        self.data = []
        for index in cellBeginIndex ..< numberOfRowsInTable {
            self.data.append(index)
        }
        
        self.clearBillDataTable()
        self.reloadBillTableData()
    }
    
    private func reloadBillTableData() {
        self.billAmountTable?.setNumberOfRows(self.data.count, withRowType: "CrownScrollBillTableRowController")
        
        for (index, value) in enumerate(self.data) {
            if let row = self.billAmountTable?.rowControllerAtIndex(index) as? CrownScrollBillTableRowController {
                row.updateCurrencyAmountLabel(value * self.cellValueMultiplier)
            }
        }
    }
    
    private func clearBillDataTable() {
        self.billAmountTable?.setNumberOfRows(0, withRowType: "BillAmountTableRowController")
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let newBillAmount = self.data[rowIndex] * self.cellValueMultiplier
        self.dataSource.billAmount = newBillAmount
        
        let nextContext: InterfaceControllerContext
        switch self.currentContext {
        case .CrownScrollPagedOnes:
            nextContext = .CrownScrollTipChooser
        case .CrownScrollPagedTens:
            nextContext = .CrownScrollPagedOnes
        default:
            nextContext = .CrownScrollTipChooser
        }
        
        switch nextContext {
        case .CrownScrollTipChooser:
            self.pushControllerWithName("CrownScrollTipInterfaceController", context: nextContext.rawValue)
        default:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: nextContext.rawValue)
        }
    }
    
    
}