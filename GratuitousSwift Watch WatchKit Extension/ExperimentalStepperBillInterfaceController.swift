//
//  ExperimentalStepperBillInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/2/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class ExperimentalStepperBillInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var currencyLabel: WKInterfaceLabel?
    
    @IBOutlet private weak var hundredsButton: WKInterfaceButton?
    @IBOutlet private weak var tensButton: WKInterfaceButton?
    @IBOutlet private weak var onesButton: WKInterfaceButton?
    
    @IBOutlet private weak var hundredsGroup: WKInterfaceGroup?
    @IBOutlet private weak var tensGroup: WKInterfaceGroup?
    @IBOutlet private weak var onesGroup: WKInterfaceGroup?
    
    @IBOutlet private weak var currencySlider: WKInterfaceSlider?
    @IBOutlet private weak var nextButton: WKInterfaceButton?
    
    private var currentContext = InterfaceControllerContext.NotSet
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    private var buttonValues: (hundreds: Int, tens: Int, ones: Int) = (0,0,0) {
        didSet {
            self.hundredsButton?.setTitle("\(self.buttonValues.hundreds)")
            self.tensButton?.setTitle("\(self.buttonValues.tens)")
            self.onesButton?.setTitle("\(self.buttonValues.ones)")
        }
    }
    private var selectedButton: SelectedButton = .None {
        didSet {
            let unselectedColor = UIColor.grayColor()
            let selectedColor = UIColor.whiteColor()
            self.currencySlider?.setValue(-1) // this fixes a bug where the slider was not setting itself to 0 on ocassion
            switch self.selectedButton {
            case .None:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
            case .Hundreds:
                self.hundredsGroup?.setBackgroundColor(selectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.hundreds))
            case .Tens:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(selectedColor)
                self.onesGroup?.setBackgroundColor(unselectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.tens))
            case .Ones:
                self.hundredsGroup?.setBackgroundColor(unselectedColor)
                self.tensGroup?.setBackgroundColor(unselectedColor)
                self.onesGroup?.setBackgroundColor(selectedColor)
                self.currencySlider?.setValue(Float(self.buttonValues.ones))
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentContext: InterfaceControllerContext
        //let currentContext: InterfaceControllerContext
        if let contextString = context as? String {
            currentContext = InterfaceControllerContext(rawValue: contextString) !! InterfaceControllerContext.StepperPagedTens
        } else {
            fatalError("StepperInterfaceController: Context not present during awakeWithContext:")
        }
        self.currentContext = currentContext
    }
    
    override func willActivate() {
        super.willActivate()
        
        self.nextButton?.setTitle(NSLocalizedString("Next", comment: ""))
        self.updateUIWithCurrencyAmount(self.dataSource.billAmount)
        self.selectedButton = .Ones
    }
    
    private func updateUIWithCurrencyAmount(currencyAmount: Int?) {
        if let currencyAmount = currencyAmount {
            if currencyAmount > 999 {
                self.buttonValues = (9,9,9) // this display cannot show more than 999, so if its, we will use that as the new billAmount
            } else {
                let intString = "\(currencyAmount)"
                let intArray = Array(intString).map { String($0).toInt() }
                for (index, integer) in enumerate(intArray.reverse()) {
                    switch index {
                    case 0:
                        self.buttonValues.ones = integer !! 0
                    case 1:
                        self.buttonValues.tens = integer !! 0
                    case 2:
                        self.buttonValues.hundreds = integer !! 0
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func writeCurrencyValueToDisk(currencyArray: [Int]) {
        println("Saving Array to disk \(currencyArray)")
        var compiledInt = 0
        for (index, integer) in enumerate(currencyArray.reverse()) {
            // for index 0 the integer needs to be multiplied by 1.
            // For index 1, it needs to be multiplied by 10
            // for index 2, it needs to be multipled by 100
            // the index == the number of zeros needed after the 1.
            // this for loop accomplishes that.
            var zeroString = "1"
            for i in 0..<index {
                zeroString += "0"
            }
            let multiplier = zeroString.toInt() !! 1
            compiledInt += integer * multiplier
        }
        self.dataSource.billAmount = compiledInt
    }

    @IBAction private func sliderDidChange(value: Float) {
        switch self.selectedButton {
        case .None:
            break
        case .Hundreds:
            if self.buttonValues.hundreds == Int(round(value)) && self.buttonValues.hundreds == 0 {
                self.carryValueDown(valuePlace: .Hundreds)
            } else {
                self.buttonValues.hundreds = Int(round(value))
            }
        case .Tens:
            if self.buttonValues.tens == Int(round(value)) {
                switch self.buttonValues.tens {
                case 9:
                    self.carryValueUp(valuePlace: .Tens)
                case 0:
                    self.carryValueDown(valuePlace: .Tens)
                default:
                    break
                }
            } else {
                self.buttonValues.tens = Int(round(value))
            }
        case .Ones:
            if self.buttonValues.ones == Int(round(value)) && self.buttonValues.ones == 9 {
                self.carryValueUp(valuePlace: .Ones)
            } else {
                self.buttonValues.ones = Int(round(value))
            }
        }
        self.writeCurrencyValueToDisk([self.buttonValues.hundreds, self.buttonValues.tens, self.buttonValues.ones])
    }
    
    private func carryValueUp(#valuePlace: SelectedButton) {
        switch valuePlace {
        case .Tens:
            self.buttonValues.hundreds += 1
            self.buttonValues.tens = 0
            self.selectedButton = .Tens
        case .Ones:
            self.buttonValues.tens += 1
            self.buttonValues.ones = 0
            self.selectedButton = .Ones
        default:
            break
        }
    }
    
    private func carryValueDown(#valuePlace: SelectedButton) {
        // this may or may not make sense
        // it can lead to some strange behavior and some data loss
        // may remove this function before release
        switch valuePlace {
        case .Tens:
            self.buttonValues.ones = 9
            self.selectedButton = .Ones
        case .Hundreds:
            self.buttonValues.tens = 9
            self.buttonValues.ones = 9
            self.selectedButton = .Tens
        default:
            break
        }
    }
    
    @IBAction private func hundredButtonSelected() {
        self.selectedButton = .Hundreds
    }
    
    @IBAction private func tensButtonSelected() {
        self.selectedButton = .Tens
    }
    
    @IBAction private func onesButtonSelected() {
        self.selectedButton = .Ones
    }
    
    private enum SelectedButton: Printable {
        case None, Hundreds, Tens, Ones
        var description: String {
            switch self {
            case .None:
                return "SelectedButton.None"
            case .Hundreds:
                return "SelectedButton.Hundreds"
            case .Tens:
                return "SelectedButton.Tens"
            case .Ones:
                return "SelectedButton.Ones"
            }
        }
    }
}