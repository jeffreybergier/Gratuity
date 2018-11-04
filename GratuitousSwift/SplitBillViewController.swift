//
//  SplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

final class SplitBillViewController: SmallModalTableViewController {
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences
    }
    
    fileprivate var totalAmount: Int {
        let billAmount = self.applicationPreferences.billIndexPathRow
        let suggestedTipPercentage = self.applicationPreferences.suggestedTipPercentage
        let tipAmount: Int
        if self.applicationPreferences.tipIndexPathRow != 0 {
            tipAmount = self.applicationPreferences.tipIndexPathRow
        } else {
            tipAmount = Int(round(Double(billAmount) * suggestedTipPercentage))
        }
        let totalAmount = tipAmount + billAmount
        //return 4000
        return totalAmount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.estimatedRowHeight = 100
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.title = LocalizedString.TitleLabel
    }
    
//    override func configureDynamicTextLabels() {
//        super.configureDynamicTextLabels()
//        self.tableView?.reloadData()
//    }

    fileprivate func roundedDivisionWithTop(_ top: Int, bottom: Int) -> Int {
        let division = Double(top)/Double(bottom)
        if division.isInfinite == false && division.isNaN == false {
            return Int(round(division))
        }
        return 0
    }
    
    fileprivate func determineTableRowCount() -> Int {
        for i in 1 ..< 100 {
            if self.roundedDivisionWithTop(self.totalAmount, bottom: i) <= 6 {
                return i
            }
        }
        return 100
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.determineTableRowCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 ..< 5:
            return tableView.dequeueReusableCell(withIdentifier: "DetailSingleLabel")!
        default:
            return tableView.dequeueReusableCell(withIdentifier: "DetailBiLabel")!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        guard let cell = cell as? SplitBillTableViewCell else { return }
        switch indexPath.row {
        case 0:
            cell.identity = SplitBillTableViewCell.Identity.one(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 1:
            cell.identity = SplitBillTableViewCell.Identity.two(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 2:
            cell.identity = SplitBillTableViewCell.Identity.three(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 3:
            cell.identity = SplitBillTableViewCell.Identity.four(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 4:
            cell.identity = SplitBillTableViewCell.Identity.five(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        default:
            cell.identity = SplitBillTableViewCell.Identity.higher(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1), divisor: indexPath.row + 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
