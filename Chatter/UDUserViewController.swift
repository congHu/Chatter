//
//  UDUserViewController.swift
//  Chatter
//
//  Created by David on 16/7/21.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDUserViewController: UIViewController {

    var uid:String?
    var avatar:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor() 
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        avatar = UIImageView(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
        avatar.center.x = view.center.x
        avatar.backgroundColor = UIColor.grayColor()
        view.addSubview(avatar)
        let resq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(uid!)")!)
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if json == nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.avatar?.image = UIImage(data: data)
                            data.writeToFile("\(caches)/avatar/\(self.uid!).jpg", atomically: true)
                        })
                    }
                }
            }
        })
        
        
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
