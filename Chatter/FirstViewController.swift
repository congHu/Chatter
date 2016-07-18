//
//  FirstViewController.swift
//  Chatter
//
//  Created by David on 16/7/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var loginVC:UDLoginViewController!
    var uid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginVC = UDLoginViewController()
        loginVC.view.backgroundColor = UIColor.whiteColor()
        print(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true))
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

