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
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func timerElapse(){
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/fetchMsg.php")!)
        resq.HTTPMethod = "POST"
        resq.HTTPBody = NSString(string: "uid=\(uid!)&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSArray
                    if jsonObj!!.count != 0{
                        var reMsg = self.msg?.reverseObjectEnumerator().allObjects
                        for item in jsonObj!!{
                            let msgItem = item as! NSDictionary
                            let sendFromType = msgItem.objectForKey("send_from") as! String
                            let sendFromID = msgItem.objectForKey("fromid") as! String
                            for ins in 0..<reMsg!.count{
                                let dic = reMsg![ins] as! NSDictionary
                                if dic.objectForKey("send_from") as! String == sendFromType && dic.objectForKey("fromid") as! String == sendFromID{
                                    reMsg?.removeAtIndex(ins)
                                    break
                                }
                            }
                            reMsg?.append(msgItem)
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
                        self.msg?.removeAllObjects()
                        reMsg = (reMsg! as NSArray).reverseObjectEnumerator().allObjects
                        for item in reMsg!{
                            self.msg?.addObject(item)
                        }
                        self.msg?.writeToFile("\(self.caches)/msg.plist", atomically: true)
                        // TODO: 处理未读数量小红点
                        dispatch_async(dispatch_get_main_queue(), {
                            self.navBar.title = "消息"
                            self.tableView.reloadData()
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
        // TODO: 异步处理头像显示
        let avatar = UIImageView(frame: CGRect(x: 16, y: 8, width: 48, height: 48))
        avatar.backgroundColor = UIColor.grayColor()
        cell.addSubview(avatar)
        
        let chatTitle = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: cell.frame.width - 40 - avatar.frame.width, height: 20))
        chatTitle.text = msgItem?.objectForKey("chatname") as? String
        cell.addSubview(chatTitle)
        
        let textPV = UILabel(frame: CGRect(x: chatTitle.frame.origin.x, y: 36, width: chatTitle.frame.width, height: 20))
        textPV.textColor = UIColor.grayColor()
        textPV.text = msgItem?.objectForKey("body") as? String
        cell.addSubview(textPV)
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        hidesBottomBarWhenPushed = true
        let chatVC = UDChatViewController()
        // TODO: 这是假数据。准备传入真实uid数据
        chatVC.chatroomName = "\(indexPath.row)"
        chatVC.chatroomID = "324"
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

