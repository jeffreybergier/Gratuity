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
    @IBOutlet private weak var loadingImageGroup: WKInterfaceGroup?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    private var cellValueMultiplier = 1
    private var currentContext: InterfaceControllerContext = .NotSet
    
    private var interfaceControllerIsConfigured = false
    
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //let currentContext: InterfaceControllerContext
        var currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.CrownScrollTipChooser
        } else {
            fatalError("CrownScrollBillInterfaceController: Context not present during awakeWithContext:")
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
        
        self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        
        var numberOfRowsInTable: Int
        var cellBeginIndex: Int
        //let numberOfRowsInTable: Int
        //let cellBeginIndex: Int
        switch self.currentContext {
        case .CrownScrollInfinite:
            self.setTitle(NSLocalizedString("Bill Amount", comment: ""))
            self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to choose the Bill Amount", comment: ""), attributes: self.titleTextAttributes))
            cellBeginIndex = 1
            numberOfRowsInTable = 500
            self.cellValueMultiplier = 1
        case .CrownScrollPagedOnes:
            self.setTitle(NSLocalizedString("Refine Bill", comment: ""))
            self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to refine the Bill Amount", comment: ""), attributes: self.titleTextAttributes))
            let billAmount = self.dataSource.billAmount !! 0
            let offset = 3
            cellBeginIndex = billAmount >= offset ? billAmount - offset : billAmount
            numberOfRowsInTable = billAmount + 10
            self.cellValueMultiplier = 1
        case .CrownScrollPagedTens:
            self.setTitle(NSLocalizedString("Bill Amount", comment: ""))
            self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to the number closest to the Bill Amount", comment: ""), attributes: self.titleTextAttributes))
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
        self.loadingImageGroup?.setHidden(true)
        self.instructionalTextLabel?.setHidden(false)
        self.billAmountTable?.setHidden(false)
    }
    
    private func reloadBillTableData() {
        self.billAmountTable?.setNumberOfRows(self.data.count, withRowType: "CrownScrollBillTableRowController")
        
        for (index, value) in enumerate(self.data) {
            if let row = self.billAmountTable?.rowControllerAtIndex(index) as? CrownScrollBillTableRowController {
                if row.interfaceIsConfigured == false {
                    row.configureInterface()
                }
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
        
        var nextContext: InterfaceControllerContext
        //let nextContext: InterfaceControllerContext
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
