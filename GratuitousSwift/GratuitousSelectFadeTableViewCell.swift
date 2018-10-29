//
//  GratuitousSelectFadeTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousSelectFadeTableViewCell: UITableViewCell {
    
    weak var animatableTextLabel: UILabel?
    var animatingBorderColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.layer.borderWidth = GratuitousUIConstant.thinBorderWidth()
        self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().cgColor
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        self.animatingBorderColor = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //this timer was needed because this seems to get called slightly too soon and if the user touched the same cell again it would repeat the animation and it was jarring.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.cgAnimationDidFinish(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func cgAnimationDidFinish(_ timer: Timer?) {
        timer?.invalidate()
        
        self.animatingBorderColor = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let selectionAnimationDuration = animated == true ? GratuitousUIConstant.animationDuration() : 0.0001
        let deselectionAnimationDuration = animated == true ? GratuitousUIConstant.animationDuration() * 3 : 0.0001
        switch selected {
        case true:
            UIView.animate(withDuration: selectionAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                    self.animatableTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
                },
                completion: .none)
        case false:
            UIView.animate(withDuration: deselectionAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                    self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
                },
                completion: .none)
        }
    }
}
