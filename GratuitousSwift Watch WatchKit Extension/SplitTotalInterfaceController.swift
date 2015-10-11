//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

final class SplitTotalInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var splitAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var splitAmount0CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount1CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount4CurrencyLabel: WKInterfaceLabel?
    
    private var interfaceControllerIsConfigured = false
    
    private let titleTextAttribute = GratuitousUIColor.WatchFonts.titleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.splitBillValueText
    
    private var totalAmount = 0
    private var dataSource: GratuitousWatchDataSource? {
        didSet {
            if let dataSource = dataSource {
                let billAmount = dataSource.defaultsManager.billIndexPathRow
                let tipAmount: Int
                if dataSource.defaultsManager.tipIndexPathRow != 0 {
                    tipAmount = dataSource.defaultsManager.tipIndexPathRow
                } else {
                    tipAmount = Int(round(dataSource.defaultsManager.suggestedTipPercentage * Double(billAmount)))
                }
                let totalAmount = billAmount + tipAmount
                
                self.totalAmount = totalAmount
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let dataSource = context as? GratuitousWatchDataSource {
            self.dataSource = dataSource
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            // interface is now configured
            self.interfaceControllerIsConfigured = true
            
            self.setTitle(SplitTotalInterfaceController.LocalizedString.CloseSplitBillTitle)
            let titleString = NSAttributedString(string: SplitTotalInterfaceController.LocalizedString.SplitBillTitleLabel, attributes: self.titleTextAttribute)
            self.splitAmountTitleLabel?.setAttributedText(titleString)
            self.configureSplitAmountLabels()
        }
    }
    
    private func configureSplitAmountLabels() {
        guard let dataSource = self.dataSource else { return }
        
        // do the math
        let zero = self.totalAmount
        let one = Int(round(Double(self.totalAmount) / 2))
        let two = Int(round(Double(self.totalAmount) / 3))
        let three = Int(round(Double(self.totalAmount) / 4))
        let four = Int(round(Double(self.totalAmount) / 5))
        
        // prepare the attributed text
        let zeroString = NSAttributedString(string: dataSource.currencyStringFromInteger(zero), attributes: self.valueTextAttributes)
        let oneString = NSAttributedString(string: dataSource.currencyStringFromInteger(one), attributes: self.valueTextAttributes)
        let twoString = NSAttributedString(string: dataSource.currencyStringFromInteger(two), attributes: self.valueTextAttributes)
        let threeString = NSAttributedString(string: dataSource.currencyStringFromInteger(three), attributes: self.valueTextAttributes)
        let fourString = NSAttributedString(string: dataSource.currencyStringFromInteger(four), attributes: self.valueTextAttributes)
        
        // populate the labels
        self.splitAmount0CurrencyLabel?.setAttributedText(zeroString)
        self.splitAmount1CurrencyLabel?.setAttributedText(oneString)
        self.splitAmount2CurrencyLabel?.setAttributedText(twoString)
        self.splitAmount3CurrencyLabel?.setAttributedText(threeString)
        self.splitAmount4CurrencyLabel?.setAttributedText(fourString)

    }
}
