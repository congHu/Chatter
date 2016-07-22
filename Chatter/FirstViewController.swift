//
//  FirstViewController.swift
//  Chatter
//
//  Created by David on 16/7/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var loginVC:UDLoginViewController!
    var uid:String?
    var active:String?
    var tableView:UITableView!
    var msg:NSMutableArray?
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var numOfUnread = 0
    
    
    @IBOutlet var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginVC = UDLoginViewController()
        print(NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .UserDomainMask, true))
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
            active = user?.objectForKey("activecode") as? String
            print("uid: \(uid!) | acode: \(active!)")
        }
        navBar.title = "连接中..."
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FirstViewController.timerElapse), userInfo: nil, repeats: true)
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        _ = try? NSFileManager.defaultManager().createDirectoryAtPath("\(caches)/avatar", withIntermediateDirectories: true, attributes: nil)
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/msg.plist"){
            msg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
            
        }else{
            msg = NSMutableArray()
            msg?.writeToFile("\(caches)/msg.plist", atomically: true)
        }
        
        for item in msg!{
            let msgItem = item as! NSDictionary
            numOfUnread += msgItem.objectForKey("unread") as! Int
        }
        if self.numOfUnread != 0{
            self.navBar.title = "消息(\(self.numOfUnread))"
            self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
        }else{
            self.navBar.title = "消息"
            self.tabBarController?.tabBar.items?.first!.badgeValue = ""
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    // MARK: 定时检查新消息
    func timerElapse(){
        // 请求
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
                                        let lastUnread = dic.objectForKey("unread") as! Int
                                        unread += lastUnread
                                        reMsg?.removeAtIndex(ins)
                                        break
                                    }
                                }
                                msgItem.setObject(unread, forKey: "unread")
                                
                                self.numOfUnread += unread
                                reMsg?.append(msgItem)
                                
                                
                                // 分发消息到各个列表
                                let currentPath = "\(self.caches)/\(sendFromType)\(sendFromID).plist"
                                let dialogList:NSMutableArray?
                                if NSFileManager.defaultManager().fileExistsAtPath(currentPath){
                                    dialogList = NSMutableArray(contentsOfFile: currentPath)
                                }else{
                                    dialogList = NSMutableArray()
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
                            self.navBar.title = "消息(\(self.numOfUnread))"
                            self.tableView.reloadData()
                            self.tabBarController?.tabBar.items?.first!.badgeValue = "\(self.numOfUnread)"
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (msg?.count)!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let msgItem = msg?.objectAtIndex(indexPath.row) as? NSDictionary
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "sd")
        
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
        
        cell.addSubview(avatar)
        
        let timeLabel = UILabel(frame: CGRect(x: cell.frame.width - 68, y: 8, width: 60, height: 20))
        timeLabel.text = UDChatDate.shortTime(msgItem?.objectForKey("time") as! String)
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont.systemFontOfSize(12)
        timeLabel.textAlignment = .Right
        //timeLabel.backgroundColor = UIColor.greenColor()
        
        cell.addSubview(timeLabel)
        
        let unreadInt = msgItem?.objectForKey("unread") as! Int
        
        if unreadInt != 0{
            let unreadBadge = UILabel(frame: CGRect(x: cell.frame.width - 28, y: 36, width: 20, height: 20))
            unreadBadge.text = "\(unreadInt)"
            unreadBadge.backgroundColor = UIColor.redColor()
            unreadBadge.textColor = UIColor.whiteColor()
            unreadBadge.textAlignment = .Center
            unreadBadge.layer.cornerRadius = 10
            unreadBadge.layer.masksToBounds = true
            cell.addSubview(unreadBadge)
        }
        
        let chatTitle = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: cell.frame.width - 100 - avatar.frame.width, height: 20))
        chatTitle.text = msgItem?.objectForKey("chatname") as? String
        //chatTitle.backgroundColor = UIColor.greenColor()
        cell.addSubview(chatTitle)
        
        let textPV = UILabel(frame: CGRect(x: chatTitle.frame.origin.x, y: 36, width: cell.frame.width - 60 - avatar.frame.width, height: 20))
        //textPV.backgroundColor = UIColor.greenColor()
        textPV.textColor = UIColor.grayColor()
        textPV.text = msgItem?.objectForKey("body") as? String
        cell.addSubview(textPV)
        
        
        
        
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
        
        hidesBottomBarWhenPushed = true
        let chatVC = UDChatViewController()
        chatVC.myUID = uid
        chatVC.chatroomName = msgItem?.objectForKey("chatname") as? String
        chatVC.chatroomID = "\(msgItem?.objectForKey("send_from") as! String)\(msgItem?.objectForKey("fromid") as! String)"
        chatVC.view.backgroundColor = UIColor.whiteColor()
        navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidesBottomBarWhenPushed = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

