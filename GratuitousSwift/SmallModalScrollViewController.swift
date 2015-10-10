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
    }
    
    override func navigationBarHeightDidChange() {
        super.navigationBarHeightDidChange()
        self.autoFitScrollViewTopInset()
        if self.shouldScrollScrollViewToTopBecauseFirstLoad == true {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 100, height: 100), animated: false)
                self.shouldScrollScrollViewToTopBecauseFirstLoad = false
            }
        }
    }
    
    private func autoFitScrollViewTopInset() {
        if let navBar = self.navigationBar, let scrollView = self.scrollView {
            scrollView.contentInset.top = navBar.frame.size.height
        }
    }
    
}