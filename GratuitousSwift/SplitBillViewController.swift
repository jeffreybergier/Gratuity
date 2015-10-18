//
//  SplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

final class SplitBillViewController: SmallModalTableViewController {
    
    private var applicationPreferences: GratuitousUserDefaults {
        return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences
    }
    
    private var totalAmount: Int {
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
        
        self.navigationBar?.items?.first?.title = LocalizedString.TitleLabel
    }
    
    private func roundedDivisionWithTop(top: Int, bottom: Int) -> Int {
        let division = Double(top)/Double(bottom)
        if isinf(division) == false && isnan(division) == false {
            return Int(round(division))
        }
        return 0
    }
    
    private func determineTableRowCount() -> Int {
        for i in 1 ..< 100 {
            if self.roundedDivisionWithTop(self.totalAmount, bottom: i) <= 6 {
                return i
            }
        }
        return 100
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.determineTableRowCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 ..< 5:
            return tableView.dequeueReusableCellWithIdentifier("DetailSingleLabel")!
        default:
            return tableView.dequeueReusableCellWithIdentifier("DetailBiLabel")!
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SplitBillTableViewCell else { return }
        switch indexPath.row {
        case 0:
            cell.identity = SplitBillTableViewCell.Identity.One(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 1:
            cell.identity = SplitBillTableViewCell.Identity.Two(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 2:
            cell.identity = SplitBillTableViewCell.Identity.Three(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 3:
            cell.identity = SplitBillTableViewCell.Identity.Four(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        case 4:
            cell.identity = SplitBillTableViewCell.Identity.Five(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1))
        default:
            cell.identity = SplitBillTableViewCell.Identity.Higher(value: self.roundedDivisionWithTop(self.totalAmount, bottom: indexPath.row + 1), divisor: indexPath.row + 1)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
