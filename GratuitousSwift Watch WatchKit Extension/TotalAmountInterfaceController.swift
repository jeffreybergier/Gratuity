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
    
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private var currentContext = InterfaceControllerContext.NotSet
    private var dataSource = GratuitousWatchDataSource.sharedInstance
    
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
    
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
        
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
        
        self.setTitle(NSLocalizedString("Total Amount", comment: ""))
        
        // putting this in a background queue allows willActivate to finish, the animation to start.
        let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
        dispatch_async(backgroundQueue) {
            self.configureInterfaceController()
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            // set the text color of the labels
            self.tipPercentageLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.tipAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.totalAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.billAmountLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
            self.tipPercentageTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.tipAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.totalAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.billAmountTitleLabel?.setTextColor(GratuitousUIColor.lightTextColor())
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
            self.billAmountLabel?.setAttributedText(billAmountString)
            
            // set color for the group rings
            self.startOverButtonGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
            self.totalAmountGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.tipAmountGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.tipPercentageGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.billAmountGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            
            // we made it to the final step. time to increment the runcount
            if self.dataSource.watchAppRunCountShouldBeIncremented == true {
                self.dataSource.watchAppRunCount++
                self.dataSource.watchAppRunCountShouldBeIncremented = false // don't want to increment this more than once per runtime.
            }
            
            self.backgroundImageGroup?.setHidden(true)
            self.totalAmountGroup?.setHidden(false)
            self.tipAmountGroup?.setHidden(false)
            self.tipPercentageGroup?.setHidden(false)
            self.billAmountGroup?.setHidden(true)
            self.startOverButtonGroup?.setHidden(false)
        }
    }
    
    @IBAction func didTapStartOverButton() {
        self.popToRootController()
    }
}
