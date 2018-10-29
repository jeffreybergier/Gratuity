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
    fileprivate var shouldScrollScrollViewToTopBecauseFirstLoad = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case its not caught by navigationBarDidChangeHeight
        self.autoFitScrollViewTopInset()
    }
    
    override func navigationBarHeightDidChange() {
        super.navigationBarHeightDidChange()
        self.autoFitScrollViewTopInset()
        if self.shouldScrollScrollViewToTopBecauseFirstLoad == true {
            let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 100, height: 100), animated: false)
                self.shouldScrollScrollViewToTopBecauseFirstLoad = false
            }
        }
    }
    
    fileprivate func autoFitScrollViewTopInset() {
        if let navBar = self.navigationBar, let scrollView = self.scrollView {
            scrollView.contentInset.top = navBar.frame.size.height
        }
    }
    
}
