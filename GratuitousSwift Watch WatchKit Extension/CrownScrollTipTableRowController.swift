//
//  TipTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollTipTableRowController: NSObject {
    
    @IBOutlet weak var lineFormingGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var starLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabelSmall: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let tipDollarAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.Headline)]
    private let tipPercentAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 16, fallbackStyle: UIFontStyle.Headline)]
    
    func setMoneyAmountLabel(#tipAmount: Int, billAmount: Int, starFlag: Bool) {
        self.starLabel?.setHidden(starFlag)
        if billAmount != 0 {
            self.tipPercentageLabelSmall?.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(Double(tipAmount) / Double(billAmount)), attributes: self.tipPercentAttributes))
            self.tipAmountLabel?.setAttributedText(NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount), attributes: self.tipDollarAttributes))
        } else {
            self.tipAmountLabel?.setText("$–")
            self.tipPercentageLabelSmall?.setText("–%")
        }
    }
    
    var interfaceIsConfigured = false
    func configureInterface() {
        self.tipAmountLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.starLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.tipPercentageLabelSmall?.setTextColor(GratuitousUIColor.lightTextColor())
        self.lineFormingGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
        self.interfaceIsConfigured = true
    }
}