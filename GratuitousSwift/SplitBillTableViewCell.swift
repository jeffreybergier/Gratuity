//
//  SplitBillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

final class SplitBillTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var primaryLabel: UILabel?
    @IBOutlet private weak var secondaryTextLabel: UILabel?
    @IBOutlet private weak var primaryImageView: UIImageView?
    
    private let currencyFormatter = GratuitousNumberFormatter(style: .RespondsToLocaleChanges)
    private var currentCurrencySign: CurrencySign {
        return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences.overrideCurrencySymbol
    }
    
    var identity: Identity? {
        didSet {
            if let identity = self.identity {
                switch identity {
                case .One(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.one
                case .Two(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.two
                case .Three(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.three
                case .Four(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.four
                case .Five(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.five
                case .Higher(let value, let divisor):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = "\(divisor)"
                    self.primaryImageView?.image = IdentityImage.one
                }
            } else {
                self.primaryLabel?.text = ""
                self.secondaryTextLabel?.text = ""
                self.primaryImageView?.image = .None
            }
        }
    }
    
    enum Identity {
        case One(value: Int)
        case Two(value: Int)
        case Three(value: Int)
        case Four(value: Int)
        case Five(value: Int)
        case Higher(value: Int, divisor: Int)
    }
    
    struct IdentityImage {
        static let one = UIImage(named: "faces1")
        static let two = UIImage(named: "faces2")
        static let three = UIImage(named: "faces3")
        static let four = UIImage(named: "faces4")
        static let five = UIImage(named: "faces5")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareFontsAndColors()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: NSCurrentLocaleDidChangeNotification, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySignChanged:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: .None)
    }
    
    @objc private func currencySignChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.currencyFormatter.locale = NSLocale.currentLocale()
            let currentIdentity = self.identity
            self.identity = currentIdentity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepareFontsAndColors()
    }
    
    private func prepareFontsAndColors() {
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize
        let bigFuturaFont = UIFont.futura(style: Futura.Medium, size: headlineFontSize * 2.5, fallbackStyle: UIFontStyle.Headline)
        
        var normalFont = UIFont.preferredFontForTextStyle(UIFontStyle.Headline.description).fontWithSize(headlineFontSize * 1.5)
        if #available(iOS 9.0, *) {
            let traits = normalFont.fontDescriptor().objectForKey(UIFontDescriptorTraitsAttribute) as? NSDictionary
            let weight = CGFloat((traits?[UIFontWeightTrait] as? NSNumber)?.floatValue !! 0.3)
            let monospaceFont = UIFont.monospacedDigitSystemFontOfSize(normalFont.pointSize, weight: weight)
            normalFont = monospaceFont
        }
        
        self.primaryLabel?.font = bigFuturaFont
        self.secondaryTextLabel?.font = normalFont
        
        self.primaryLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.secondaryTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        self.contentView.backgroundColor = UIColor.blackColor()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
