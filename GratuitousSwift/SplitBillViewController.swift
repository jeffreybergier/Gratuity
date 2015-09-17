//
//  SplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class SplitBillViewController: SmallModalViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView?
    
    private var dataSource: GratuitousiOSDataSource {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate {
            return appDelegate.dataSource
        } else {
            fatalError("SplitBillTableViewCell: Data Source was NIL.")
        }
    }
    
    private var totalAmount: Int {
        guard let defaultsManager = self.dataSource.defaultsManager else { return 0 }
        let billAmount = defaultsManager.billIndexPathRow
        let suggestedTipPercentage = defaultsManager.suggestedTipPercentage
        let tipAmount: Int
        if defaultsManager.tipIndexPathRow != 0 {
            tipAmount = defaultsManager.tipIndexPathRow
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navBar = self.navigationBar, let tableView = self.tableView {
            tableView.contentInset = UIEdgeInsets(
                top: navBar.frame.size.height,
                left: tableView.contentInset.left,
                bottom: tableView.contentInset.bottom,
                right: tableView.contentInset.right
            )
        }
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
            if self.roundedDivisionWithTop(self.totalAmount, bottom: i) <= 5 {
                return i
            }
        }
        return 100
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.determineTableRowCount()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Detail")!
    }
}
