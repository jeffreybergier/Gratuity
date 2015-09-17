//
//  SplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class SplitBillViewController: SmallModalViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView?
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SplitBillTableViewCell else { return }
        switch indexPath.row {
        case 0:
            cell.identity = SplitBillTableViewCell.Identity.One(value: 100)
        case 1:
            cell.identity = SplitBillTableViewCell.Identity.Two(value: 50)
        case 2:
            cell.identity = SplitBillTableViewCell.Identity.Three(value: 25)
        case 3:
            cell.identity = SplitBillTableViewCell.Identity.Four(value: 13)
        case 4:
            cell.identity = SplitBillTableViewCell.Identity.Five(value: 6)
        default:
            cell.identity = .None
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Detail")!
    }
}
