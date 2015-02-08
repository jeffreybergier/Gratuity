//
//  TipAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation

class TipAmountInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private weak var totalAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountSlider: WKInterfaceSlider?
    @IBOutlet weak var suggestedTipTitleLabel: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    @IBAction func tipAmountDidChange(value: Float) {
        // update the data source
        self.dataSource.tipAmount = value * 100
        
        // get the current values from the data source
        let currentTipAmount = self.dataSource.tipAmount
        let currentTipPercentage = self.dataSource.tipPercentage!
        let currentBillAmount = self.dataSource.billAmount
        let currentTotalAmount = self.dataSource.totalAmount
        
        // update the text
        self.suggestedTipTitleLabel?.setText(NSLocalizedString("Desired Tip", comment: "This text is when the user is manually selecting a tip. It should say that its a tip he overrode from the suggested tip."))
        self.tipAmountLabel?.setText(self.dataSource.dollarStringFromFloat(currentTipAmount))
        self.tipPercentageLabel?.setText(self.dataSource.percentStringFromFloat(currentTipPercentage * 100))
        self.totalAmountLabel?.setText(self.dataSource.dollarStringFromFloat(currentTotalAmount))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // get the current values from the data source
        let currentTipAmount = self.dataSource.tipAmount!
        let currentTipPercentage = self.dataSource.tipPercentage!
        let currentBillAmount = self.dataSource.billAmount
        let currentTotalAmount = self.dataSource.totalAmount
        
        self.billAmountLabel?.setText(self.dataSource.dollarStringFromFloat(currentBillAmount))
        self.tipAmountLabel?.setText(self.dataSource.dollarStringFromFloat(currentTipAmount))
        self.tipPercentageLabel?.setText(self.dataSource.percentStringFromFloat(currentTipPercentage * 100))
        self.totalAmountLabel?.setText(self.dataSource.dollarStringFromFloat(currentTotalAmount))
        self.tipAmountSlider?.setValue(currentTipAmount / 100)
    }
}
