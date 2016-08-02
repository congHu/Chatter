//
//  UDLoadingSpinner.swift
//  Chatter
//
//  Created by David on 16/8/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDLoadingSpinner: UIView {

    var spinnerBG:UIView!
    var spinner:UIActivityIndicatorView!
    var hidesWhenStopped: Bool{
        get{
            return spinner.hidesWhenStopped
        }
        set(val){
            spinner.hidesWhenStopped = val
        }
    }
    
    
    func startAnimating(){
        spinner.startAnimating()
        self.alpha = 1
    }
    func stopAnimating(){
        spinner.stopAnimating()
        if hidesWhenStopped{
            self.alpha = 0
        }
    }
    func isAnimating() -> Bool{
        return spinner.isAnimating()
    }
    
    init() {
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width))
        spinnerBG = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinnerBG.center = self.center
        spinnerBG.backgroundColor = UIColor(white: 0, alpha: 0.75)
        spinnerBG.layer.cornerRadius = 5
        self.addSubview(spinnerBG)
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.center = CGPoint(x: 25, y: 25)
        spinner.activityIndicatorViewStyle = .White
        spinner.startAnimating()
        
        spinnerBG.addSubview(spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
