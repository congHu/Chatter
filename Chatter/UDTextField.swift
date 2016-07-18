//
//  MyTextField.swift
//  NoteCloud
//
//  Created by David on 16/5/4.
//  Copyright (c) 2016年 David. All rights reserved.
//

import UIKit

enum UDTextFieldType {
    case Email
    case Password
    case Verify
}

class UDTextField: UITextField {

    private var underLine:UIView!
    var tabIndex:Int = 0
    var underLineColor:UIColor{
        get{
            return underLine.backgroundColor!
        }
        set(val){
            underLine.backgroundColor = val
        }
    }
    private var inputType:UDTextFieldType = .Email
    var textFieldType:UDTextFieldType{
        get{
            return inputType
        }
        set(val){
            inputType = val
            setType()
        }
    }
    
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
        self.clearButtonMode = .WhileEditing
        underLine = UIView(frame: CGRectMake(0, 0, self.frame.width, 2))
        underLine.center.y = self.frame.height - 1
        underLine.backgroundColor = UIColor.blackColor()
        self.addSubview(underLine)
        setType()
    }
    
    private func setType(){
        switch inputType {
        case .Email:
            placeholder = "user@example.com"
            keyboardType = .EmailAddress
            returnKeyType = .Next
            autocorrectionType = .No
            autocapitalizationType = .None
            tabIndex = 0
            break
        case .Password:
            placeholder = "密码"
            secureTextEntry = true
            keyboardType = .ASCIICapable
            returnKeyType = .Next
            tabIndex = 1
            break
        case .Verify:
            placeholder = "验证码"
            returnKeyType = .Done
            keyboardType = .ASCIICapable
            autocorrectionType = .No
            autocapitalizationType = .None
            tabIndex = 2
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
