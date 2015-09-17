//
//  SplitBillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SplitBillTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var primaryLabel: UILabel?
    @IBOutlet private weak var secondaryTextLabel: UILabel?
    @IBOutlet private weak var primaryImageView: UIImageView?
    
    private var dataSource: GratuitousiOSDataSource {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate {
            return appDelegate.dataSource
        } else {
            fatalError("SplitBillTableViewCell: Data Source was NIL.")
        }
    }
    
    var identity: Identity? {
        didSet {
            if let identity = self.identity {
                switch identity {
                case .One(let value):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.one
                case .Two(let value):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.two
                case .Three(let value):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.three
                case .Four(let value):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.four
                case .Five(let value):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
                    self.secondaryTextLabel?.text = ""
                    self.primaryImageView?.image = IdentityImage.five
                case .Higher(let value, let divisor):
                    self.primaryLabel?.text = self.dataSource.currencyFormattedString(value)
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
    }
    
    private func prepareFontsAndColors() {
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize
        let bigFuturaFont = UIFont.futura(style: Futura.Medium, size: headlineFontSize * 2.5, fallbackStyle: UIFontStyle.Headline)
        let normalFuturaFont = UIFont.futura(style: Futura.Medium, size: headlineFontSize * 2, fallbackStyle: UIFontStyle.Headline)
        
        self.primaryLabel?.font = bigFuturaFont
        self.secondaryTextLabel?.font = normalFuturaFont
        
        self.primaryLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.secondaryTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
    }
    
}
