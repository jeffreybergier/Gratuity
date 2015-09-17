//
//  SplitBillTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SplitBillTableViewCell: UITableViewCell {
    
    var identity: Identity? {
        didSet {
            if let identity = self.identity {
                switch identity {
                case .One(let value):
                    self.primaryLabel?.text = "\(value)"
                    self.primaryImageView?.image = IdentityImage.one
                case .Two(let value):
                    self.primaryLabel?.text = "\(value)"
                    self.primaryImageView?.image = IdentityImage.two
                case .Three(let value):
                    self.primaryLabel?.text = "\(value)"
                    self.primaryImageView?.image = IdentityImage.three
                case .Four(let value):
                    self.primaryLabel?.text = "\(value)"
                    self.primaryImageView?.image = IdentityImage.four
                case .Five(let value):
                    self.primaryLabel?.text = "\(value)"
                    self.primaryImageView?.image = IdentityImage.five
                }
            } else {
                self.primaryLabel?.text = ""
                self.primaryImageView?.image = .None
            }
        }
    }
    
    @IBOutlet private weak var primaryLabel: UILabel?
    @IBOutlet private weak var primaryImageView: UIImageView?
    
    enum Identity {
        case One(value: Int)
        case Two(value: Int)
        case Three(value: Int)
        case Four(value: Int)
        case Five(value: Int)
    }
    
    struct IdentityImage {
        static let one = UIImage(named: "faces1")
        static let two = UIImage(named: "faces2")
        static let three = UIImage(named: "faces3")
        static let four = UIImage(named: "faces4")
        static let five = UIImage(named: "faces5")
    }
    
}
