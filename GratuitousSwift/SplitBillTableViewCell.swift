//
//  SplitBillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

final class SplitBillTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var primaryLabel: UILabel?
    @IBOutlet fileprivate weak var secondaryTextLabel: UILabel?
    @IBOutlet fileprivate weak var primaryImageView: UIImageView?
    
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    fileprivate var currentCurrencySign: CurrencySign {
        return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences.overrideCurrencySymbol
    }
    
    var identity: Identity? {
        didSet {
            if let identity = self.identity {
                switch identity {
                case .one(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.one
                case .two(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.two
                case .three(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.three
                case .four(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.four
                case .five(let value):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.five
                case .higher(let value, let divisor):
                    self.primaryLabel?.text = self.currencyFormatter.currencyFormattedStringWithCurrencySign(self.currentCurrencySign, amount: value)
                    self.secondaryTextLabel?.text = "\(divisor)"
                    self.primaryImageView?.image = IdentityImage.one
                }
            } else {
                self.primaryLabel?.text = ""
                self.secondaryTextLabel?.text = ""
                self.primaryImageView?.image = .none
            }
        }
    }
    
    enum Identity {
        case one(value: Int)
        case two(value: Int)
        case three(value: Int)
        case four(value: Int)
        case five(value: Int)
        case higher(value: Int, divisor: Int)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySignChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: .none)
    }
    
    @objc fileprivate func currencySignChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.currencyFormatter.locale = Locale.current
            let currentIdentity = self.identity
            self.identity = currentIdentity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepareFontsAndColors()
    }
    
    fileprivate func prepareFontsAndColors() {
        let headlineFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let headlineFontSize = headlineFont.pointSize
        let bigFuturaFont = UIFont.futura(style: Futura.Medium, size: headlineFontSize * 2.5, fallbackStyle: UIFontStyle.headline)
        
        var normalFont = UIFont.preferredFont(forTextStyle: .headline).withSize(headlineFontSize * 1.5)
        if #available(iOS 9.0, *) {
            let traits = normalFont.fontDescriptor.object(forKey: UIFontDescriptorTraitsAttribute) as? NSDictionary
            let weight = CGFloat((traits?[UIFontWeightTrait] as? NSNumber)?.floatValue !! 0.3)
            let monospaceFont = UIFont.monospacedDigitSystemFont(ofSize: normalFont.pointSize, weight: weight)
            normalFont = monospaceFont
        }
        
        self.primaryLabel?.font = bigFuturaFont
        self.secondaryTextLabel?.font = normalFont
        
        self.primaryLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.secondaryTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        self.contentView.backgroundColor = UIColor.black
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
