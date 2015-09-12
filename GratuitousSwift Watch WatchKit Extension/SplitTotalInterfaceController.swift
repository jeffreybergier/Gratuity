//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SplitTotalInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var totalAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var totalAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var splitAmount1CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount1IconLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2IconLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3IconLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var totalAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var splitAmountGroup: WKInterfaceGroup?

    private var interfaceControllerIsConfigured = false
    private var currencySymbolDidChangeWhileAway = false
    
    private let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    private var totalAmount = 0
    private var tipAmount = 0
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
                self.tipAmount = tipAmount
            }
        }
    }
    
    struct Context {
        var totalAmount: Int
        var tipAmount: Int
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
        
        // if the currency symbol changed while this controller was not visible, we now need to update the rows
        // this is needed because updates to the UI won't be sent if they are not visible
        if self.currencySymbolDidChangeWhileAway == true {
            self.configureValueLabels()
            self.currencySymbolDidChangeWhileAway = false
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            // set the static text of the labels
            self.tipAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Tip Amount", comment: ""), attributes: self.subtitleTextAttributes))
            self.totalAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Total Amount", comment: ""), attributes: self.subtitleTextAttributes))
            
            // configure the values 
            self.configureValueLabels()
            
            // interface is now configured
            self.interfaceControllerIsConfigured = true
            
            // unhide split amount of its been purchased
            //if self.dataSource.defaultsManager.splitTipFeatureUnlocked == true {
                self.configureSplitAmountLabels()
                self.splitAmountGroup?.setHidden(false)
            //}
            
            // unhide everything
            self.totalAmountGroup?.setHidden(false)
            self.tipAmountGroup?.setHidden(false)
        }
    }
    
    private func configureValueLabels() {
        // prepare attributed text from data
        let tipAmountString = NSAttributedString(string: self.dataSource!.currencyStringFromInteger(self.tipAmount), attributes: self.valueTextAttributes)
        let totalAmountString = NSAttributedString(string: self.dataSource!.currencyStringFromInteger(self.totalAmount), attributes: self.valueTextAttributes)
        
        // populate labels with data
        self.tipAmountLabel?.setAttributedText(tipAmountString)
        self.totalAmountLabel?.setAttributedText(totalAmountString)
    }
    
    private func configureSplitAmountLabels() {
        // do the math
        let two = Int(round(Double(totalAmount) / 2))
        let three = Int(round(Double(totalAmount) / 3))
        let four = Int(round(Double(totalAmount) / 4))
        
        // prepare the attributed text
        let oneString = NSAttributedString(string: self.dataSource!.currencyStringFromInteger(two), attributes: self.valueTextAttributes)
        let twoString = NSAttributedString(string: self.dataSource!.currencyStringFromInteger(three), attributes: self.valueTextAttributes)
        let threeString = NSAttributedString(string: self.dataSource!.currencyStringFromInteger(four), attributes: self.valueTextAttributes)
        
        // populate the labels
        self.splitAmount1CurrencyLabel?.setAttributedText(oneString)
        self.splitAmount2CurrencyLabel?.setAttributedText(twoString)
        self.splitAmount3CurrencyLabel?.setAttributedText(threeString)

    }
}
