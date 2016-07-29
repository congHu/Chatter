//
//  UDUserViewController.swift
//  Chatter
//
//  Created by David on 16/7/21.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit
enum UDUserRelation {
    case Myself
    case Friend
    case Stranger
    case BlackList
}
//protocol UDSingleChatDelegate {
//    func pushToChatVCImd(chatVC:UDChatViewController)
//    
//}
class UDUserViewController: UIViewController, UIActionSheetDelegate {

    var scrollView:UIScrollView!
    
    var myUID:String?
    var acode:String?
    var thisUid:String?
    var rootVC:FirstViewController?
    
    var rightToolBar:UIToolbar!
    var bgImgView:UIButton!
    var avatar:UIButton!
    var unameLabel:UILabel!
    var subLabel:UILabel?
    
    var infoTableView:UITableView!
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    
    var friendComments:NSDictionary?
    var friendRelation:UDUserRelation = .Stranger
    
//    var delegate:UDSingleChatDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: view.frame)
        view.addSubview(scrollView)
        scrollView.backgroundColor = UIColor(hex: "dddddd")
        scrollView.alwaysBounceVertical = true
        
        
        // TODO: 获取封面图
        bgImgView = UIButton(frame: CGRect(x: 0, y: -128, width: scrollView.frame.width, height: scrollView.frame.width))
        scrollView.addSubview(bgImgView)
        bgImgView.backgroundColor = UIColor.lightGrayColor()
        
        
        avatar = UIButton(frame: CGRect(x: 16, y: bgImgView.frame.origin.y + bgImgView.frame.height - 40, width: 80, height: 80))
        avatar.backgroundColor = UIColor.grayColor()
        avatar.layer.cornerRadius = 10
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 2
        avatar.layer.masksToBounds = true
        scrollView.addSubview(avatar)
        let avatarImgPath = "\(caches)/avatar/user\(thisUid!).jpg"
        if NSFileManager.defaultManager().fileExistsAtPath(avatarImgPath){
            avatar.setImage(UIImage(contentsOfFile: avatarImgPath), forState: .Normal)
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/friend_comments.plist"){
            friendComments = NSDictionary(contentsOfFile: "\(caches)/friend_comments.plist")
        }else{
            let friendComReq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getFriendComments.php")!)
            friendComReq.HTTPMethod = "POST"
            friendComReq.HTTPBody = NSString(string: "uid=\(myUID!)&&acode=\(acode!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(friendComReq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        self.friendComments = NSDictionary(dictionary: jsonObj!)
                        self.friendComments?.writeToFile("\(self.caches)/friend_comments.plist", atomically: true)
                        dispatch_async(dispatch_get_main_queue(), {
                            if self.friendComments?.objectForKey("\(self.thisUid!)") != nil{
                                self.unameLabel.text = self.friendComments?.objectForKey("\(self.thisUid!)") as? String
                            }
                        })
                    }
                }
            }
        }
        
        unameLabel = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: avatar.frame.origin.y + 20, width: scrollView.frame.width - avatar.frame.width - 16 - 8 - 16, height: 20))
        scrollView.addSubview(unameLabel)
        unameLabel.textColor = UIColor.whiteColor()
        unameLabel.font = UIFont.systemFontOfSize(16)
        unameLabel.layer.shadowColor = UIColor.blackColor().CGColor
        unameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        unameLabel.text = ""
        if friendComments?.objectForKey("\(thisUid!)") != nil{
            unameLabel.text = friendComments?.objectForKey("\(thisUid!)") as? String
        }
        
        
        subLabel = UILabel(frame: CGRect(x: unameLabel.frame.origin.x + 5, y: bgImgView.frame.origin.y + bgImgView.frame.height, width: unameLabel.frame.width, height: 20))
        subLabel?.textColor = UIColor.grayColor()
        subLabel?.font = UIFont.systemFontOfSize(12)
        scrollView.addSubview(subLabel!)
        subLabel?.text = ""
        
        let avatarResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(thisUid!)&type=user")!)
        NSURLConnection.sendAsynchronousRequest(avatarResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if json == nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.avatar.setImage(UIImage(data: data), forState: .Normal)
                            data.writeToFile(avatarImgPath, atomically: true)
                        })
                        
                        
                    }
                    
                }
            }
        })
        
        // TODO: 获取用户信息, 生日、个性签名未处理
        let infoResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getUserInfo.php?uid=\(thisUid!)")!)
        NSURLConnection.sendAsynchronousRequest(infoResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    if json != nil{
                        if json!.objectForKey("error") == nil{
                            dispatch_async(dispatch_get_main_queue(), {
                                self.navigationItem.title = json?.objectForKey("uname") as? String
                                if self.unameLabel.text == ""{
                                    self.unameLabel.text = json?.objectForKey("uname") as? String
                                }
                                var subTitle = ""
                                if (json?.objectForKey("area") as? String) != nil{
                                    subTitle += json?.objectForKey("area") as! String
                                    subTitle += " "
                                }
                                if (json?.objectForKey("gender") as? String) != nil{
                                    let gender = json?.objectForKey("gender") as! String
                                    if gender == "0"{
                                        subTitle += "男"
                                    }else if gender == "1"{
                                        subTitle += "女"
                                    }
                                    subTitle += " "
                                }
                                if json?.objectForKey("age") != nil{
                                    if (json?.objectForKey("age") as? Int) != nil{
                                        subTitle += "\(json?.objectForKey("age") as! Int)"
                                        subTitle += "岁"
                                    }
                                }
                                
                                self.subLabel?.text = subTitle
                                
                            })
                        }
                    }
                }
            }
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rightToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 76, height: 45))
        rightToolBar.layer.borderWidth = 0.0
        rightToolBar.layer.masksToBounds = true
        
        // TODO: 获取用户的关系, 还差黑名单
        
        if myUID == thisUid{
            friendRelation = .Myself
            
        }else{
            let infoResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/isFriend.php")!)
            infoResq.HTTPMethod = "POST"
            infoResq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(acode!)&fid=\(thisUid!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(infoResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                        if json == nil{
                            dispatch_async(dispatch_get_main_queue(), {
                                if NSString(data:data, encoding: NSUTF8StringEncoding) == "1"{
                                    self.friendRelation = .Friend
                                }
                                var toolBarItems:[UIBarButtonItem] = []
                                switch self.friendRelation {
                                case .Myself:
                                    
                                    toolBarItems.append(UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(UDUserViewController.gotoEdit)))
                                    break
                                case .Stranger:
                                    toolBarItems.append(UIBarButtonItem(image: UIImage(named: "addFriend"), style: .Plain, target: self, action: #selector(UDUserViewController.gotoAddFriend)))
//                                    toolBarItems.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
                                    toolBarItems.append(UIBarButtonItem(image: UIImage(named: "more"), style: .Plain, target: self, action: #selector(UDUserViewController.moreMenu)))
                                    break
                                case .Friend:
                                    toolBarItems.append(UIBarButtonItem(image: UIImage(named: "chat"), style: .Plain, target: self, action: #selector(UDUserViewController.gotoChat)))
//                                    toolBarItems.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
                                    toolBarItems.append(UIBarButtonItem(image: UIImage(named: "more"), style: .Plain, target: self, action: #selector(UDUserViewController.moreMenu)))
                                    break
                                default:
                                    break
                                }
                                
                                self.rightToolBar.setItems(toolBarItems, animated: true)
                                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightToolBar)
                            })
                        }
                    }
                }
            })
            
        }
        
    }
    
    func gotoEdit(){
        print("edit")
    }
    func gotoChat(){
        print("chat")
        // TODO: pop到rootVC 然后push到chatVC
        let chatVC = UDChatViewController()
        chatVC.myUID = myUID
        chatVC.myAcode = acode
        chatVC.chatroomName = unameLabel.text
        chatVC.chatroomID = "user\(thisUid!)"
        
        navigationController?.popToRootViewControllerAnimated(false)
        rootVC?.pushToChatVCImd(chatVC)
        
//        for vc in (navigationController?.viewControllers)!{
//            if vc.isKindOfClass(FirstViewController){
//                let fvc = vc as! FirstViewController
//                fvc.pushToChatVCImd(chatVC)
//            }
//        }
//        let firstVC = navigationController?.storyboard?.instantiateViewControllerWithIdentifier("firstVC") as! FirstViewController
        
//        firstVC.pushToChatVCImd(chatVC)
    }
    func gotoAddFriend(){
        print("add friend")
    }
    func moreMenu(){
        switch friendRelation {
        case .Myself:
            break
        case .Friend:
            UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "删除好友").showInView(view)
            break
        case .Stranger:
            UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "添加至黑名单").showInView(view)
            break
        case .BlackList:
            UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "移除黑名单").showInView(view)
            break
        }
        
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0{
            switch friendRelation {
            case .Myself:
                break
            case .Friend:
                print("删除")
                break
            case .Stranger:
                print("黑名单")
                break
            case .BlackList:
                print("移除黑名单")
                break
            }
        }
        
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
