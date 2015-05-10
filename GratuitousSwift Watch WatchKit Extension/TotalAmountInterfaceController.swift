//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class TotalAmountInterfaceController: GratuitousMenuInterfaceController {
    
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private weak var totalAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var totalAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var splitAmount0CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount0IconLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount1CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount1IconLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount2IconLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3CurrencyLabel: WKInterfaceLabel?
    @IBOutlet private weak var splitAmount3IconLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var startOverButtonLabel: WKInterfaceLabel?
    @IBOutlet private weak var backgroundImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var totalAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipPercentageGroup: WKInterfaceGroup?
    @IBOutlet private weak var startOverButtonGroup: WKInterfaceGroup?
    @IBOutlet private weak var splitAmountGroup: WKInterfaceGroup?
    
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private var dataSource = GratuitousWatchDataSource.sharedInstance
    private var interfaceControllerIsConfigured = false
    private var currencySymbolDidChangeWhileAway = false
    
    private let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            self.animationImageView?.setImageNamed("gratuityCap4-")
            self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
            
            self.setTitle(NSLocalizedString("Total Amount", comment: ""))
            
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
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
            // register for notifications from the settings screen
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySymbolDidChangeInSettings:", name: WatchNotification.CurrencySymbolDidChangeInSettings, object: nil)
            
            // set the static text of the labels
            self.tipPercentageTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Percentage", comment: ""), attributes: self.subtitleTextAttributes))
            self.tipAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Tip Amount", comment: ""), attributes: self.subtitleTextAttributes))
            self.totalAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Total Amount", comment: ""), attributes: self.subtitleTextAttributes))
            self.startOverButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Start Over", comment: ""), attributes: self.largerButtonTextAttributes))
            
            // configure the values 
            self.configureValueLabels()
            
            // interface is now configured
            self.interfaceControllerIsConfigured = true
            
            // unhide everything
            self.backgroundImageGroup?.setHidden(true)
            self.totalAmountGroup?.setHidden(false)
            self.tipAmountGroup?.setHidden(false)
            self.tipPercentageGroup?.setHidden(false)
            self.startOverButtonGroup?.setHidden(false)
        }
    }
    
    private func configureValueLabels() {
        // prepare data
        let billAmount = self.dataSource.defaultsManager.billIndexPathRow
        let tipAmount = self.dataSource.defaultsManager.tipIndexPathRow
        let tipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        
        // prepare attributed text from data
        let tipPercentageString = NSAttributedString(string: self.dataSource.percentStringFromRawDouble(tipPercentage), attributes: self.valueTextAttributes)
        let tipAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount), attributes: self.valueTextAttributes)
        let totalAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount + billAmount), attributes: self.valueTextAttributes)
        let billAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(billAmount), attributes: self.valueTextAttributes)
        
        // populate labels with data
        self.tipPercentageLabel?.setAttributedText(tipPercentageString)
        self.tipAmountLabel?.setAttributedText(tipAmountString)
        self.totalAmountLabel?.setAttributedText(totalAmountString)
    }
    
    @objc private func currencySymbolDidChangeInSettings(notification: NSNotification) {
        self.currencySymbolDidChangeWhileAway = true
    }
    
    @IBAction func didTapStartOverButton() {
        self.popToRootController()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
