//
//  DRMovePanView.swift
//  TwoFingerGes
//
//  Created by David on 16/7/4.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

@objc protocol DRMovePanViewDelegate {
    optional func panViewDidMove(panView: DRMovePanView, gesture: UIPanGestureRecognizer)
    optional func panViewTouchEnded(panView: DRMovePanView, gesture: UIPanGestureRecognizer)
    optional func panViewShouldRecognizeSimultaneouslyWithGestureRecognizer(gestureRecognizer: UIGestureRecognizer, otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

class DRMovePanView: UIView, UIGestureRecognizerDelegate {

    var movable = true
    var movableHorizontal = true
    var movableVertical = true
    
    var scaleOnMove = true
    var scaleRatio:CGFloat = 1.1
    
    var delegate:DRMovePanViewDelegate?
    var indexPath:NSIndexPath?
    
    private var touchBegin = false
    var isTouching:Bool{
        get{
            return touchBegin
        }
    }
    
    private var ges:UIPanGestureRecognizer!
    private var panOffset:(x: CGFloat, y:CGFloat) = (0,0)
    var offset:CGPoint{
        get{
            return CGPoint(x: panOffset.x, y: panOffset.y)
        }
    }
    
    private var containedRect:UIView?
    var gestureLocatingView:UIView?{
        get{
            return containedRect
        }
        set(view){
            containedRect = view
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ges = UIPanGestureRecognizer(target: self, action: #selector(DRMovePanView.panGes(_:)))
        ges.delegate = self
        self.addGestureRecognizer(ges)
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(DRMovePanView.timer), userInfo: nil, repeats: true)
    }
    
    convenience init(frame: CGRect, gestureLocatingView: UIView) {
        self.init(frame: frame)
        containedRect = gestureLocatingView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func timer(){
        if ges.state == .Possible{
            if touchBegin{
                self.delegate?.panViewTouchEnded?(self, gesture: ges)
            }
            touchBegin = false
            if scaleOnMove{
                UIView.animateWithDuration(0.2, animations: {
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
            }
            
        }
    }
    
    @objc private func panGes(sender:UIPanGestureRecognizer){
        if movable{
            if touchBegin{
                let point = CGPoint(x: sender.locationInView(containedRect).x - panOffset.x, y: sender.locationInView(containedRect).y - panOffset.y)
                if movableHorizontal{
                    self.center.x = point.x
                }
                if movableVertical{
                    self.center.y = point.y
                }
            }else{
                if containedRect == nil{
                    containedRect = sender.view?.superview
                }
                
                panOffset = (sender.locationInView(containedRect).x - self.center.x, sender.locationInView(containedRect).y - self.center.y)
                touchBegin = true
                
                if scaleOnMove{
                    UIView.animateWithDuration(0.2, animations: { 
                        self.transform = CGAffineTransformMakeScale(self.scaleRatio, self.scaleRatio)
                    })
                }
            }
            self.delegate?.panViewDidMove?(self, gesture: sender)
        }
        
    }

//    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let point = gestureRecognizer.locationInView(self)
//        let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(self)
//        print(velocity.x)
//        if velocity.x > -200{
//            return false
//        }
        
//        let panGes = gestureRecognizer as! UIPanGestureRecognizer
//        let transPoint = panGes.translationInView(self)
//        if fabs(transPoint.x) > fabs(transPoint.y) {
//            return true
//        }
//        return false
//    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if delegate?.panViewShouldRecognizeSimultaneouslyWithGestureRecognizer?(gestureRecognizer, otherGestureRecognizer: otherGestureRecognizer) != nil{
            return (delegate?.panViewShouldRecognizeSimultaneouslyWithGestureRecognizer!(gestureRecognizer, otherGestureRecognizer: otherGestureRecognizer))!
        }else{
            return true
        }
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
