//
//  CellSwipeButtonsView.swift
//  Chatter
//
//  Created by David on 16/8/5.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit
@objc protocol CellSwipeButtonsViewDelgate {
    optional func cellSwipeButtonClickedAtIndex(swipeView: CellSwipeButtonsView, indexPath: NSIndexPath?, buttonIndex: Int)
}
class CellSwipeButtonsView: UIView {
    
    var buttons:[UIButton]?
    var indexPath:NSIndexPath?
    var delegate:CellSwipeButtonsViewDelgate?
    convenience init(buttons: [UIButton], indexPath: NSIndexPath?){
        self.init()
        self.buttons = buttons
        self.indexPath = indexPath
        var width:CGFloat = 0
        var height:CGFloat = 0
        var buttonIndex:Int = 0
        for btn in buttons{
            self.addSubview(btn)
            btn.tag = buttonIndex
            buttonIndex += 1
            btn.addTarget(self, action: #selector(CellSwipeButtonsView.btnClick(_:)), forControlEvents: .TouchUpInside)
            if btn.frame.height > height{
                height = btn.frame.height
            }
            width += btn.frame.width
        }
        
        self.frame = CGRect(x: UIScreen.mainScreen().bounds.width - width, y: 0, width: width, height: height)
        
    }
    
    func btnClick(sender:UIButton){
        if indexPath != nil{
            delegate?.cellSwipeButtonClickedAtIndex?(self, indexPath: indexPath!, buttonIndex: sender.tag)
        }else{
            delegate?.cellSwipeButtonClickedAtIndex?(self, indexPath: nil, buttonIndex: sender.tag)
        }
        
    }
}

