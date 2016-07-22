//
//  UDSendStatusView.swift
//  Chatter
//
//  Created by David on 16/7/22.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDSendStatusView: UIView {

    var spinner:UIActivityIndicatorView!
    var resendButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.addSubview(spinner)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        resendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        // TODO: 重发的图片
        //resendButton?.setImage(UIImage(named: ""), forState: .Normal)
        resendButton?.alpha = 0
        self.addSubview(resendButton)
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
