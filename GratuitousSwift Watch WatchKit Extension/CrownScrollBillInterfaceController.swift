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
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    @IBOutlet private weak var largerButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var largerButtonLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private var data = [Int]()
    private var cellValueMultiplier = 1
    private var currentContext: InterfaceControllerContext = .NotSet
    
    private var interfaceControllerIsConfigured = false
    
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    private let largerButtonTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Headline)]
    
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
        
        // variables needed for UI changes at the end
        var localizedTitled: String
        var instructionalText: NSAttributedString
        var numberOfRowsInTable: Int
        var cellBeginIndex: Int
        var cellValueMultiplier: Int
        //let numberOfRowsInTable: Int
        //let cellBeginIndex: Int
        switch self.currentContext {
        case .CrownScrollInfinite:
            localizedTitled = NSLocalizedString("Bill Amount", comment: "")
            instructionalText = NSAttributedString(string: NSLocalizedString("Scroll to choose the Bill Amount", comment: ""), attributes: self.titleTextAttributes)
            cellBeginIndex = 1
            numberOfRowsInTable = self.dataSource.numberOfRowsInBillTableForWatch
            cellValueMultiplier = 1
        case .CrownScrollPagedOnes:
            localizedTitled = NSLocalizedString("Refine Bill", comment: "")
            instructionalText = NSAttributedString(string: NSLocalizedString("Scroll to refine the Bill Amount", comment: ""), attributes: self.titleTextAttributes)
            let billAmount = self.dataSource.billAmount !! 0
            let offset = 3
            cellBeginIndex = billAmount >= offset ? billAmount - offset : billAmount
            numberOfRowsInTable = billAmount + 10
            cellValueMultiplier = 1
        case .CrownScrollPagedTens:
            localizedTitled = NSLocalizedString("Bill Amount", comment: "")
            instructionalText = NSAttributedString(string: NSLocalizedString("Scroll to the number closest to the Bill Amount", comment: ""), attributes: self.titleTextAttributes)
            cellBeginIndex = 1
            numberOfRowsInTable = 50
            cellValueMultiplier = 10
        default:
            fatalError("CrownScrollBillInterfaceController: Context not set")
        }
        
        // prepare the tables
        self.cellValueMultiplier = cellValueMultiplier
        self.data = []
        for index in cellBeginIndex ..< numberOfRowsInTable {
            self.data.append(index)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            // set the text
            self.setTitle(localizedTitled)
            self.instructionalTextLabel?.setAttributedText(instructionalText)
            self.largerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Larger", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set colors
            self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.largerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.largerButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            // configure the tables
            self.clearBillDataTable() // not sure if it is safe to call these on background thread
            self.reloadBillTableData()
            
            // show the UI
            self.loadingImageGroup?.setHidden(true)
            self.largerButtonGroup?.setHidden(false)
            self.instructionalTextLabel?.setHidden(false)
            self.billAmountTable?.setHidden(false)
            self.interfaceControllerIsConfigured = true
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "scrollToCorrectRowIfNeeded:", userInfo: nil, repeats: false) // this fixes a bug where scrolling didn't work properly
        }
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
    
    @objc private func scrollToCorrectRowIfNeeded(timer: NSTimer?) {
        timer?.invalidate()
        if self.dataSource.watchAppRunCount > 3 {
            let billAmount = self.dataSource.billAmount
            if self.cellValueMultiplier > 0 {
                self.instructionalTextLabel?.setHidden(true)
                let tableIndex = Int(round(Float(billAmount) / Float(self.cellValueMultiplier))) + 1
                self.billAmountTable?.scrollToRowAtIndex(tableIndex)
            }
        }
    }
    
    @IBAction private func didTapLargerAmountButton() {
        println("did tap larger amount button in bill view")
    }
    
}
