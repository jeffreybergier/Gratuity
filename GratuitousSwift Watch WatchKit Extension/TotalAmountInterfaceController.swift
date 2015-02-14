//
//  TotalAmountInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class TotalAmountInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private weak var totalAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountLabel: WKInterfaceLabel?
    private var currentContext = InterfaceControllerContext.NotSet
    private var dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.TotalAmountInterfaceController
        } else {
            currentContext = Optional.None !! InterfaceControllerContext.TotalAmountInterfaceController
        }
        
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.tipPercentageLabel?.setText("– %")
        self.tipAmountLabel?.setText("$ –")
        self.totalAmountLabel?.setText("$ –")
        self.billAmountLabel?.setText("$ –")
        
        let billAmount = self.dataSource.billAmount !! 0
        let tipAmount = self.dataSource.tipAmount !! 0
        let tipPercentage = self.dataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount)) !! 0.2
        let tipPercentageInt = Int(round(tipPercentage * 100))
        
        self.tipPercentageLabel?.setText("\(tipPercentageInt)%")
        self.tipAmountLabel?.setText(self.dataSource.currencyStringFromInteger(tipAmount))
        self.totalAmountLabel?.setText(self.dataSource.currencyStringFromInteger(tipAmount + billAmount))
        self.billAmountLabel?.setText(self.dataSource.currencyStringFromInteger(billAmount))
    }
    
}
