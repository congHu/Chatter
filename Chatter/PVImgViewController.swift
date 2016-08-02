//
//  PVImgViewController.swift
//  Chatter
//
//  Created by David on 16/8/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class PVImgViewController: UIViewController {

    var imageView:UIImageView!
    var spinner:UDLoadingSpinner!
    convenience init(imagePrview:UIImage?){
        self.init()
        imageView = UIImageView(frame: view.frame)
        imageView.backgroundColor = UIColor.blackColor()
        
        view.addSubview(imageView)
        if imagePrview != nil{
            imageView.image = imagePrview
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        spinner = UDLoadingSpinner()
        view.addSubview(spinner)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
