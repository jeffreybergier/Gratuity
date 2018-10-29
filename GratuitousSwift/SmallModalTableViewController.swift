//
//  SmallModalTableViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SmallModalTableViewController: SmallModalViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    private var shouldScrollTableViewToTopBecauseFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case its not caught by navigationBarDidChangeHeight
        self.autoFitTableViewTopInset()
    }
    
    override func navigationBarHeightDidChange() {
        super.navigationBarHeightDidChange()
        self.autoFitTableViewTopInset()
        if self.shouldScrollTableViewToTopBecauseFirstLoad == true {
            self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            self.shouldScrollTableViewToTopBecauseFirstLoad = false
        }
    }
    
    private func autoFitTableViewTopInset() {
        if let navBar = self.navigationBar, let tableView = self.tableView {
            tableView.contentInset.top = navBar.frame.size.height
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
