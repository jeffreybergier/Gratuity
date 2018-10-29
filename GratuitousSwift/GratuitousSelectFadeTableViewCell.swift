//
//  GratuitousSelectFadeTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class GratuitousSelectFadeTableViewCell: UITableViewCell {
    
    weak var animatableTextLabel: UILabel?
    var animatingBorderColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.layer.borderWidth = GratuitousUIConstant.thinBorderWidth()
        self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().CGColor
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
    }
    
    override func animationDidStart(anim: CAAnimation) {
        self.animatingBorderColor = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        //this timer was needed because this seems to get called slightly too soon and if the user touched the same cell again it would repeat the animation and it was jarring.
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.cgAnimationDidFinish(_:)), userInfo: nil, repeats: false)
    }
    
    func cgAnimationDidFinish(timer: NSTimer?) {
        timer?.invalidate()
        
        self.animatingBorderColor = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let selectionAnimationDuration = animated == true ? GratuitousUIConstant.animationDuration() : 0.0001
        let deselectionAnimationDuration = animated == true ? GratuitousUIConstant.animationDuration() * 3 : 0.0001
        switch selected {
        case true:
            UIView.animateWithDuration(selectionAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                    self.animatableTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
                },
                completion: .None)
        case false:
            UIView.animateWithDuration(deselectionAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                    self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
                },
                completion: .None)
        }
    }
}
