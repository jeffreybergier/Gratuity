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
    
    @IBOutlet weak var billAmountLabel: WKInterfaceLabel!
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel!
    @IBOutlet weak var tipPercentageLabel: WKInterfaceLabel!
    @IBOutlet weak var totalAmountLabel: WKInterfaceLabel!
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
    }
    
    @IBAction func tipAmountDidChange(value: AnyObject) {
        if let floatValue = value as? Float {
            //update the data source
            self.dataSource.tipAmount = floatValue * 100
            
            //update the text
            self.tipAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.tipAmount))
            self.tipPercentageLabel.setText(self.dataSource.percentStringFromFloat(self.dataSource.tipPercentage * 100))
            self.totalAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount + self.dataSource.tipAmount))
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.billAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount))
        self.tipAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.tipAmount))
        self.tipPercentageLabel.setText(self.dataSource.percentStringFromFloat(self.dataSource.tipPercentage * 100))
        self.totalAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount + self.dataSource.tipAmount))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
   
}
