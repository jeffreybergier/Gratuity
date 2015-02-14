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
    private var numberOfRowsInTable = 50
    private var cellBeginIndex = 0
    private var currentContext: InterfaceControllerContext? {
        didSet {
            if let context = self.currentContext {
                switch context {
                case .CrownScrollInfinite:
                    self.setTitle(NSLocalizedString("Bill", comment: ""))
                    self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to choose the Bill Amount", comment: ""))
                    self.cellBeginIndex = 0
                    self.cellValueMultiplier = 1
                    self.numberOfRowsInTable = 500
                case .CrownScrollPagedOnes:
                    self.setTitle(NSLocalizedString("Refine", comment: ""))
                    self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to refine the Bill Amount", comment: ""))
                    let billAmount = self.dataSource.billAmount !! 0
                    let offset = 3
                    self.cellBeginIndex = billAmount >= offset ? billAmount - offset : billAmount
                    self.cellValueMultiplier = 1
                    self.numberOfRowsInTable = billAmount + 10
                case .CrownScrollPagedTens:
                    self.setTitle(NSLocalizedString("Bill", comment: ""))
                    self.instructionalTextLabel?.setText(NSLocalizedString("Scroll to the number closest to the Bill Amount", comment: ""))
                    self.cellBeginIndex = 0
                    self.cellValueMultiplier = 10
                    self.numberOfRowsInTable = 50
                default:
                    break
                }
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let contextString = context as? String,
        let context = InterfaceControllerContext(rawValue: contextString)
        {
            self.currentContext = context
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.currentContext == nil {
            switch self.dataSource.interfaceState {
            case .CrownScrollInfinite:
                self.currentContext = InterfaceControllerContext.CrownScrollInfinite
            case .CrownScrollPaged:
                self.currentContext = InterfaceControllerContext.CrownScrollPagedTens
            default:
                break
            }
        }
        
        self.data = []
        for index in self.cellBeginIndex..<self.numberOfRowsInTable {
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
        if let currentContext = self.currentContext {
            let nextContext: InterfaceControllerContext
            switch currentContext {
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
    
    
}
