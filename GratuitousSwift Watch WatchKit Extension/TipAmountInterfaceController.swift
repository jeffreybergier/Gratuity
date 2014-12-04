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
    
    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
    }
    
    /*@IBAction*/ func tipAmountDidChange(value: Float) {
        //update the data source
        self.dataSource.tipAmount = value * 100
        
        //update the text
        self.suggestedTipTitleLabel?.setText(NSLocalizedString("Desired Tip", comment: "This text is when the user is manually selecting a tip. It should say that its a tip he overrode from the suggested tip."))
        self.tipAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.tipAmount))
        self.tipPercentageLabel?.setText(self.dataSource.percentStringFromFloat(self.dataSource.tipPercentage * 100))
        self.totalAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount + self.dataSource.tipAmount))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.billAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount))
        self.tipAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.tipAmount))
        self.tipPercentageLabel?.setText(self.dataSource.percentStringFromFloat(self.dataSource.tipPercentage * 100))
        self.totalAmountLabel?.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount + self.dataSource.tipAmount))
        self.tipAmountSlider?.setValue(self.dataSource.tipAmount / 100)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
   
}
