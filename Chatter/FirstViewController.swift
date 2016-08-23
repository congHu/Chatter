//
//  FirstViewController.swift
//  Chatter
//
//  Created by David on 16/7/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DRMovePanViewDelegate, CellSwipeButtonsViewDelgate, UIScrollViewDelegate, UITabBarControllerDelegate {
    
//    var loginVC:UDLoginViewController!
    var uid:String?
    var active:String?
    var tableView:UITableView!
    var msg:NSMutableArray?
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var numOfUnread = 0
    var friendComments:NSDictionary?
    
    var currentSwipedCell:UIView?
    var currentSwipingCell:UIView?
    var scrollViewDragging = false
    var swipeButtonsViews:[CellSwipeButtonsView] = []
    
    var inChatRoom:String?
    
    @IBOutlet var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .UserDomainMask, true))
        UDSingleChat.rootVC = self
        
        //读取主页消息
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/msg.plist"){
            msg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
            
        }else{
            msg = NSMutableArray()
            msg?.writeToFile("\(caches)/msg.plist", atomically: true)
        }
        
        tableView = UITableView(frame: view.frame)
        // ios7
        if NSString(string: UIDevice.currentDevice().systemVersion).floatValue < 8.0{
            tableView.frame = CGRect(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 113)
        }
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            let loginVC = UDLoginViewController()
            presentViewController(loginVC, animated: false, completion: nil)
        }
        
        
        navBar.title = "连接中..."
        
        
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FirstViewController.timerElapse), userInfo: nil, repeats: true)
        
        
        //头像文件夹
        _ = try? NSFileManager.defaultManager().createDirectoryAtPath("\(caches)/avatar", withIntermediateDirectories: true, attributes: nil)
        //封面文件夹
        _ = try? NSFileManager.defaultManager().createDirectoryAtPath("\(caches)/bg_img", withIntermediateDirectories: true, attributes: nil)
        //聊天图片文件夹
        _ = try? NSFileManager.defaultManager().createDirectoryAtPath("\(caches)/chat_img", withIntermediateDirectories: true, attributes: nil)
        
        
        navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(FirstViewController.gotoSearch))
        
        self.tabBarController?.delegate = self
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //是否登录。获取uid和acode
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            let loginVC = UDLoginViewController()
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
            active = user?.objectForKey("activecode") as? String
            print("uid: \(uid!) | acode: \(active!)")
            
            //读取主页消息
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/msg.plist"){
                msg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
                
            }else{
                msg = NSMutableArray()
                msg?.writeToFile("\(caches)/msg.plist", atomically: true)
            }
            //未读
            numOfUnread = 0
            for item in msg!{
                let msgItem = item as! NSDictionary
                let unread = msgItem.objectForKey("unread") as! Int
                numOfUnread += unread
            }
            if self.numOfUnread != 0{
                self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
            }else{
                self.tabBarController?.tabBar.items?.first!.badgeValue = nil
            }
            
            
            //获取备注列表

            let friendComReq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getFriendComments.php")!)
            friendComReq.HTTPMethod = "POST"
            friendComReq.HTTPBody = NSString(string: "uid=\(uid!)&&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(friendComReq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
//                        print(NSString(data: data, encoding: NSUTF8StringEncoding))
                        let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        let jsonDict = jsonObj as? NSDictionary
                        if jsonDict != nil{
                            self.friendComments = NSDictionary(dictionary: jsonDict!)
                            self.friendComments?.writeToFile("\(self.caches)/friend_comments.plist", atomically: true)
                        }
                        
                    }
                }
            }
            
            
            
            swipeButtonsViews.removeAll()
            tableView.reloadData()
            inChatRoom = nil
        }
        
        
        
        
        
    }
    
    
    // MARK: 定时检查新消息
    func timerElapse(){
        // 请求
        if uid != nil && active != nil{
            let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/fetchMsg.php")!)
            resq.HTTPMethod = "POST"
            resq.HTTPBody = NSString(string: "uid=\(uid!)&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSMutableArray
                        if jsonObj != nil{
                            if jsonObj?.count != 0{ // 是否有消息
                                var reMsg = self.msg?.reverseObjectEnumerator().allObjects
                                self.numOfUnread = 0
                                for item in jsonObj!{
                                    let msgItem = NSMutableDictionary(dictionary: item as! NSDictionary)
                                    
                                    let sendFromType = msgItem.objectForKey("send_from") as! String
                                    let sendFromID = msgItem.objectForKey("fromid") as! String
                                    
                                    
                                    // 找出列表里面的同类项，放到列表前面
                                    var unread = 1
                                    for ins in 0..<reMsg!.count{
                                        let dic = reMsg![ins] as! NSDictionary
                                        if dic.objectForKey("send_from") as! String == sendFromType && dic.objectForKey("fromid") as! String == sendFromID{
                                            unread = dic.objectForKey("unread") as! Int + 1
                                            reMsg?.removeAtIndex(ins)
                                            break
                                        }
                                    }
                                    // MARK: 如果在聊天界面内，不刷新未读数量
                                    if self.inChatRoom != nil{
                                        if self.inChatRoom == "\(sendFromType)\(sendFromID)" {
                                            unread = 0
                                        }
                                    }
                                    msgItem.setObject(unread, forKey: "unread")
                                    self.numOfUnread += unread
//                                    print(self.numOfUnread)
                                    
                                    reMsg?.append(msgItem)
                                    
                                    let msgTime = msgItem.objectForKey("time") as! String
                                    
                                    // 分发消息到各个列表
                                    let currentPath = "\(self.caches)/\(sendFromType)\(sendFromID).plist"
                                    let dialogList:NSMutableArray?
                                    if NSFileManager.defaultManager().fileExistsAtPath(currentPath){
                                        dialogList = NSMutableArray(contentsOfFile: currentPath)
                                    }else{
                                        dialogList = NSMutableArray()
                                    }
                                    var requireMarker = true
                                    
                                    if dialogList?.count != 0{
                                        let lastTime = (dialogList?.lastObject as! NSDictionary).objectForKey("time") as! String
                                        requireMarker = UDChatDate.isTimeToAddTimeMarker(msgTime, lastTime)
                                    }
                                    if requireMarker{
                                        let timeMarker = NSMutableDictionary()
                                        timeMarker.setValue("timeMark", forKey: "send_from")
                                        timeMarker.setValue("0", forKey: "fromid")
                                        timeMarker.setValue("string", forKey: "type")
                                        timeMarker.setValue(UDChatDate.longTime(msgTime)!, forKey: "body")
                                        timeMarker.setValue(msgTime, forKey: "time")
                                        timeMarker.setValue("\(sendFromType)\(sendFromID)", forKey: "chatname")
                                        dialogList?.addObject(timeMarker)
                                    }
                                    dialogList?.addObject(msgItem)
                                    dialogList?.writeToFile(currentPath, atomically: true)
                                }
                                
                                // 刷新内存，reloadData
                                self.msg?.removeAllObjects()
                                reMsg = (reMsg! as NSArray).reverseObjectEnumerator().allObjects
                                for item in reMsg!{
                                    self.msg?.addObject(item)
                                }
                                self.msg?.writeToFile("\(self.caches)/msg.plist", atomically: true)
                                
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                                if self.numOfUnread != 0{
                                    self.navBar.title = "消息(\(self.numOfUnread))"
                                    self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
                                }else{
                                    self.navBar.title = "消息"
                                    self.tabBarController?.tabBar.items?.first!.badgeValue = nil
                                }
                            })
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            if self.numOfUnread != 0{
                                self.navBar.title = "消息(\(self.numOfUnread))"
                                self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
                            }else{
                                self.navBar.title = "消息"
                                self.tabBarController?.tabBar.items?.first!.badgeValue = nil
                            }
                            
                        })
                        
                    }
                }
            }
        }
        
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (msg?.count)!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let msgItem = msg?.objectAtIndex(indexPath.row) as? NSDictionary
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "sd")
        var buttons:[UIButton] = []
        let delBtn = UIButton(frame: CGRect(x: 50, y: 0, width: 50, height: 64))
        delBtn.backgroundColor = UIColor.redColor()
        delBtn.setTitle("删除", forState: .Normal)
        delBtn.setTitleColor(UIColor(r: 217, g: 217, b: 217, a: 255), forState: .Normal)
        buttons.append(delBtn)
        let cleatRead = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
        cleatRead.backgroundColor = UIColor.grayColor()
        cleatRead.setTitle("已读", forState: .Normal)
        cleatRead.setTitleColor(UIColor(r: 217, g: 217, b: 217, a: 255), forState: .Normal)
        buttons.append(cleatRead)
        let swipeButton = CellSwipeButtonsView(buttons: buttons, indexPath: indexPath)
        swipeButton.delegate = self
        swipeButton.indexPath = indexPath
        cell.addSubview(swipeButton)
        swipeButtonsViews.append(swipeButton)
        
        let msgView = DRMovePanView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        msgView.scaleOnMove = false
        msgView.movableVertical = false
        msgView.delegate = self
        msgView.backgroundColor = UIColor.whiteColor()
        cell.addSubview(msgView)
        let avatar = UIImageView(frame: CGRect(x: 16, y: 8, width: 48, height: 48))
        avatar.backgroundColor = UIColor.grayColor()
        
        // MARK: 异步处理头像显示
        let type = msgItem?.objectForKey("send_from") as! String
        let fid = msgItem?.objectForKey("fromid") as! String
        let avatarImgPath = "\(caches)/avatar/\(type)\(fid).jpg"
        if NSFileManager.defaultManager().fileExistsAtPath(avatarImgPath){
            avatar.image = UIImage(contentsOfFile: avatarImgPath)
        }else{
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(fid)&type=\(type)")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                        if json == nil{
                            dispatch_async(dispatch_get_main_queue(), { 
                                avatar.image = UIImage(data: data)
                                data.writeToFile(avatarImgPath, atomically: true)
                            })
                            
                            
                        }
                    }
                }
            })
        }
        
        msgView.addSubview(avatar)
        
        let timeLabel = UILabel(frame: CGRect(x: view.frame.width - 68, y: 8, width: 60, height: 20))
        timeLabel.text = UDChatDate.shortTime(msgItem?.objectForKey("time") as! String)
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont.systemFontOfSize(12)
        timeLabel.textAlignment = .Right
//        timeLabel.backgroundColor = UIColor.greenColor()
        
        msgView.addSubview(timeLabel)
        
        // 未读
        let unreadInt = msgItem?.objectForKey("unread") as! Int
        
        if unreadInt != 0{
            let unreadBadge = UILabel(frame: CGRect(x: view.frame.width - 28, y: 36, width: 20, height: 20))
            unreadBadge.text = "\(unreadInt)"
            unreadBadge.backgroundColor = UIColor.redColor()
            unreadBadge.textColor = UIColor(r: 217, g: 217, b: 217, a: 255)
            unreadBadge.textAlignment = .Center
            unreadBadge.layer.cornerRadius = 10
            unreadBadge.layer.masksToBounds = true
            msgView.addSubview(unreadBadge)
        }
        
        let chatTitle = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: view.frame.width - 100 - avatar.frame.width, height: 20))
        chatTitle.text = msgItem?.objectForKey("chatname") as? String
        if friendComments?.objectForKey("\(fid)") != nil{
            chatTitle.text = friendComments?.objectForKey("\(fid)") as? String
        }
//        chatTitle.backgroundColor = UIColor.greenColor()
        msgView.addSubview(chatTitle)
        
        let textPV = UILabel(frame: CGRect(x: chatTitle.frame.origin.x, y: 36, width: view.frame.width - 60 - avatar.frame.width, height: 20))
        textPV.textColor = UIColor.grayColor()
        let msgType = msgItem?.objectForKey("type") as? String
        switch msgType! {
        case "string":
            textPV.text = msgItem?.objectForKey("body") as? String
            break
        case "req":
            textPV.text = "请求添加为好友"
            break
        case "image":
            textPV.text = "[图片]"
            break
        case "voice":
            textPV.text = "[语音]"
            break
        case "video":
            textPV.text = "[视频]"
            break
        case "location":
            textPV.text = "[位置]"
            break
        default:
            break
        }
        
        // MARK: 读取草稿
        var draftList:NSMutableDictionary?
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/draft.plist"){
            draftList = NSMutableDictionary(contentsOfFile: "\(caches)/draft.plist")
        }else{
            draftList = NSMutableDictionary()
        }
        let chatType = msgItem?.objectForKey("send_from") as! String
        let chatID = msgItem?.objectForKey("fromid") as! String
        if draftList?.objectForKey("\(chatType)\(chatID)") != nil{
            textPV.text = "[草稿]"
            textPV.text! += draftList?.objectForKey("\(chatType)\(chatID)") as! String
        }
        
        textPV.font = UIFont.systemFontOfSize(14)
//        textPV.backgroundColor = UIColor.greenColor()
        msgView.addSubview(textPV)
        
//        let selBG = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
//        selBG.backgroundColor = UIColor.grayColor()
//        cell.selectedBackgroundView = selBG
        
        
        return cell
    }

    // MARK: 点击进入
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let msgItem = msg?.objectAtIndex(indexPath.row) as? NSMutableDictionary
        numOfUnread -= msgItem?.objectForKey("unread") as! Int
        
        if numOfUnread != 0{
            navBar.title = "消息(\(numOfUnread))"
            self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
        }else{
            navBar.title = "消息"
            self.tabBarController?.tabBar.items?.first!.badgeValue = nil
        }
        
        msgItem?.setObject(0, forKey: "unread")
        msg?.writeToFile("\(caches)/msg.plist", atomically: true)
        
        self.tableView.reloadData()
        
        
        
        let chatVC = UDChatViewController()
        chatVC.myUID = uid
        chatVC.myAcode = active
        chatVC.rootVC = self
        // TODO: 需要考虑群聊的情况
        let chatType = msgItem?.objectForKey("send_from") as! String
        let chatID = msgItem?.objectForKey("fromid") as! String
        
        // MARK: 读取草稿
        var draftList:NSMutableDictionary?
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/draft.plist"){
            draftList = NSMutableDictionary(contentsOfFile: "\(caches)/draft.plist")
        }else{
            draftList = NSMutableDictionary()
        }
        if draftList?.objectForKey("\(chatType)\(chatID)") != nil{
            chatVC.draft = draftList?.objectForKey("\(chatType)\(chatID)") as? String
        }
        
        if chatType == "user"{
            chatVC.chatroomID = "\(chatType)\(chatID)"
            inChatRoom = "\(chatType)\(chatID)"
            chatVC.chatroomName = msgItem?.objectForKey("chatname") as? String
//            if friendComments?.objectForKey("\(chatID)") != nil{
//                chatVC.chatroomName = friendComments?.objectForKey("\(chatID)") as? String
//            }
        }else if chatType.hasPrefix("group"){
            chatVC.chatroomID = "\(chatType)"
            inChatRoom = "\(chatType)"
        }
        if msgItem?.objectForKey("type") as! String == "req"{
            chatVC.notFriendYet = true
        }
        
        chatVC.view.backgroundColor = UIColor.whiteColor()
        
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func pushToChatVCImd(chatVC:UDChatViewController){
        inChatRoom = chatVC.chatroomID
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func gotoSearch(){
        let searchVC = UDSearchViewController()
        searchVC.myUID = uid
        searchVC.myAcode = active
        searchVC.rootVC = self
        searchVC.view.backgroundColor = UIColor.whiteColor()
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func panViewDidMove(panView: DRMovePanView, gesture: UIPanGestureRecognizer) {
        currentSwipingCell = panView
        if scrollViewDragging{
            panView.center.x = view.center.x
        }
        // 限制滑动的距离
        if panView.center.x < view.center.x - 100{
            panView.center.x = view.center.x - 100
        }
        if panView.center.x > view.center.x{
            panView.center.x = view.center.x
        }
    }
    func panViewTouchEnded(panView: DRMovePanView, gesture: UIPanGestureRecognizer) {
        // MARK: 惯性拨开和惯性收回
        if panView.center.x >= view.center.x - 40{
            UIView.animateWithDuration(0.3, animations: { 
                panView.center.x = self.view.center.x
            })
            
        }else if panView.center.x < view.center.x - 40 && panView.center.x >= view.center.x - 100{
            if self.currentSwipedCell != panView{
                self.currentSwipedCell?.center.x = self.view.center.x
            }
            UIView.animateWithDuration(0.3, animations: {
                
                panView.center.x = self.view.center.x - 100
                }, completion: { (finished) in
                    self.currentSwipedCell = panView
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        UIView.animateWithDuration(0.3) { 
//            self.currentSwipedCell?.center.x = self.view.center.x
//        }
//        currentSwipedCell = nil
        if currentSwipingCell != nil{
            currentSwipingCell?.center.x = view.center.x
        }
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.currentSwipedCell?.center.x = self.view.center.x
        currentSwipedCell = nil
        scrollViewDragging = true
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDragging = false
    }
    func panViewShouldRecognizeSimultaneouslyWithGestureRecognizer(gestureRecognizer: UIGestureRecognizer, otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let panGes = gestureRecognizer as! UIPanGestureRecognizer
        let transPoint = panGes.translationInView(view)
//        print(transPoint)
        if fabs(transPoint.x) > fabs(transPoint.y) {
            return false
        }else{
            return true
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidesBottomBarWhenPushed = false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cellSwipeButtonClickedAtIndex(swipeView: CellSwipeButtonsView, indexPath: NSIndexPath?, buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            // MARK: 删除
            msg?.removeObjectAtIndex(indexPath!.row)
            tableView.reloadData()
            msg?.writeToFile("\(caches)/msg.plist", atomically: true)
            break
        case 1:
            // MARK: 已读
            let msgItem = msg?.objectAtIndex(indexPath!.row) as? NSMutableDictionary
            numOfUnread -= msgItem?.objectForKey("unread") as! Int
            
            if numOfUnread != 0{
                navBar.title = "消息(\(numOfUnread))"
                self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
            }else{
                navBar.title = "消息"
                self.tabBarController?.tabBar.items?.first!.badgeValue = nil
            }
            
            msgItem?.setObject(0, forKey: "unread")
            msg?.writeToFile("\(caches)/msg.plist", atomically: true)
            
            self.tableView.reloadData()
            break
        default:
            break
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // TODO: 点击tabbar事件
    }
    
}
class UDSingleChat{
    static var rootVC:FirstViewController?
}

