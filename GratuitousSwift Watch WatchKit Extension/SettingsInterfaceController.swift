//
//  SettingsInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var suggestedTipTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var maximumBillTitleLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolTitleLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipSlider: WKInterfaceSlider?
    @IBOutlet private weak var maximumBillSlider: WKInterfaceSlider?
    
    @IBOutlet private weak var currencySymbolLocalLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolDollarLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolPoundLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolEuroLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolYenLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySymbolNoneLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var suggestedTipGroup: WKInterfaceGroup?
    @IBOutlet private weak var maximumBillGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolLocalGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolDollarGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolPoundGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolEuroGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolYenGroup: WKInterfaceGroup?
    @IBOutlet private weak var currencySymbolNoneGroup: WKInterfaceGroup?
    
    private var interfaceControllerIsConfigured = false
    
    private let titleTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 14, fallbackStyle: UIFontStyle.Headline)]
    private let largerButtonTextAttributes = [NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Headline)]
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.suggestedTipTitleLabel?.setAttributedText(NSAttributedString(string: "Suggested Tip Percentage", attributes: self.titleTextAttributes))
            self.maximumBillTitleLabel?.setAttributedText(NSAttributedString(string: "Maximum Bill Amount", attributes: self.titleTextAttributes))
            self.currencySymbolTitleLabel?.setAttributedText(NSAttributedString(string: "Currency Symbol", attributes: self.titleTextAttributes))
            
//            self.suggestedTipSlider
//            self.maximumBillSlider
            
            self.currencySymbolLocalLabel?.setAttributedText(NSAttributedString(string: "Local", attributes: self.titleTextAttributes))
            self.currencySymbolDollarLabel?.setAttributedText(NSAttributedString(string: "$", attributes: self.titleTextAttributes))
            self.currencySymbolPoundLabel?.setAttributedText(NSAttributedString(string: "£", attributes: self.titleTextAttributes))
            self.currencySymbolEuroLabel?.setAttributedText(NSAttributedString(string: "€", attributes: self.titleTextAttributes))
            self.currencySymbolYenLabel?.setAttributedText(NSAttributedString(string: "¥", attributes: self.titleTextAttributes))
            self.currencySymbolNoneLabel?.setAttributedText(NSAttributedString(string: "None", attributes: self.titleTextAttributes))
            
            self.suggestedTipGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.maximumBillGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolLocalGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolDollarGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolPoundGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolEuroGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolYenGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.currencySymbolNoneGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            
            self.interfaceControllerIsConfigured = true
        }
    }
    
    @IBAction func suggestedTipSliderDidChange(value: Float) {
        
    }
    
    @IBAction func maximumBillSliderDidChange(value: Float) {
        
    }
    
    @IBAction func currencySymbolButtonLocalTapped() {
        
    }
    
    @IBAction func currencySymbolButtonDollarTapped() {
        
    }
    
    @IBAction func currencySymbolButtonPoundTapped() {
        
    }
    
    @IBAction func currencySymbolButtonEuroTapped() {
        
    }
    
    @IBAction func currencySymbolButtonYenTapped() {
        
    }
    
    @IBAction func currencySymbolButtonNoneTapped() {
        
    }
}
