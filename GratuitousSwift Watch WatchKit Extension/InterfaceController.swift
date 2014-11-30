//
//  BillAmountInterfaceController.swift
//  Gratuityλ WatchKit Extension
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet private weak var billAmountLabel: WKInterfaceLabel!
    @IBOutlet private weak var billAmountSlider: WKInterfaceSlider!
    @IBOutlet private weak var billAmountNextButton: WKInterfaceButton!
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override init(context: AnyObject?) {
        // Initialize variables here.
        super.init(context: context)
    }
    
    @IBAction func didChangeBillAmountSliderValue(value: AnyObject) {
        self.dataSource.billAmount = value as Float * 100
        self.billAmountLabel.setText(self.dataSource.dollarStringFromFloat(value as Float * 100))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //load the bill amount from the data source and populate the label
        self.billAmountLabel.setText(self.dataSource.dollarStringFromFloat(self.dataSource.billAmount))
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
}
