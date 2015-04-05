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
        for index in ScrollInterfaceConstants.dataMin ..< ScrollInterfaceConstants.dataMax {
            array.append(index)
        }
        return array
        }()
    private(set) var currentContext = CrownScrollerInterfaceContext.NotSet
    private var billAmountOffset: Int? // This property is only set when context is CrownScrollPagedOnes
    private var interfaceControllerIsConfigured = false
    private var currencySymbolDidChangeWhileAway = false
    private var highestDataIndexInTable: Int = 0 {
        didSet {
            if self.highestDataIndexInTable >= self.data.count - 1 {
                self.largerButtonGroup?.setHidden(true)
            }
            //println("highestDataIndexInTable: \(self.highestDataIndexInTable)")
            //println("highestValueFromArray: \(self.data[self.highestDataIndexInTable])")
        }
    }
    private var lowestDataIndexInTable: Int = 0 {
        didSet {
            if self.lowestDataIndexInTable <= 0 {
                self.smallerButtonGroup?.setHidden(true)
            }
            
            //println("lowestDataIndexInTable: \(self.lowestDataIndexInTable)")
            //println("lowestValueFromArray: \(self.data[self.lowestDataIndexInTable])")
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
        
        if self.interfaceControllerIsConfigured == false {
            
            self.animationImageView?.setImageNamed("gratuityCap4-")
            self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
            
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
        
        // if the currency symbol changed while this controller was not visible, we now need to update the rows
        // this is needed because updates to the UI won't be sent if they are not visible
        if self.currencySymbolDidChangeWhileAway == true {
            NSNotificationCenter.defaultCenter().postNotificationName(WatchNotification.CurrencySymbolShouldUpdate, object: self)
            self.currencySymbolDidChangeWhileAway = false
        }
    }
    
    private func configureInterfaceController() {
        //
        // This is always executed on a background queue
        // All UI changes must be done at the end
        // All UI changes must call back to the main queue
        //
        dispatch_async(dispatch_get_main_queue()) {
            // clear the table of storyboard cruft
            self.clearDataTable()
            
            // register for notifications from the settings screen
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySymbolDidChangeInSettings:", name: WatchNotification.CurrencySymbolDidChangeInSettings, object: nil)
            
            // set the text
            self.largerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Larger", comment: ""), attributes: self.largerButtonTextAttributes))
            self.smallerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Smaller", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set colors
            self.largerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.smallerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            
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
        //println("Scroll to Currency: \(currencyAmountToScrollTo), IndexPath: \(rowIndexPath)")
        
        if rowIndexPath > 0 && rowIndexPath < self.currencyAmountTable?.numberOfRows {
            self.currencyAmountTable?.scrollToRowAtIndex(rowIndexPath)
        }
    }
    
    @objc private func currencySymbolDidChangeInSettings(notification: NSNotification) {
        self.currencySymbolDidChangeWhileAway = true
    }
    
    private func insertTableRowControllersAtTop(newNumberOfRows: Int) {
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
                            row.configureInterface(parentInterfaceController: self)
                        }
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
                            row.configureInterface(parentInterfaceController: self)
                        }
                        row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                    }
                default:
                    fatalError("CrownScrollBillInterfaceController: insertAmountTableRowControllersAtTop called when currentContext was not .NotSet")
                }
            }
            // update instance variables
            self.lowestDataIndexInTable = newLowestDataIndex
        }
    }
    
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
                                    row.configureInterface(parentInterfaceController: self)
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                            }
                        case .Bill:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                            if let row = self.currencyAmountTable?.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface(parentInterfaceController: self)
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
                
                var idealCurrencyAmount: Int
                switch self.currentContext {
                case .Bill:
                    idealCurrencyAmount = billAmount
                case .Tip:
                    idealCurrencyAmount = idealTip
                case .NotSet:
                    fatalError("CrownScrollBillInterfaceController: configureTableForTheFirstTime called when currentContext was .NotSet")
                }
                
                // configure the buffers
                let upperBuffer = ScrollInterfaceConstants.upperBufferWithContext(self.currentContext) !! 25
                let lowerBuffer = ScrollInterfaceConstants.lowerBufferWithContext(self.currentContext) !! 20
                
                if idealCurrencyAmount > self.data.count {
                    idealCurrencyAmount = self.data.count - 1 - upperBuffer
                }
                
                // write the ideal tip to disk for use later
                self.dataSource.defaultsManager.tipIndexPathRow = idealTip
                
                // do the math for the table
                let lowestNumber = idealCurrencyAmount > lowerBuffer ? idealCurrencyAmount - lowerBuffer : 0
                let highestNumber = idealCurrencyAmount + upperBuffer + 1
                
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
                                    row.configureInterface(parentInterfaceController: self)
                                }
                                row.setCurrencyLabels(bigCurrency: value, littlePercentage: GratuitousWatchDataSource.optionalDivision(top: Double(value), bottom: Double(billAmount)), starFlag: star)
                            }
                        case .Bill:
                            tableView.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                            if let row = self.currencyAmountTable?.rowControllerAtIndex(index) as? CrownScrollTableRowController {
                                if row.interfaceIsConfigured == false {
                                    row.configureInterface(parentInterfaceController: self)
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
        //println("DidSelectRowIndex \(rowIndex), Adjusted Index \(adjustedIndex), Currency Amount: \(currencyAmount)")
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
        //println("\(self.numberOfRowsToAdd(buttonType: .SmallerButton)) Rows added to Top")
        switch self.currentContext {
        case .Bill:
            self.insertTableRowControllersAtTop(self.numberOfRowsToAdd(buttonType: .SmallerButton))
        case .Tip:
            self.insertTableRowControllersAtTop(self.numberOfRowsToAdd(buttonType: .SmallerButton))
        case .NotSet:
            break
        }
    }
    
    
    @IBAction private func didTapLargerAmountButton() {
        //println("\(self.numberOfRowsToAdd(buttonType: .LargerButton)) Rows added to Bottom")
        switch self.currentContext {
        case .Bill:
            self.insertTableRowControllersAtBottom(self.numberOfRowsToAdd(buttonType: .LargerButton))
        case .Tip:
            self.insertTableRowControllersAtBottom(self.numberOfRowsToAdd(buttonType: .LargerButton))
        case .NotSet:
            break
        }
    }
    
    private func numberOfRowsToAdd(#buttonType: ScrollInterfaceConstants.ButtonTapped) -> Int {
        switch self.currentContext {
        case .Bill:
            switch buttonType {
            case .LargerButton:
                switch self.highestDataIndexInTable {
                case 50 ..< 100:
                    return 50
                case 100 ..< 500:
                    return 75
                case 500 ..< 1000:
                    return 200
                case 1000 ..< Int.max:
                    return 300
                default: // Int.min ..< 50
                    return 25
                }
            case .SmallerButton:
                switch self.lowestDataIndexInTable {
                case 50 ..< 100:
                    return 25
                case 100 ..< 500:
                    return 65
                case 500 ..< 1000:
                    return 150
                case 1000 ..< Int.max:
                    return 200
                default: // Int.min ..< 50
                    return 15
                }
            }
        case .Tip:
            switch buttonType {
            case .LargerButton:
                switch self.highestDataIndexInTable {
                case 50 ..< 100:
                    return 25
                case 100 ..< 500:
                    return 45
                case 500 ..< 1000:
                    return 75
                case 1000 ..< Int.max:
                    return 150
                default: // Int.min ..< 50
                    return 15
                }
            case .SmallerButton:
                switch self.lowestDataIndexInTable {
                case 50 ..< 100:
                    return 15
                case 100 ..< 500:
                    return 25
                case 500 ..< 1000:
                    return 75
                case 1000 ..< Int.max:
                    return 150
                default: // Int.min ..< 50
                    return 10
                }
            }
        case .NotSet:
            fatalError("CrownScrollBillInterfaceController: numberOfRowsToAdd called when currentContext was .NotSet")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private struct ScrollInterfaceConstants {
        static let dataMax = 2001
        static let dataMin = 0
        
        enum ButtonTapped {
            case LargerButton, SmallerButton
        }
        
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
