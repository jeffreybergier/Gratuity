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
    @IBOutlet private weak var loadingImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    @IBOutlet private weak var largerButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var largerButtonLabel: WKInterfaceLabel?
    
    private var data = [Int]()
    private var currentContext = InterfaceControllerContext.NotSet
    private var interfaceControllerIsConfigured = false
    private var idealTipIndex = 0
    
    private let tipOffset = 5
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    private let largerButtonTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Headline)]
    
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
        dispatch_async(dispatch_get_main_queue()) {
            switch self.currentContext {
            case .CrownScrollTipChooser:
                self.setTitle(NSLocalizedString("Tip Amount", comment: ""))
                self.instructionalTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Scroll to the choose your desired Tip Amount", comment: ""), attributes: self.titleTextAttributes))
                self.instructionalTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
                
                let billAmount = self.dataSource.billAmount !! 0
                let suggestedTipPercentage = self.dataSource.tipPercentage !! 0.2
                let tipAmount = Int(round(Double(billAmount) * suggestedTipPercentage))
                
                var cellBeginIndex: Int
                //let cellBeginIndex: Int
                if tipAmount >= self.tipOffset {
                    cellBeginIndex = tipAmount - self.tipOffset
                    self.idealTipIndex = 6
                } else {
                    cellBeginIndex = tipAmount
                    self.idealTipIndex = 0
                }
                let numberOfRowsInTable = cellBeginIndex + self.tipOffset * 3
                
                self.data = []
                for index in cellBeginIndex ..< numberOfRowsInTable {
                    self.data.append(index)
                }
                
                self.reloadTipTableData(idealTip: tipAmount, billAmount: billAmount)
            default:
                break
            }
            
            // set the text
            self.largerButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Larger", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // set colors
            self.largerButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.largerButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            
            // show the view
            self.loadingImageGroup?.setHidden(true)
            self.largerButtonGroup?.setHidden(false)
            self.instructionalTextLabel?.setHidden(false)
            self.tipAmountTable?.setHidden(false)
            self.interfaceControllerIsConfigured = true
            let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "scrollToCorrectRowIfNeeded:", userInfo: nil, repeats: false)
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
    
    @objc private func scrollToCorrectRowIfNeeded(timer: NSTimer?) {
        timer?.invalidate()
        if self.dataSource.watchAppRunCount > 3 {
            if self.idealTipIndex > 0 {
                let tableIndex = self.idealTipIndex - 1
                self.tipAmountTable?.scrollToRowAtIndex(tableIndex)
            }
        }
    }
    
    @IBAction private func didTapLargerAmountButton() {
        if let numberOfRows = self.tipAmountTable?.numberOfRows {
            if let highestTipAmount = self.data.last {
                self.dataSource.tipAmount = highestTipAmount
            }
        }
        self.pushControllerWithName("ThreeButtonStepperTipInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperTip.rawValue)
    }
    
}
