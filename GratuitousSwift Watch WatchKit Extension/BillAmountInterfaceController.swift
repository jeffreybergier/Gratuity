//
//  BillAmountInterfaceController.swift
//  Gratuityλ WatchKit Extension
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation


class BillAmountInterfaceController: WKInterfaceController {

    @IBOutlet private weak var billAmountLabel: WKInterfaceLabel!
    @IBOutlet private weak var billAmountSlider: WKInterfaceSlider!
    @IBOutlet private weak var billAmountNextButton: WKInterfaceButton!
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    @IBAction func didChangeBillAmountSliderValue(value: Float) {
        self.dataSource.billAmount = Int(round(value * 100))
        self.billAmountLabel.setText(self.dataSource.currencyStringFromInteger(Int(round(value * 100.0))))
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //load the bill amount from the data source and populate the label
        let currentBillAmount = self.dataSource.billAmount
        self.billAmountLabel.setText(self.dataSource.currencyStringFromInteger(currentBillAmount))
        if let currentBillAmount = currentBillAmount {
            self.billAmountSlider.setValue(Float(currentBillAmount) / 100)
        }
    }
}
