//
//  GratuitousTableView.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/22/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTableView: UITableView, UITableViewDelegate {
    
    private let MAXBILLAMOUNT = 500
    private let MAXTIPAMOUNT = 250
    private let BILLAMOUNTTAG = 0
    private let TIPAMOUNTTAG = 1
    private let IDEALTIPPERCENTAGE = 0.2
    
    var isScrolling = false
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureTableViewWithCellType(cellClass: String, AndCellIdentifier cellIdentifier: String, AndTag tag: Int, AndViewControllerDelegate delegate: protocol <UITableViewDataSource, UITableViewDelegate>) {
        self.delegate = delegate
        self.dataSource = delegate
        self.tag = tag
        self.estimatedRowHeight = 76.0
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.showsVerticalScrollIndicator = false
        self.registerNib(UINib(nibName: cellClass, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
}
