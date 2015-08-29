//
//  PickerInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/23/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import Foundation

class PickerInterfaceController: WKInterfaceController, GratuitousWatchConnectivityDelegate {
    
    @IBOutlet private var loadingGroup: WKInterfaceGroup?
    @IBOutlet private var mainGroup: WKInterfaceGroup?
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let watchConnectivityManager = GratuitousWatchConnectivityManager()
    
    private var items = [WKPickerItem]() {
        didSet {
            self.billPicker?.setItems(self.items)
            self.tipPicker?.setItems(self.items)
            self.billPicker?.setSelectedItemIndex(self.dataSource.defaultsManager.billIndexPathRow - 1)
            self.interfaceState = .Loaded
        }
    }
    
    enum InterfaceState {
        case Loading, Loaded
    }
    
    private var interfaceState: InterfaceState = .Loading {
        didSet {
            switch self.interfaceState {
            case .Loading:
                self.loadingGroup?.setHidden(false)
                self.mainGroup?.setHidden(true)
            case .Loaded:
                self.loadingGroup?.setHidden(true)
                self.mainGroup?.setHidden(false)
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        // start animating
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: Int.max)
        
        // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
        let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
        dispatch_async(backgroundQueue) {
            self.watchConnectivityManager.interfaceControllerDelegate = self
            self.dataOnDiskChanged()
        }
    }
    
    func dataOnDiskChanged() {
        if let items = readPickerItemsFromDisk(self.dataSource.defaultsManager.overrideCurrencySymbol) {
            dispatch_async(dispatch_get_main_queue()) {
                self.items = items
            }
        } else {
            self.watchConnectivityManager.requestDataFromPhone()
        }
    }
    
    func readPickerItemsFromDisk(currency: CurrencySign) -> [WKPickerItem]? {
        let fileName: String
        switch currency {
        case .Default:
            fileName = "\(self.dataSource.currencyCode)Currency.data"
        case .Dollar:
            fileName = "DollarCurrency.data"
        case .Pound:
            fileName = "PoundCurrency.data"
        case .Euro:
            fileName = "EuroCurrency.data"
        case .Yen:
            fileName = "YenCurrency.data"
        case .None:
            fileName = "NoneCurrency.data"
        }
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent(fileName)
        var items = [WKPickerItem]()
        if let data = NSData(contentsOfURL: dataURL),
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSArray {
                for object in array {
                    if let image = object as? UIImage {
                        let wkImage = WKImage(image: image)
                        let item = WKPickerItem()
                        item.contentImage = wkImage
                        items += [item]
                    }
                }
        }
        
        print("\(items.count) found at URL: \(dataURL.path!)")
        if items.isEmpty == false { return items } else { return .None }
    }
    
    
    
    private var currentBillAmount = 0 {
        didSet {
            let string = NSAttributedString(string: self.dataSource.currencyStringFromInteger(self.currentBillAmount), attributes: self.largeValueTextAttributes)
            self.billAmountLabel?.setAttributedText(string)
        }
    }
    private var currentTipPercentage: Double? = 0.0 {
        didSet {
            let string = NSAttributedString(string: self.dataSource.percentStringFromRawDouble(self.currentTipPercentage), attributes: self.smallValueTextAttributes)
            self.tipPercentageLabel?.setAttributedText(string)
        }
    }

    @IBOutlet private var tipPercentageLabel: WKInterfaceLabel?
    @IBOutlet private var billAmountLabel: WKInterfaceLabel?
    @IBOutlet private var tipPicker: WKInterfacePicker?
    @IBOutlet private var billPicker: WKInterfacePicker?
        
    private let largeValueTextAttributes = GratuitousUIColor.WatchFonts.hugeValueText
    private let smallValueTextAttributes = GratuitousUIColor.WatchFonts.valueText

    @IBAction func billPickerChanged(value: Int) {
        self.dataSource.defaultsManager.billIndexPathRow = value + 1
        
        let billAmount = value + 1
        let suggestTipPercentage = self.dataSource.defaultsManager.suggestedTipPercentage
        let tipAmount = Int(round(Double(billAmount) * suggestTipPercentage))
        
        let tipIndex = tipAmount - 1
        if tipIndex >= 0 {
            self.tipPicker?.setSelectedItemIndex(tipIndex)
        }
        
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
    }
    
    @IBAction func tipPickerChanged(value: Int) {
        self.dataSource.defaultsManager.tipIndexPathRow = value + 1
        
        let billAmount = self.dataSource.defaultsManager.billIndexPathRow
        let tipAmount = value + 1
        let actualTipPercentage = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(billAmount))
        self.currentBillAmount = billAmount + tipAmount
        self.currentTipPercentage = actualTipPercentage
    }
}
