//
//  SecondViewController.swift
//  Chatter
//
//  Created by David on 16/7/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var tableView:UITableView!
    var friendList:NSMutableArray!
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var uid:String?
    var active:String?
    var indexKeys:[String] = []
    var numOfRows:[Int] = []
//    var friendComments:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        // MARK: 读取本地列表
        let friendFilePath = "\(caches)/friends.plist"
        
        if NSFileManager.defaultManager().fileExistsAtPath(friendFilePath){
            friendList = NSMutableArray(contentsOfFile: friendFilePath)
        }else{
            friendList = NSMutableArray()
            friendList.writeToFile(friendFilePath, atomically: true)
        }
        
        // 生成分组索引
        //indexKeys.append("功能")
        for elem in friendList{
            let item = (elem as! NSDictionary).objectForKey("pinyin") as! NSString
            
            var upperChar = ""
            if item == ""{
                upperChar = "#"
            }else{
                upperChar = item.substringToIndex(1).uppercaseString
                if Int(upperChar) != nil{
                    upperChar = "#"
                }
            }
            
            var isExist = false
            for char in indexKeys{
                if char == upperChar{
                    isExist = true
                    break
                }
            }
            if !isExist{
                indexKeys.append(upperChar)
            }
        }
        print(indexKeys)
        // 生成每组的行数
        for i in 0..<indexKeys.count{
            var numOfRow = 0
            for elem in friendList{
                let item = (elem as! NSDictionary).objectForKey("pinyin") as! NSString
                var upperChar = ""
                if item == ""{
                    upperChar = "#"
                }else{
                    upperChar = item.substringToIndex(1).uppercaseString
                    if Int(upperChar) != nil{
                        upperChar = "#"
                    }
                }
                if upperChar == indexKeys[i]{
                    numOfRow += 1
                }
            }
            numOfRows.append(numOfRow)
        }
        
        
        // 获取当前用户uid
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            let loginVC = UDLoginViewController()
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
            active = user?.objectForKey("activecode") as? String
        }
        
        
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let friendFilePath = "\(caches)/friends.plist"
        // MARK: 获取好友列表
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getFriendList.php")!)
        resq.HTTPMethod = "POST"
        resq.HTTPBody = NSString(string: "uid=\(uid!)&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSArray
                    self.friendList = NSMutableArray(array: jsonObj!)
                    
                    //排序
                    self.friendList.sortUsingFunction({ (first:AnyObject, second:AnyObject, context:UnsafeMutablePointer<Void>) -> Int in
                        let Obi = first as! NSDictionary
                        let Obj = second as! NSDictionary
                        if (Obi.objectForKey("pinyin") as! String) < (Obj.objectForKey("pinyin") as! String){
                            return -1
                        }else if (Obi.objectForKey("pinyin") as! String) > (Obj.objectForKey("pinyin") as! String){
                            return 1
                        }else{
                            return 0
                        }
                        }, context: nil)
                    //生成索引
                    self.indexKeys.removeAll()
                    //self.indexKeys.append("功能")
                    for elem in self.friendList{
                        let item = (elem as! NSDictionary).objectForKey("pinyin") as! NSString
                        var upperChar = ""
                        if item == ""{
                            upperChar = "#"
                        }else{
                            upperChar = item.substringToIndex(1).uppercaseString
                            if Int(upperChar) != nil{
                                upperChar = "#"
                            }
                        }
                        
                        var isExist = false
                        for char in self.indexKeys{
                            if char == upperChar{
                                isExist = true
                                break
                            }
                        }
                        if !isExist{
                            self.indexKeys.append(upperChar)
                        }
                    }
                    //每个索引组的行数
                    self.numOfRows.removeAll()
                    for i in 0..<self.indexKeys.count{
                        var numOfRow = 0
                        for elem in self.friendList{
                            
                            let item = (elem as! NSDictionary).objectForKey("pinyin") as! NSString
                            var upperChar = ""
                            if item == ""{
                                upperChar = "#"
                            }else{
                                upperChar = item.substringToIndex(1).uppercaseString
                                if Int(upperChar) != nil{
                                    upperChar = "#"
                                }
                            }
                            if upperChar == self.indexKeys[i]{
                                numOfRow += 1
                            }
                            
                        }
                        self.numOfRows.append(numOfRow)
                    }
                    self.friendList.writeToFile(friendFilePath, atomically: true)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        }
        
        //获取备注列表
        /*
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/friend_comments.plist"){
            friendComments = NSDictionary(contentsOfFile: "\(caches)/friend_comments.plist")
        }else{
            let friendComReq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getFriendComments.php")!)
            friendComReq.HTTPMethod = "POST"
            friendComReq.HTTPBody = NSString(string: "uid=\(uid!)&&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(friendComReq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let jsonObj = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        self.friendComments = NSDictionary(dictionary: jsonObj!)
                        self.friendComments?.writeToFile("\(self.caches)/friend_comments.plist", atomically: true)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
 */
        
        
        tableView.reloadData()
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexKeys.count + 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1 // MARK: 功能区行数
        }else{
            return numOfRows[section-1]
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        
        return indexKeys
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0{
            return indexKeys[section-1]
        }
        return nil
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "friend")
        if indexPath.section > 0{
            if friendList.count != 0{
                let thisIndex = indexPath.row + (indexPath.section-1)*numOfRows[indexPath.section-1]
                let friendItem = friendList.objectAtIndex(thisIndex) as? NSDictionary
                
                let avatar = UIImageView(frame: CGRect(x: 16, y: 8, width: cell.frame.height - 16, height: cell.frame.height - 16))
                avatar.backgroundColor = UIColor.grayColor()
                var fid = friendItem?.objectForKey("uid") as? String
                if friendItem?.objectForKey("uid") as? String == nil{
                    fid = "\(friendItem?.objectForKey("uid") as! Int)"
                }
                let avatarImgPath = "\(caches)/avatar/user\(fid!).jpg"
                if NSFileManager.defaultManager().fileExistsAtPath(avatarImgPath){
                    avatar.image = UIImage(contentsOfFile: avatarImgPath)
                }else{
                    NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(fid!)&type=user")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
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
                
                let namelabel = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: cell.frame.width - avatar.frame.width - 32, height: avatar.frame.height))
                namelabel.text = friendItem?.objectForKey("uname") as? String
//                if friendComments?.objectForKey("\(fid!)") != nil{
//                    namelabel.text = friendComments?.objectForKey("\(fid!)") as? String
//                }
                
                cell.addSubview(namelabel)
            }
        }else if indexPath.section == 0{
            if indexPath.row == 0{
                let avatar = UIImageView(frame: CGRect(x: 16, y: 8, width: cell.frame.height - 16, height: cell.frame.height - 16))
                avatar.backgroundColor = UIColor.grayColor()
                avatar.image = UIImage(named: "addFriendGreen")
                cell.addSubview(avatar)
                let namelabel = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: cell.frame.width - avatar.frame.width - 32, height: avatar.frame.height))
                namelabel.text = "添加好友"
                cell.addSubview(namelabel)
            }
        }
        
        
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: 点击进入用户详情
        if indexPath.section == 0{
            let searchVC = UDSearchViewController()
            searchVC.myUID = uid
            searchVC.myAcode = active
            searchVC.pushFromTab2 = true
            searchVC.rootVC = UDSingleChat.rootVC
            searchVC.view.backgroundColor = UIColor.whiteColor()
            hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(searchVC, animated: true)
        }else{
            let thisIndex = indexPath.row + (indexPath.section-1)*numOfRows[indexPath.section-1]
            let friendItem = friendList.objectAtIndex(thisIndex) as? NSDictionary
            let userVC = UDUserViewController()
            // MARK: 进入用户详情
            if friendItem?.objectForKey("uid") as? String != nil{
                userVC.thisUid = friendItem?.objectForKey("uid") as? String
            }else{
                userVC.thisUid = "\(friendItem?.objectForKey("uid") as! Int)"
            }
            
            userVC.myUID = uid
            userVC.acode = active
            userVC.needToTab = true
            userVC.rootVC = UDSingleChat.rootVC
            hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(userVC, animated: true)
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


}

