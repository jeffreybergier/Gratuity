//
//  CrownScrollInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollBillInterfaceController: GratuitousMenuInterfaceController {
    
    @IBOutlet private weak var instructionalTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountTable: WKInterfaceTable?
    @IBOutlet private weak var loadingImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    @IBOutlet private weak var largerButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var largerButtonLabel: WKInterfaceLabel?
    
    private var data = [Int]()
    private var cellValueMultiplier = 1
    private var currentContext = CrownScrollerInterfaceContext.NotSet
    private var billAmountOffset: Int? // This property is only set when context is CrownScrollPagedOnes
    private var interfaceControllerIsConfigured = false
    
    private var numberOfRowsLoadedAlready = 0
    
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
            self.setTitle(NSLocalizedString("Bill Amount", comment: ""))
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
        
        // variables needed for UI changes at the end
        var localizedTitle: String?
        var instructionalText: NSAttributedString
        var numberOfRowsInTable: Int
        var cellBeginIndex: Int
        var cellValueMultiplier: Int
        //let numberOfRowsInTable: Int
        //let cellBeginIndex: Int
        //switch self.currentContext {
        //case .Bill:
            //localizedTitle = NSLocalizedString("Bill Amount", comment: "")
            instructionalText = NSAttributedString(string: NSLocalizedString("Scroll to choose the Bill Amount", comment: ""), attributes: self.titleTextAttributes)
            cellBeginIndex = 1
            numberOfRowsInTable = self.dataSource.numberOfRowsInBillTableForWatch
            cellValueMultiplier = 1
        //case .Tip:
            //break
        //default:
            //fatalError("CrownScrollBillInterfaceController: Context not set")
        //}
        
        // prepare the tables
        self.cellValueMultiplier = cellValueMultiplier
        self.data = []
        for index in cellBeginIndex ..< numberOfRowsInTable {
            self.data.append(index)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            // set the text
            if let localizedTitle = localizedTitle {
                self.setTitle(localizedTitle) // causes the title to flicker when its set outside of willactivate
            }
            self.instructionalTextLabel?.setAttributedText(instructionalText)
            self.largerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Larger", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set colors
            self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.largerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.largerButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            // configure the tables
            self.clearBillDataTable() // not sure if it is safe to call these on background thread
            self.tableRowInsertNumber(100)
            
            // show the UI
            self.largerButtonGroup?.setHidden(false)
            self.instructionalTextLabel?.setHidden(false)
            self.billAmountTable?.setHidden(false)
            self.loadingImageGroup?.setHidden(true)
            self.interfaceControllerIsConfigured = true
            
            //NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "scrollToCorrectRowIfNeeded:", userInfo: nil, repeats: false) // this fixes a bug where scrolling didn't work properly
        }
    }
    
    @objc private func tableRowInsertNumber(newNumberOfRows: Int) {
        let range = NSRange(location: self.numberOfRowsLoadedAlready, length: self.numberOfRowsLoadedAlready + newNumberOfRows)
        
        for index in self.numberOfRowsLoadedAlready ..< newNumberOfRows + self.numberOfRowsLoadedAlready {
            if index < self.data.count {
                self.billAmountTable?.insertRowsAtIndexes(NSIndexSet(index: index), withRowType: "CrownScrollBillTableRowController")
                if let row = self.billAmountTable?.rowControllerAtIndex(index) as? CrownScrollBillTableRowController {
                    if row.interfaceIsConfigured == false {
                        row.configureInterface()
                    }
                    let value = self.data[index]
                    row.updateCurrencyAmountLabel(value * self.cellValueMultiplier)
                }
            } else {
                break
            }
        }
        
        self.numberOfRowsLoadedAlready += newNumberOfRows
    }
    
    private func clearBillDataTable() {
        self.billAmountTable?.setNumberOfRows(0, withRowType: "BillAmountTableRowController")
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let newBillAmount = self.data[rowIndex] * self.cellValueMultiplier
        self.dataSource.billAmount = newBillAmount
        
        var nextContext: CrownScrollerInterfaceContext?
        //let nextContext: CrownScrollerInterfaceContext
        switch self.currentContext {
        case .Bill:
            nextContext = .Tip
        case .Tip:
            break
        default:
            break
        }
        
        if let nextContext = nextContext {
            switch nextContext {
            case .Tip:
                self.pushControllerWithName("CrownScrollTipInterfaceController", context: nextContext.rawValue)
            default:
                break
            }
        } else {
            self.pushControllerWithName("TotalAmountInterfaceController", context: nil)
        }
    }
    
    @objc private func scrollToCorrectRowIfNeeded(timer: NSTimer?) {
        timer?.invalidate()
        if self.dataSource.watchAppRunCount > 1 {
            let billAmount = self.dataSource.billAmount
            switch self.currentContext {
            case .Bill:
                if let offset = self.billAmountOffset {
                    let tableIndex = billAmount - offset
                    self.billAmountTable?.scrollToRowAtIndex(tableIndex)
                    break
                }
//            case .CrownScrollPagedTens:
//                fallthrough
//            case .CrownScrollInfinite:
//                if let division = GratuitousWatchDataSource.optionalDivision(top: Double(billAmount), bottom: Double(self.cellValueMultiplier)) {
//                    let tableIndex = Int(round(division)) - 1
//                    if let numberOfRows = self.billAmountTable?.numberOfRows {
//                        if numberOfRows > tableIndex {
//                            self.billAmountTable?.scrollToRowAtIndex(tableIndex)
//                        } else {
//                            self.billAmountTable?.scrollToRowAtIndex(numberOfRows - 1)
//                        }
//                    }
//                }
            default:
                fatalError("CrownScrollBillInterfaceController: Invalid context found when attempting to scroll to desired row.")
            }
        }
    }
    
    @IBAction private func didTapLargerAmountButton() {
        if let numberOfRows = self.billAmountTable?.numberOfRows {
            if let highestBillAmount = self.data.last {
                self.dataSource.billAmount = highestBillAmount * self.cellValueMultiplier//numberOfRows * self.cellValueMultiplier
            }
        }
        self.tableRowInsertNumber(30)
        //self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
    }
}
