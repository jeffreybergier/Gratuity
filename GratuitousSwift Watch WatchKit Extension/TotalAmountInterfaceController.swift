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
    
    @IBOutlet private weak var totalAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipAmountTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var tipPercentageTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var billAmountTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var startOverButtonLabel: WKInterfaceLabel?
    @IBOutlet private weak var backgroundImageGroup: WKInterfaceGroup?
    @IBOutlet private weak var totalAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var tipPercentageGroup: WKInterfaceGroup?
    @IBOutlet private weak var billAmountGroup: WKInterfaceGroup?
    @IBOutlet private weak var startOverButtonGroup: WKInterfaceGroup?
    
    private var currentContext = InterfaceControllerContext.NotSet
    private var dataSource = GratuitousWatchDataSource.sharedInstance
    
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 17, fallbackStyle: UIFontStyle.Headline)]
    private let valueTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 25, fallbackStyle: UIFontStyle.Headline)]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentContext: InterfaceControllerContext
        //let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.TotalAmountInterfaceController
        } else {
            currentContext = Optional.None !! InterfaceControllerContext.TotalAmountInterfaceController
        }
        
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        // set the text color of the labels
        self.tipPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.tipAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.totalAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.billAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        self.tipPercentageTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.tipAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.totalAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.billAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
        self.startOverButtonGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
        self.startOverButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
        
        // set the static text of the labels
        self.tipPercentageTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Percentage", comment: ""), attributes: self.titleTextAttributes))
        self.tipAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Tip Amount", comment: ""), attributes: self.titleTextAttributes))
        self.totalAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Total Amount", comment: ""), attributes: self.titleTextAttributes))
        self.billAmountTitleLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Bill Amount", comment: ""), attributes: self.titleTextAttributes))
        self.startOverButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Start Over", comment: ""), attributes: self.titleTextAttributes))

        // clear strings from nib
        self.tipPercentageLabel?.setText("– %")
        self.tipAmountLabel?.setText("$ –")
        self.totalAmountLabel?.setText("$ –")
        self.billAmountLabel?.setText("$ –")
        
        // prepare data
        let billAmount = self.dataSource.billAmount !! 0
        let tipAmount = self.dataSource.tipAmount !! 0
        let tipPercentage = self.dataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount)) !! 0.2
        
        // prepare attributed text from data
        let tipPercentageString = NSAttributedString(string: self.dataSource.percentStringFromRawDouble(tipPercentage), attributes: self.valueTextAttributes)
        let tipAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount), attributes: self.valueTextAttributes)
        let totalAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(tipAmount + billAmount), attributes: self.valueTextAttributes)
        let billAmountString = NSAttributedString(string: self.dataSource.currencyStringFromInteger(billAmount), attributes: self.valueTextAttributes)
        
        // populate labels with data
        self.tipPercentageLabel?.setAttributedText(tipPercentageString)
        self.tipAmountLabel?.setAttributedText(tipAmountString)
        self.totalAmountLabel?.setAttributedText(totalAmountString)
        self.billAmountLabel?.setAttributedText(billAmountString)
        
        self.backgroundImageGroup?.setHidden(true)
        self.totalAmountGroup?.setHidden(false)
        self.tipAmountGroup?.setHidden(false)
        self.tipPercentageGroup?.setHidden(false)
        self.billAmountGroup?.setHidden(true)
        self.startOverButtonGroup?.setHidden(false)
    }
    
    @IBAction func didTapStartOverButton() {
        self.popToRootController()
    }
}
