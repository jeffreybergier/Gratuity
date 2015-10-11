//
//  GratuitousHeaderTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousRoundedHeaderTableView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 6.0
    }
}
