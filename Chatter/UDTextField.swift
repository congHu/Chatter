//
//  MyTextField.swift
//  NoteCloud
//
//  Created by David on 16/5/4.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit

class UDTextField: UITextField {

    var underLine:UIView!
    var tabIndex:Int = 0
    
    var boderWidth:CGFloat{
        get{
            return underLine.frame.height
        }
        set(value){
            underLine.frame = CGRectMake(0, 0, self.frame.width, value)
            underLine.center.y = self.frame.height - value/2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderStyle = UITextBorderStyle.None
        underLine = UIView(frame: CGRectMake(0, 0, self.frame.width, 2))
        underLine.center.y = self.frame.height - 1
        underLine.backgroundColor = UIColor.blackColor()
        self.addSubview(underLine)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
