//
//  CrownScrollInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollInterfaceController: GratuitousMenuInterfaceController {
    
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencyAmountTable: WKInterfaceTable?
    @IBOutlet private weak var loadingImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    @IBOutlet private weak var largerButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var largerButtonLabel: WKInterfaceLabel?
    @IBOutlet private weak var smallerButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var smallerButtonLabel: WKInterfaceLabel?
    
    private let data: [Int] = {
        var array = [Int]()
        for index in 0 ..< 49 {
            array.append(index)
        }
        return array
        }()
    private(set) var currentContext = CrownScrollerInterfaceContext.NotSet
    private var billAmountOffset: Int? // This property is only set when context is CrownScrollPagedOnes
    private var interfaceControllerIsConfigured = false
    private var highestDataIndexInTable: Int = 0 {
        didSet {
            if self.highestDataIndexInTable >= self.data.count - 1 {
                self.largerButtonGroup?.setHidden(true)
            }
            println("highestDataIndexInTable: \(self.highestDataIndexInTable)")
            println("highestValueFromArray: \(self.data[self.highestDataIndexInTable])")
        }
    }
    private var lowestDataIndexInTable: Int = 0 {
        didSet {
            if self.lowestDataIndexInTable <= 0 {
                self.smallerButtonGroup?.setHidden(true)
            }
            
            println("lowestDataIndexInTable: \(self.lowestDataIndexInTable)")
            println("lowestValueFromArray: \(self.data[self.lowestDataIndexInTable])")
        }
    }
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //let currentContext: CrownScrollerInterfaceContext
        var currentContext: CrownScrollerInterfaceContext
        if let contextString = context as? String {
            currentContext = CrownScrollerInterfaceContext(rawValue: contextString) !! CrownScrollerInterfaceContext.Bill
        } else {
            fatalError("CrownScrollBillInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        //
        // This is always executed on a background queue
        // All UI changes must be done at the end
        // All UI changes must call back to the main queue
        //
        dispatch_async(dispatch_get_main_queue()) {
            self.clearDataTable()
            
            // set the text
            self.largerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Larger", comment: ""), attributes: self.largerButtonTextAttributes))
            self.smallerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Smaller", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set colors
            self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.largerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.largerButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.smallerButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            // show the UI
            self.largerButtonGroup?.setHidden(false)
            self.smallerButtonGroup?.setHidden(false)
            self.instructionalTextLabel?.setHidden(false)
            self.currencyAmountTable?.setHidden(false)
            
            switch self.currentContext {
            case .Bill:
                self.setTitle(NSLocalizedString("Bill Amount", comment: ""))
                self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to select Bill", comment: ""), attributes: self.titleTextAttributes))
            case .Tip:
                self.setTitle(NSLocalizedString("Tip Amount", comment: ""))
                self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to select Tip", comment: ""), attributes: self.titleTextAttributes))
            case .NotSet:
                break
            }
            
            // configure the table
            self.configureTableForTheFirstTime()
            
            // show the UI
            self.loadingImageGroup?.setHidden(true)
            self.interfaceControllerIsConfigured = true
            
            NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "scrollToCorrectRowIfNeeded:", userInfo: nil, repeats: false) // this fixes a bug where scrolling didn't work properly
        }
    }
    
    @objc private func scrollToCorrectRowIfNeeded(timer: NSTimer?) {
        timer?.invalidate()
        var currencyAmountToScrollTo: Int
        switch self.currentContext {
        case .Bill:
            currencyAmountToScrollTo = self.dataSource.defaultsManager.billIndexPathRow < self.data.count ? self.dataSource.defaultsManager.billIndexPathRow : self.data.count - 1
        case .Tip:
            currencyAmountToScrollTo = self.dataSource.defaultsManager.tipIndexPathRow < self.data.count ? self.dataSource.defaultsManager.tipIndexPathRow : self.data.count - 1
        case .NotSet:
            currencyAmountToScrollTo = 0
        }
        let rowIndexPath = currencyAmountToScrollTo - self.lowestDataIndexInTable
        println("Scroll to Currency: \(currencyAmountToScrollTo), IndexPath: \(rowIndexPath)")
        
        if rowIndexPath > 0 && rowIndexPath < self.currencyAmountTable?.numberOfRows {
            self.currencyAmountTable!.scrollToRowAtIndex(rowIndexPath)
        }
    }
    
    private func insertTableRowControllersAtTop(newNumberOfRows: Int) {
        if self.currentContext != .NotSet {
            if let tableView = self.currencyAmountTable {
                let currentLowestDataIndex = self.lowestDataIndexInTable
                let newLowestDataIndex = currentLowestDataIndex - newNumberOfRows > 0 ? currentLowestDataIndex - newNumberOfRows : 0
                let endOfRange = currentLowestDataIndex < newNumberOfRows ? currentLowestDataIndex : newNumberOfRows
                for index in 0 ..< endOfRange {
                    let value = self.data[newLowestDataIndex + index]
                    switch self.currentContext {
                    case .Bill:
                        tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                        if let row = tableView.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                            if row.interfaceIsConfigured == false {
                                row.configureInterface()
                            }
                            //row.updateCurrencyAmountLabel(value)
                            row.setCurrencyLabels(bigCurrency: value, littlePercentage: nil, starFlag: nil)
                        }
                    case .Tip:
                        tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollTipTableRowController")
                        let billAmount = self.dataSource.defaultsManager.billIndexPathRow
                        let suggestedTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
                        let idealTip = Int(round(Double(billAmount) * suggestedTipPercentage))
                        let star = idealTip == value ? false : true
                        if let row = tableView.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                            if row.interfaceIsConfigured == false {
                                row.configureInterface()
                            }
                            row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                        }
                    default:
                        break
                    }
                    // update instance variables
                    self.lowestDataIndexInTable = newLowestDataIndex
                }
            }
        } else {
            fatalError("CrownScrollBillInterfaceController: insertAmountTableRowControllersAtTop called when currentContext was not .NotSet")
        }
    }
    
//    private func insertBillAmountTableRowControllersAtBottom(newNumberOfRows: Int) {
//        switch self.currentContext {
//        case .Bill:
//            if let tableView = self.currencyAmountTable {
//                // update the table
//                let currentNumberOfRowsInTable = tableView.numberOfRows
//                let currentLowestNumber = self.lowestDataIndexInTable
//                let currentHighestNumber = self.highestDataIndexInTable
//                let newHighestNumber = currentHighestNumber + newNumberOfRows
//                for index in currentNumberOfRowsInTable ..< currentNumberOfRowsInTable + newNumberOfRows {
//                    let correctedIndex = index + currentHighestNumber - currentNumberOfRowsInTable
//                    if correctedIndex < self.data.count {
//                        let value = self.data[correctedIndex]
//                        tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
//                        if let row = self.currencyAmountTable?.rowControllerAtIndex(index) as? CrownScrollTableRowController {
//                            if row.interfaceIsConfigured == false {
//                                row.configureInterface()
//                            }
//                            row.setCurrencyLabels(bigCurrency: value, littlePercentage: nil, starFlag: nil)
//                        }
//                    } else {
//                        break
//                    }
//                }
//                
//                // update instance variables
//                self.highestDataIndexInTable = newHighestNumber < self.data.count ? newHighestNumber : self.data.count - 1
//            }
//        default:
//            fatalError("CrownScrollBillInterfaceController: billTableRowInsertNumber called when currentContext was not .Bill")
//        }
//    }
    
    private func insertTableRowControllersAtBottom(newNumberOfRows: Int) {
            if let tableView = self.currencyAmountTable {
                // calculate ideal tip
                let billAmount = self.dataSource.defaultsManager.billIndexPathRow
                let suggestedTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
                let idealTip = Int(round(Double(billAmount) * suggestedTipPercentage))
                
                // update the table
                let currentNumberOfRowsInTable = tableView.numberOfRows
                let lowestNumber = self.lowestDataIndexInTable
                let highestNumber = currentNumberOfRowsInTable + newNumberOfRows + lowestNumber
                for index in currentNumberOfRowsInTable ..< currentNumberOfRowsInTable + newNumberOfRows {
                    let correctedIndex = index + self.highestDataIndexInTable - currentNumberOfRowsInTable
                    if correctedIndex < self.data.count {
                        let value = self.data[correctedIndex]
                        switch self.currentContext {
                        case .Tip:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollTipTableRowController")
                            let star = idealTip == value ? false : true
                            if let row = tableView.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface()
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                            }
                        case .Bill:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                            if let row = self.currencyAmountTable?.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface()
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: nil, starFlag: nil)
                            }
                        case .NotSet:
                            fatalError("CrownScrollBillInterfaceController: insertTableRowControllersAtBottom called when currentContext was .NotSet")
                        }
                    } else {
                        break
                    }
                }
                
                // update instance variables
                self.highestDataIndexInTable = highestNumber < self.data.count ? highestNumber : self.data.count - 1
            }
    }
    
    private func configureTableForTheFirstTime() {
        if self.interfaceControllerIsConfigured == false {
            if let tableView = self.currencyAmountTable {
                // do the math for the tip
                let billAmount = self.dataSource.defaultsManager.billIndexPathRow
                let suggestedTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
                let idealTip = Int(round(Double(billAmount) * suggestedTipPercentage))
                
                // write the ideal tip to disk for use later
                self.dataSource.defaultsManager.tipIndexPathRow = idealTip
                
                // do the math for the table
                let upperBuffer = ScrollInterfaceConstants.upperBufferWithContext(self.currentContext) !! 25
                let lowerBuffer = ScrollInterfaceConstants.lowerBufferWithContext(self.currentContext) !! 20

                var lowestNumber: Int
                var highestNumber: Int
                switch self.currentContext {
                case .Bill:
                    lowestNumber = billAmount > lowerBuffer ? billAmount - lowerBuffer - 1 : 0
                    highestNumber = billAmount + upperBuffer
                case .Tip:
                    lowestNumber = idealTip > lowerBuffer ? idealTip - lowerBuffer - 1 : 0
                    highestNumber = idealTip + upperBuffer
                case .NotSet:
                    fatalError("CrownScrollBillInterfaceController: configureTableForTheFirstTime called when currentContext was .NotSet")
                }
                
                // add the rows to the table
                for index in 0 ..< highestNumber - lowestNumber {
                    let correctedIndex = index + lowestNumber
                    if correctedIndex < self.data.count {
                        let value = self.data[correctedIndex]
                        switch self.currentContext {
                        case .Tip:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollTipTableRowController")
                            let star = idealTip == value ? false : true
                            if let row = tableView.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface()
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                            }
                        case .Bill:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                            if let row = self.currencyAmountTable?.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface()
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: nil, starFlag: nil)
                            }
                        case .NotSet:
                            fatalError("CrownScrollBillInterfaceController: configureTableForTheFirstTime called when currentContext was .NotSet")

                        }
                    }
                }
                // update instance variables
                self.lowestDataIndexInTable = lowestNumber > 0 ? lowestNumber : 0
                self.highestDataIndexInTable = highestNumber < self.data.count ? highestNumber : self.data.count - 1
            }
        }
    }
    
    private func clearDataTable() {
        self.currencyAmountTable?.setNumberOfRows(0, withRowType: "BillAmountTableRowController")
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let adjustedIndex = rowIndex + self.lowestDataIndexInTable
        let currencyAmount = self.data[adjustedIndex]
        println("DidSelectRowIndex \(rowIndex), Adjusted Index \(adjustedIndex), Currency Amount: \(currencyAmount)")
        switch self.currentContext {
        case .Bill:
            self.dataSource.defaultsManager.billIndexPathRow = currencyAmount
            self.pushControllerWithName("CrownScrollTipInterfaceController", context: CrownScrollerInterfaceContext.Tip.rawValue)
        case .Tip:
            self.dataSource.defaultsManager.tipIndexPathRow = currencyAmount
            self.pushControllerWithName("TotalAmountInterfaceController", context: nil)
        default:
            fatalError("CrownScrollBillInterfaceController: didSelectRowAtIndex called when currentContext was .NotSet")
        }
    }
    
    @IBAction func didTapSmallerAmountButton() {
        switch self.currentContext {
        case .Bill:
            self.insertTableRowControllersAtTop(30)
        case .Tip:
            self.insertTableRowControllersAtTop(10)
        case .NotSet:
            break
        }
    }
    
    
    @IBAction private func didTapLargerAmountButton() {
        switch self.currentContext {
        case .Bill:
            self.insertTableRowControllersAtBottom(30)
        case .Tip:
            self.insertTableRowControllersAtBottom(10)
        case .NotSet:
            break
        }
    }
    
    private struct ScrollInterfaceConstants {
        static let dataMax = 999
        static let dataMin = 0
        
        static func upperBufferWithContext(currentContext: CrownScrollerInterfaceContext) -> Int? {
            switch currentContext {
            case .Bill:
                return 25
            case .Tip:
                return 6
            case .NotSet:
                return nil
            }
        }
        
        static func lowerBufferWithContext(currentContext: CrownScrollerInterfaceContext) -> Int? {
            switch currentContext {
            case .Bill:
                return 20
            case .Tip:
                return 3
            case .NotSet:
                return nil
            }
        }
    }
}
