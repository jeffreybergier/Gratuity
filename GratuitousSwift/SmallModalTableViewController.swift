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
    fileprivate var shouldScrollTableViewToTopBecauseFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case its not caught by navigationBarDidChangeHeight
//        self.autoFitTableViewTopInset()
    }
    
//    override func navigationBarHeightDidChange() {
//        super.navigationBarHeightDidChange()
//        self.autoFitTableViewTopInset()
//        if self.shouldScrollTableViewToTopBecauseFirstLoad == true {
//            self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//            self.shouldScrollTableViewToTopBecauseFirstLoad = false
//        }
//    }
    
//    fileprivate func autoFitTableViewTopInset() {
//        if let navBar = self.navigationBar, let tableView = self.tableView {
//            tableView.contentInset.top = navBar.frame.size.height
//        }
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
