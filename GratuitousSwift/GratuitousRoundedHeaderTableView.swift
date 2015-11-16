//
//  GratuitousHeaderTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//


final class GratuitousRoundedHeaderTableView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = GratuitousUIConstant.cornerRadius
    }
}
