//
//  StepperBillInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/14/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class StepperInterfaceController: WKInterfaceController {

    @IBOutlet private weak var instructionTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencyAmountTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var currencySlider: WKInterfaceSlider?
    @IBOutlet private weak var nextButton: WKInterfaceButton?
    @IBOutlet weak var tipPercentageLabel: WKInterfaceLabel?
    
    private var currentContext = InterfaceControllerContext.NotSet
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.StepperPagedTens
        } else {
            fatalError("StepperInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }

    override func willActivate() {
        super.willActivate()
        
        self.instructionTextLabel?.setText("")
        self.currencyAmountTextLabel?.setText("$ –")
        self.tipPercentageLabel?.setText("– %")
        self.tipPercentageLabel?.setHidden(true)
        
        switch self.currentContext {
        case .StepperInfinite:
            break
        case .StepperPagedTens:
            break
        case .StepperPagedOnes:
            break
        case .StepperTipChooser:
            self.tipPercentageLabel?.setHidden(false)
        default:
            fatalError("StepperInterfaceController: Context was invalid while switching.")
        }
    }
}
