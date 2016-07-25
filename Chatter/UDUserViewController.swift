//
//  UDUserViewController.swift
//  Chatter
//
//  Created by David on 16/7/21.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDUserViewController: UIViewController {

    var myUID:String?
    var acode:String?
    var thisUid:String?
    
    var rightToolBar:UIToolbar!
    var bgImgView:UIButton!
    var avatar:UIButton!
    var unameLabel:UILabel!
    var subLabel:UILabel?
    
    var infoTableView:UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGrayColor()
        
        
        
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        avatar = UIButton(frame: CGRect(x: 0, y: 100, width: 80, height: 80))
        avatar.center.x = view.center.x
        avatar.backgroundColor = UIColor.grayColor()
        avatar.layer.cornerRadius = 10
        view.addSubview(avatar)
        
        
        
        let resq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(thisUid!)&type=user")!)
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if json == nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.avatar?.setImage(UIImage(data: data), forState: .Normal)
                            data.writeToFile("\(caches)/avatar/user\(self.thisUid!).jpg", atomically: true)
                        })
                    }
                }
            }
        })
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rightToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 70, height: 45))
        rightToolBar.layer.borderWidth = 0.0
        rightToolBar.layer.masksToBounds = true
        
        // MARK: 获取用户的关系
        
        
        rightToolBar.setItems([UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "edit"), UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil), UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sel2")], animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightToolBar)
    }
    
    func gotoEdit(){
        
    }
    func gotoChat(){
        
    }
    func gotoAddFriend(){
        
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
