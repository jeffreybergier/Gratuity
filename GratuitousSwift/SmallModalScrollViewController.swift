//
//  SmallModalScrollViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SmallModalScollViewController: SmallModalViewController {
    
    @IBOutlet weak var scrollView: UIScrollView?
    private var shouldScrollScrollViewToTopBecauseFirstLoad = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case its not caught by navigationBarDidChangeHeight
        self.autoFitScrollViewTopInset()
        self.shouldScrollScrollViewToTopBecauseFirstLoad = false
    }
    
    override func navigationBarHeightDidChange() {
        super.navigationBarHeightDidChange()
        self.autoFitScrollViewTopInset()
        if self.shouldScrollScrollViewToTopBecauseFirstLoad == true {
            self.scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 100, height: 100), animated: true)
        }
    }
    
    private func autoFitScrollViewTopInset() {
        if let navBar = self.navigationBar, let scrollView = self.scrollView {
            scrollView.contentInset.top = navBar.frame.size.height
        }
    }
    
}