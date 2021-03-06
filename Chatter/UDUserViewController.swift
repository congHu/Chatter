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
class UDUserViewController: UIViewController, UIActionSheetDelegate, UIAlertViewDelegate, UDPostViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var scrollView:UIScrollView!
    
    var myUID:String?
    var acode:String?
    var thisUid:String?
    var rootVC:FirstViewController?
    var justPop = false
    var needToTab = false
//    var tabDelegate:UDSingleChatDelegate?
    
    var rightToolBar:UIToolbar!
    var bgImgView:UIButton!
    var avatar:UIButton!
    var unameLabel:UILabel!
    
    //  修改备注按钮
//    var setFriendCommentBtn:UIButton!
    
    var subLabel:UILabel?
    
    var infoTableView:UITableView!
    var infosInTable:NSMutableDictionary?
    
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    
    var friendComments:NSMutableDictionary?
    var friendRelation:UDUserRelation = .Stranger
    
    var reqMsg:String?
    
    var descriptionHeight:CGFloat = 0
    
//    var delegate:UDSingleChatDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: view.frame)
        view.addSubview(scrollView)
        scrollView.backgroundColor = UIColor(hex: "dddddd")
        scrollView.alwaysBounceVertical = true
        
        
        
        bgImgView = UIButton(frame: CGRect(x: 0, y: -128, width: scrollView.frame.width, height: scrollView.frame.width))
        scrollView.addSubview(bgImgView)
        bgImgView.backgroundColor = UIColor.lightGrayColor()
        
        bgImgView.addTarget(self, action: #selector(UDUserViewController.bgImgTap), forControlEvents: .TouchUpInside)
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(self.caches)/bg_img/user\(self.thisUid!).jpg"){
            bgImgView.setImage(UIImage(contentsOfFile: "\(self.caches)/bg_img/user\(self.thisUid!).jpg"), forState: .Normal)
        }
        
        
        let bgResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getBGImg.php?uid=\(thisUid!)")!)
        NSURLConnection.sendAsynchronousRequest(bgResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if json == nil{
                        if data.length != 0{
                            dispatch_async(dispatch_get_main_queue(), {
                                self.bgImgView.setImage(UIImage(data: data), forState: .Normal)
                                data.writeToFile("\(self.caches)/bg_img/user\(self.thisUid!).jpg", atomically: true)
                            })
                        }
                        
                        
                        
                    }
                    
                }
            }
        })
        
        
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
        avatar.addTarget(self, action: #selector(UDUserViewController.avatarTap), forControlEvents: .TouchUpInside)
        
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/friend_comments.plist"){
            friendComments = NSMutableDictionary(contentsOfFile: "\(caches)/friend_comments.plist")
        }else{
            let friendComReq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getFriendComments.php")!)
            friendComReq.HTTPMethod = "POST"
            friendComReq.HTTPBody = NSString(string: "uid=\(myUID!)&&acode=\(acode!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(friendComReq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        let jsonDict = jsonObj as? NSDictionary
                        if jsonDict != nil{
                            self.friendComments = NSMutableDictionary(dictionary: jsonDict!)
                            self.friendComments?.writeToFile("\(self.caches)/friend_comments.plist", atomically: true)
                            dispatch_async(dispatch_get_main_queue(), {
                                if self.friendComments?.objectForKey("\(self.thisUid!)") != nil{
                                    let showText = self.friendComments?.objectForKey("\(self.thisUid!)") as? String
                                    self.unameLabel.text = showText
//                                    if showText != nil{
//                                        let size = NSString(string: showText!).boundingRectWithSize(CGSize(width: self.unameLabel.frame.width, height: self.unameLabel.frame.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.unameLabel.font], context: nil)
//                                        self.setFriendCommentBtn = UIButton(frame: CGRect(x: self.unameLabel.frame.origin.x + size.width + 8, y: self.unameLabel.frame.origin.y, width: 16, height: 16))
//                                        self.setFriendCommentBtn.setImage(UIImage(named: "edit"), forState: .Normal)
//                                        self.scrollView.addSubview(self.setFriendCommentBtn)
//                                    }
                                }
                            })
                        }
                        
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
            let showText = friendComments?.objectForKey("\(thisUid!)") as? String
            unameLabel.text = showText
//            if showText != nil{
//                let size = NSString(string: showText!).boundingRectWithSize(CGSize(width: unameLabel.frame.width, height: unameLabel.frame.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: unameLabel.font], context: nil)
//                setFriendCommentBtn = UIButton(frame: CGRect(x: unameLabel.frame.origin.x + size.width + 8, y: unameLabel.frame.origin.y, width: 16, height: 16))
//                setFriendCommentBtn.setImage(UIImage(named: "edit"), forState: .Normal)
//                scrollView.addSubview(setFriendCommentBtn)
//            }
            
        }
        
        
        subLabel = UILabel(frame: CGRect(x: unameLabel.frame.origin.x + 5, y: bgImgView.frame.origin.y + bgImgView.frame.height, width: unameLabel.frame.width, height: 20))
        subLabel?.textColor = UIColor.grayColor()
        subLabel?.font = UIFont.systemFontOfSize(12)
        scrollView.addSubview(subLabel!)
        subLabel?.text = ""
        
        infoTableView = UITableView(frame: CGRect(x: 0, y: avatar.frame.origin.y + avatar.frame.height + 16, width: view.frame.width, height: 88))
        infoTableView.alpha = 0
        scrollView.addSubview(infoTableView)
        infoTableView.allowsSelection = false
        infoTableView.delegate = self
        infoTableView.dataSource = self
        
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
                                    let showText = json?.objectForKey("uname") as? String
                                    self.unameLabel.text = showText
//                                    if showText != nil{
//                                        let size = NSString(string: showText!).boundingRectWithSize(CGSize(width: self.unameLabel.frame.width, height: self.unameLabel.frame.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self.unameLabel.font], context: nil)
//                                        self.setFriendCommentBtn = UIButton(frame: CGRect(x: self.unameLabel.frame.origin.x + size.width + 8, y: self.unameLabel.frame.origin.y, width: 16, height: 16))
//                                        self.setFriendCommentBtn.setImage(UIImage(named: "edit"), forState: .Normal)
//                                        self.scrollView.addSubview(self.setFriendCommentBtn)
//                                    }
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
                                
                                var infoTableHeight:CGFloat = 0
                                if json?.objectForKey("birthday") != nil{
                                    if ((json?.objectForKey("birthday") as? String) != nil){
                                        if self.infosInTable == nil{
                                            self.infosInTable = NSMutableDictionary()
                                        }
                                        self.infosInTable?.setValue(json?.objectForKey("birthday") as? String, forKey: "birthday")
                                        self.infoTableView.alpha = 1
                                        infoTableHeight += 44
                                    }
                                }
                                
                                if json?.objectForKey("description") != nil{
                                    if ((json?.objectForKey("description") as? String) != nil){
                                        if self.infosInTable == nil{
                                            self.infosInTable = NSMutableDictionary()
                                        }
                                        self.infosInTable?.setValue(json?.objectForKey("description") as? String, forKey: "description")
                                        self.infoTableView.alpha = 1
                                        let size = NSString(string: json?.objectForKey("description") as! String).boundingRectWithSize(CGSize(width: 200, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
                                        print(size.height)
                                        
                                        self.descriptionHeight = size.height + 27
                                        infoTableHeight += self.descriptionHeight
                                    }
                                }
                                self.infoTableView.frame = CGRect(x: 0, y: self.infoTableView.frame.origin.y, width: self.view.frame.width, height: infoTableHeight)
                                self.infoTableView.reloadData()
                                
                                
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
                            let returnCode = NSString(data:data, encoding: NSUTF8StringEncoding)
                            dispatch_async(dispatch_get_main_queue(), {
                                if returnCode == "1"{
                                    self.friendRelation = .Friend
                                }else if returnCode == "2" {
                                    self.friendRelation = .BlackList
                                }
                                var toolBarItems:[UIBarButtonItem] = []
                                switch self.friendRelation {
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
                                case .BlackList:
                                    toolBarItems.append(UIBarButtonItem(image: UIImage(named: "addFriend"), style: .Plain, target: self, action: #selector(UDUserViewController.gotoAddFriend)))
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
        
        // MARK: 生成好友请求信息
        if NSUserDefaults.standardUserDefaults().objectForKey("reqMsg") == nil{
            let infoResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getUserInfo.php?uid=\(myUID!)")!)
            NSURLConnection.sendAsynchronousRequest(infoResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        if json != nil{
                            if json!.objectForKey("error") == nil{
                                self.reqMsg = "我是\(json?.objectForKey("uname") as! String)"
                                NSUserDefaults.standardUserDefaults().setObject(self.reqMsg, forKey: "reqMsg")
                            }
                        }
                    }
                }
            })
            
        }else{
            reqMsg = "\(NSUserDefaults.standardUserDefaults().objectForKey("reqMsg") as! String)"
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if infosInTable != nil{
            return (infosInTable?.count)!
        }
        return 0
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1{
            return descriptionHeight
        }
        return 44
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "info")
        if infosInTable != nil{
            switch indexPath.row {
            case 0:
                if infosInTable?.objectForKey("birthday") != nil{
                    cell.textLabel?.text = "生日"
                    let subLabel = UILabel(frame: CGRect(x: view.frame.width - 116, y: 8, width: 100, height: 28))
                    subLabel.font = UIFont.systemFontOfSize(14)
                    subLabel.textColor = UIColor.grayColor()
                    subLabel.textAlignment = .Right
//            subLabel.backgroundColor = UIColor.greenColor()
                    cell.addSubview(subLabel)
                    subLabel.text = infosInTable?.objectForKey("birthday") as? String
                }
                
                break
            case 1:
                if infosInTable?.objectForKey("description") != nil{
                    cell.textLabel?.text = "个性签名"
                    
                    let subLabel = UILabel(frame: CGRect(x: view.frame.width - 216, y: 8, width: 200, height: descriptionHeight - 16))
                    subLabel.font = UIFont.systemFontOfSize(14)
                    subLabel.textColor = UIColor.grayColor()
                    subLabel.textAlignment = .Right
//                    subLabel.backgroundColor = UIColor.greenColor()
                    subLabel.numberOfLines = 0
                    
                    cell.addSubview(subLabel)
                    subLabel.text = infosInTable?.objectForKey("description") as? String
                }
                break
            default:
                break
            }
        }
        
        return cell
    }

    func gotoChat(){
        let chatVC = UDChatViewController()
        chatVC.myUID = myUID
        chatVC.myAcode = acode
        chatVC.chatroomName = unameLabel.text
        chatVC.chatroomID = "user\(thisUid!)"
        // MARK: pop到消息界面再进聊天界面
        if justPop {
            navigationController?.popViewControllerAnimated(true)
        }else{
            
            if needToTab{
                tabBarController?.selectedIndex = 0
                navigationController?.popToRootViewControllerAnimated(false)
            }else{
                navigationController?.popToRootViewControllerAnimated(false)
            }
            rootVC?.pushToChatVCImd(chatVC)
        }
        
    }
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        if buttonIndex == 1{
//            print("add friend with \(alertView.textFieldAtIndex(0)?.text)")
//        }
//    }
    func gotoAddFriend(){
//        let alert = UIAlertView(title: nil, message: "输入验证信息", delegate: self, cancelButtonTitle: "取消")
//        alert.addButtonWithTitle("发送")
//        alert.alertViewStyle = .PlainTextInput
//        alert.textFieldAtIndex(0)?.text = reqMsg
//        alert.show()
        
        let postVC = UDPostViewController(hint: "输入验证信息", placeholder: reqMsg, charsLimit: 30, requestURL: "http://119.29.225.180/notecloud/sendFriendReq.php")
        postVC.delegate = self
        postVC.navigationTitle = "添加好友"
        navigationController?.pushViewController(postVC, animated: true)
    }
    func postViewControllerSetBody(postVC: UDPostViewController, content: String?) -> String? {
        switch postVC.request {
        case "http://119.29.225.180/notecloud/sendFriendReq.php":
            return "uid=\(myUID!)&acode=\(acode!)&toid=\(thisUid!)&msg=\(content!)"
        case "http://119.29.225.180/notecloud/setFriendComment.php":
            return "uid=\(myUID!)&acode=\(acode!)&toid=\(thisUid!)&comment=\(content!)"
        default:
            return nil
        }
        
    }
    func postViewControllerDidSucceed(postVC: UDPostViewController, content: String?) {
        navigationController?.popViewControllerAnimated(true)
        switch postVC.request {
        case "http://119.29.225.180/notecloud/sendFriendReq.php":
            // MARK: 好友请求发送成功
            reqMsg = content!
            NSUserDefaults.standardUserDefaults().setObject(reqMsg, forKey: "reqMsg")
            UIAlertView(title: "请求发送成功", message: nil, delegate: nil, cancelButtonTitle: "好").show()
            break
        case "http://119.29.225.180/notecloud/setFriendComment.php":
            // MARK: 备注修改成功
            
            if content == "" {
                friendComments?.removeObjectForKey("\(thisUid!)")
                unameLabel.text = navigationItem.title
            }else{
                friendComments?.setValue(content!, forKey: "\(thisUid!)")
                unameLabel.text = content!
            }
            
            
            friendComments?.writeToFile("\(caches)/friend_comments.plist", atomically: true)
            break
        default:
            break
        }
    }
    func postViewControllerDidFailed(postVC: UDPostViewController, content: String?) {
        UIAlertView(title: "操作失败", message: nil, delegate: nil, cancelButtonTitle: "好").show()
    }
    func moreMenu(){
        switch friendRelation {
        case .Myself:
            break
        case .Friend:
            let asf = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            asf.addButtonWithTitle("修改备注")
            asf.addButtonWithTitle("删除好友")
            asf.addButtonWithTitle("取消")
            asf.cancelButtonIndex = asf.numberOfButtons - 1
            asf.destructiveButtonIndex = asf.numberOfButtons - 2
            asf.showInView(view)
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
        switch friendRelation {
        case .Myself:
            break
        case .Friend:
            switch buttonIndex {
            case 0:
                // MARK: 修改备注
                let postVC = UDPostViewController(hint: "输入备注名称", placeholder: unameLabel.text, charsLimit: 10, requestURL: "http://119.29.225.180/notecloud/setFriendComment.php")
                postVC.delegate = self
                postVC.navigationTitle = "修改备注"
                navigationController?.pushViewController(postVC, animated: true)
                break
            case 1:
                // MARK: 删除好友提示
                let deleteAlert = UIAlertView(title: "确认删除好友?", message: "删除好友会保留聊天记录与缓存图片，可手动删除", delegate: self, cancelButtonTitle: nil)
                deleteAlert.addButtonWithTitle("是")
                deleteAlert.addButtonWithTitle("否")
                deleteAlert.cancelButtonIndex = 1
                deleteAlert.tag = 100
                deleteAlert.show()
                
                break
            default:
                break
            }
            break
        case .Stranger:
            if buttonIndex == 0{
                // MARK: 添加黑名单提示
                let deleteAlert = UIAlertView(title: "添加到黑名单?", message: "对方将无法添加你为好友，可防止该用户骚扰", delegate: self, cancelButtonTitle: nil)
                deleteAlert.addButtonWithTitle("是")
                deleteAlert.addButtonWithTitle("否")
                deleteAlert.cancelButtonIndex = 1
                deleteAlert.tag = 200
                deleteAlert.show()
            }
            
            break
        case .BlackList:
            if buttonIndex == 0{
                // MARK: 移除黑名单提示
                let deleteAlert = UIAlertView(title: "移出黑名单?", message: "将把该用户移出黑名单", delegate: self, cancelButtonTitle: nil)
                deleteAlert.addButtonWithTitle("是")
                deleteAlert.addButtonWithTitle("否")
                deleteAlert.cancelButtonIndex = 1
                deleteAlert.tag = 300
                deleteAlert.show()
            }
            
            break
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch alertView.tag {
        case 100:
            if buttonIndex == 0{
                print("删除")
                // MARK: 删除好友
                let deleteResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/deleteFriend.php")!)
                deleteResq.HTTPMethod = "POST"
                deleteResq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(acode!)&toid=\(thisUid!)").dataUsingEncoding(NSUTF8StringEncoding)
                NSURLConnection.sendAsynchronousRequest(deleteResq, queue: NSOperationQueue(), completionHandler: { (resp:
                    NSURLResponse?, returnData:NSData?, err:NSError?) in
                    var isSuccess = false
                    if err == nil{
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if json != nil{
                                if json?.objectForKey("error") == nil{
                                    isSuccess = true
                                    // 删除首页信息
                                    let homePageMsg = NSMutableArray(contentsOfFile: "\(self.caches)/msg.plist")
                                    var index = 0
                                    for item in homePageMsg!{
                                        let msgItem = item as! NSDictionary
                                        if msgItem.objectForKey("send_from") as! String == "user" && msgItem.objectForKey("fromid") as! String == "\(self.thisUid!)"{
                                            homePageMsg?.removeObjectAtIndex(index)
                                            homePageMsg?.writeToFile("\(self.caches)/msg.plist", atomically: true)
                                            break
                                        }
                                        index += 1
                                    }
                                    
                                    // 删除好友备注
                                    self.friendComments?.removeObjectForKey("\(self.thisUid!)")
                                    self.unameLabel.text = self.navigationItem.title
                                    self.friendComments?.writeToFile("\(self.caches)/friend_comments.plist", atomically: true)
                                    
                                    // 调整本页面的好友关系
                                    self.friendRelation = .Stranger
                                    
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let deleteAlert = UIAlertView(title: "操作成功", message: nil, delegate: self, cancelButtonTitle: "好")
                                        deleteAlert.tag = 101
                                        deleteAlert.show()
                                        
                                        self.unameLabel.text = self.navigationItem.title
                                        
                                        var toolBarItems:[UIBarButtonItem] = []
                                        toolBarItems.append(UIBarButtonItem(image: UIImage(named: "addFriend"), style: .Plain, target: self, action: #selector(UDUserViewController.gotoAddFriend)))
                                        //                                    toolBarItems.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil))
                                        toolBarItems.append(UIBarButtonItem(image: UIImage(named: "more"), style: .Plain, target: self, action: #selector(UDUserViewController.moreMenu)))
                                        
                                        self.rightToolBar.setItems(toolBarItems, animated: true)
                                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightToolBar)
                                        
                                    })
                                }
                            }
                        }
                    }
                    if !isSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            let deleteAlert = UIAlertView(title: "操作失败", message: nil, delegate: self, cancelButtonTitle: "好")
                            deleteAlert.show()
                        })
                    }
                })
 
            }
            break
        case 101:
            navigationController?.popToRootViewControllerAnimated(true)
            break
        case 200:
            if buttonIndex == 0{
                print("黑名单")
                // MARK: 添加黑名单操作
                let addBLResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setBlackList.php")!)
                addBLResq.HTTPMethod = "POST"
                addBLResq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(acode!)&toid=\(thisUid!)").dataUsingEncoding(NSUTF8StringEncoding)
                NSURLConnection.sendAsynchronousRequest(addBLResq, queue: NSOperationQueue(), completionHandler: { (resp:
                    NSURLResponse?, returnData:NSData?, err:NSError?) in
                    var isSuccess = false
                    if err == nil{
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if json != nil{
                                if json?.objectForKey("error") == nil{
                                    isSuccess = true
                                    self.friendRelation = .BlackList
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let addBLAlert = UIAlertView(title: "操作成功", message: nil, delegate: self, cancelButtonTitle: "好")
                                        addBLAlert.show()
                                        
                                    })
                                    
                                }
                            }
                        }
                    }
                    if !isSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            let addBLAlert = UIAlertView(title: "操作失败", message: nil, delegate: self, cancelButtonTitle: "好")
                            addBLAlert.show()
                        })
                    }
                })
            }
            break
        case 300:
            if buttonIndex == 0{
                print("移出黑名单")
                // MARK: 移除黑名单操作
                let rmBLResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/removeBlackList.php")!)
                rmBLResq.HTTPMethod = "POST"
                rmBLResq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(acode!)&toid=\(thisUid!)").dataUsingEncoding(NSUTF8StringEncoding)
                NSURLConnection.sendAsynchronousRequest(rmBLResq, queue: NSOperationQueue(), completionHandler: { (resp:
                    NSURLResponse?, returnData:NSData?, err:NSError?) in
                    var isSuccess = false
                    if err == nil{
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if json != nil{
                                if json?.objectForKey("error") == nil{
                                    isSuccess = true
                                    self.friendRelation = .Stranger
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let rmBLAlert = UIAlertView(title: "操作成功", message: nil, delegate: self, cancelButtonTitle: "好")
                                        rmBLAlert.show()
                                        
                                    })
                                    
                                }
                            }
                        }
                    }
                    if !isSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            let rmBLAlert = UIAlertView(title: "操作失败", message: nil, delegate: self, cancelButtonTitle: "好")
                            rmBLAlert.show()
                        })
                    }
                })
            }
            break
        default:
            break
        }
    }
    
    func bgImgTap(){
        let bgImgVC = PVImgViewController(imagePrview: bgImgView.imageView?.image)
        hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(bgImgVC, animated: true)
    }
    
    func avatarTap(){
        let bgImgVC = PVImgViewController(imagePrview: avatar.imageView?.image)
        bgImgVC.requestURL = "http://119.29.225.180/notecloud/getAvatarFull.php?uid=\(thisUid!)&type=user"
        hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(bgImgVC, animated: true)
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

