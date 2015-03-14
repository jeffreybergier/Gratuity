//
//  TipTableRowController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class CrownScrollTipTableRowController: NSObject {
    
    @IBOutlet private weak var outlineGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipAmountLabel: WKInterfaceLabel?
    @IBOutlet private weak var starLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageLabelSmall: WKInterfaceLabel?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let valueTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 25, fallbackStyle: UIFontStyle.Headline)]
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    
    var tipAmount = 0
    
    func setMoneyAmountLabel(#tipAmount: Int, billAmount: Int, starFlag: Bool) {
        self.starLabel?.setHidden(starFlag)
        if billAmount != 0 {
            self.tipPercentageLabelSmall?.setAttributedText(NSAttributedString(string: self.dataSource.percentStringFromRawDouble(Double(tipAmount) / Double(billAmount)), attributes: self.titleTextAttributes))
            self.tipAmountLabel?.setAttributedText(NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount), attributes: self.valueTextAttributes))
            self.tipAmount = tipAmount
        } else {
            self.tipAmountLabel?.setAttributedText(NSAttributedString(string: "$–", attributes: self.valueTextAttributes))
            self.tipPercentageLabelSmall?.setAttributedText(NSAttributedString(string: "–%", attributes: self.titleTextAttributes))
        }
    }
    
    var interfaceIsConfigured = false
    func configureInterface() {
        self.tipAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.starLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.tipPercentageLabelSmall?.setTextColor(GratuitousUIColor.lightTextColor())
        self.outlineGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
        self.interfaceIsConfigured = true
    }
}