//
//  UDChatViewController.swift
//  Chatter
//
//  Created by David on 16/7/20.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UDChatBubbleDelegate, PVImgViewControllerDelegate, UIAlertViewDelegate {

    var chatroomID:String?
    var chatroomName:String?
    var myUID:String?
    var myAcode:String?
    var notFriendYet = false
    
    // MARK: 草稿功能
    var draft:String?
    var rootVC:FirstViewController?
    
    private var buttomBar: UIView!
    var tableView:UITableView!
    var moreType:UIButton!
    
    var inputTextView:UITextView!
    private var buttomOriginY:CGFloat!
    private var buttomStartedY:CGFloat!
    private var buttomOriginHeight:CGFloat!
    private var buttomChangeHeight:CGFloat = 0
    
    private var tableOffsetYOrigin:CGFloat!
    private var isKeyboardShowed = false
    private var isScrollToButtom = true
    //private var keyboardAnimating = false
    
    var addFriendComfirm:UIButton?
    var blackListOption:UIBarButtonItem?
    var blackListOptionBar:UIToolbar?
    
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var msgList:NSMutableArray!
    var friendComments:NSDictionary!
    
    var sendingQueue:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = chatroomName
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(UDChatViewController.gotoSetting))
        
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .OnDrag
        view.addSubview(tableView)
        tableView.alpha = 0
        
        
        buttomBar = UIView(frame: CGRect(x: 0, y: view.frame.height - 40, width: view.frame.width, height: 40))
        //buttomBar.effect = UIBlurEffect(style: .ExtraLight)
        buttomBar.backgroundColor = UIColor(white: 1, alpha: 0.8)
        view.addSubview(buttomBar)
        inputTextView = UITextView(frame: CGRect(x: 8, y: 4, width: buttomBar.frame.width - 40, height: buttomBar.frame.height - 8))
        inputTextView.backgroundColor = UIColor.clearColor()
        inputTextView.layer.borderColor = UIColor.grayColor().CGColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 8
        buttomBar.addSubview(inputTextView)
        inputTextView.delegate = self
        inputTextView.returnKeyType = .Send
        inputTextView.enablesReturnKeyAutomatically = true
        
        if draft != nil{
            inputTextView.text = draft!
        }
        
        moreType = UIButton(type: .ContactAdd)
        moreType.frame = CGRect(x: inputTextView.frame.origin.x + inputTextView.frame.width, y: 4, width: buttomBar.frame.height - 7, height: buttomBar.frame.height - 7)
        buttomBar.addSubview(moreType)
        moreType.addTarget(self, action: #selector(UDChatViewController.moreTypeOption), forControlEvents: .TouchUpInside)
        
        // MARK: 请求加为好友
        if notFriendYet{
            inputTextView.alpha = 0
            moreType.alpha = 0
            addFriendComfirm = UIButton(type: .System)
            addFriendComfirm?.frame = inputTextView.frame
            buttomBar.addSubview(addFriendComfirm!)
            addFriendComfirm?.setTitle("添加为好友", forState: .Normal)
            
            blackListOptionBar = UIToolbar(frame: CGRect(x: view.frame.width - 45, y: 0, width: 45, height: 45))
            blackListOptionBar?.backgroundColor = UIColor(white: 1, alpha: 0.8)
            blackListOptionBar?.layer.borderWidth = 0.0
            blackListOptionBar?.layer.masksToBounds = true
            buttomBar.addSubview(blackListOptionBar!)
            
            blackListOption = UIBarButtonItem(image: UIImage(named: "more"), style: .Plain, target: self, action: #selector(UDChatViewController.showBlackListOption))
            blackListOptionBar?.setItems([blackListOption!], animated: false)

            
            addFriendComfirm?.addTarget(self, action: #selector(UDChatViewController.comfirmFriend), forControlEvents: .TouchUpInside)
        }
        
        buttomOriginY = buttomBar.frame.origin.y
        // MARK: 键盘切换输入框上移
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillUnShow(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        let msgPath = "\(caches)/\(chatroomID!).plist"
        if NSFileManager.defaultManager().fileExistsAtPath(msgPath){
            msgList = NSMutableArray(contentsOfFile: msgPath)
        }else{
            msgList = NSMutableArray()
            msgList.writeToFile(msgPath, atomically: true)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(UDChatViewController.timerElapse), userInfo: nil, repeats: true)
        
    }
    func timerElapse(){
        // MARK: 定时检查新消息
        let msgPath = "\(caches)/\(chatroomID!).plist"
        if NSFileManager.defaultManager().fileExistsAtPath(msgPath){
//            msgList = NSMutableArray(contentsOfFile: msgPath)
            let newMsgList = NSMutableArray(contentsOfFile: msgPath)
            if newMsgList?.count != msgList.count{
                msgList = newMsgList
                tableView.reloadData()
                if isScrollToButtom && tableView.contentSize.height > tableView.frame.height{
                    tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
                }
                // TODO: 如果收到对方确认好友的信息，则马上隐藏添加好友按钮
                if (newMsgList?.lastObject as! NSDictionary).objectForKey("type") as! String != "req" {
                    self.addFriendComfirm?.alpha = 0
                    self.blackListOptionBar?.alpha = 0
                    self.inputTextView.alpha = 1
                    self.moreType.alpha = 1
                }
            }
        }else{
            msgList = NSMutableArray()
            msgList.writeToFile(msgPath, atomically: true)
        }
//        tableView.reloadData()
//        if isScrollToButtom && tableView.contentSize.height > tableView.frame.height{
//            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
//        }
        
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if tableView.contentOffset.y + tableView.frame.height >= tableView.contentSize.height - 1{
            isScrollToButtom = true
        }else{
            isScrollToButtom = false
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/friend_comments.plist"){
            friendComments = NSDictionary(contentsOfFile: "\(caches)/friend_comments.plist")
        }else{
            friendComments = NSDictionary()
        }
        
        if chatroomID?.hasPrefix("user") == true{
            let thisID = NSString(string: chatroomID!).substringFromIndex(4)
            if friendComments.objectForKey("\(thisID)") != nil{
                navigationItem.title = friendComments.objectForKey("\(thisID)") as? String
            }
        }
        
        if isScrollToButtom && tableView.contentSize.height > tableView.frame.height - 40{
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: false)
        }
        if tableView.alpha == 0{
            tableView.alpha = 1
        }
    }
    func gotoSetting(){
//        let userVC = UDUserViewController()
//        // TODO: setting
//        userVC.uid = "4"
//        hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(userVC, animated: true)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return msgList.count
        }
        return 1
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "msg")
        if indexPath.section == 0{
            var bubble:UDChatBubble!
            let curItem = msgList.objectAtIndex(indexPath.row) as! NSDictionary
            
            let sendFromType = curItem.objectForKey("send_from") as! String
            let msgText = curItem.objectForKey("body") as! String
            if sendFromType == "user"{
                let fromID = curItem.objectForKey("fromid") as! String
                // TODO: 还没考虑群聊的情况, 和其他类型消息的情况
                 let msgType = curItem.objectForKey("type") as! String
//                if curItem.objectForKey("type") as! String == "req"{
//                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: msgText, uid: nil)
//                }
                if fromID != myUID{
                    
                    switch msgType {
                    case "image":
                        // MARK: 读取缩略图
                        let thum_img = UIImage(contentsOfFile: "\(caches)/chat_img/\(msgText)")
                        if thum_img != nil{
                            bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 96), style: .Left, img: thum_img, uid: fromID, indexPath: indexPath)
                        }else{
                            bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 96), style: .Left, img: nil, uid: fromID, indexPath: indexPath)
                        }
                        bubble.delegate = self
                        let resq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getChatImg.php?filename=\(msgText)")!)
                        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                            if err == nil{
                                if let data = returnData{
                                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                                    if json == nil{
                                        dispatch_async(dispatch_get_main_queue(), {
                                            bubble.imageToShow = UIImage(data: data)!
                                            data.writeToFile("\(self.caches)/chat_img/\(msgText)", atomically: true)
                                        })
                                    }
                                }
                            }
                        })
                        
                        break
                    default:
                        
                        bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: cell.frame.height-32), style: .Left, text: msgText, uid: fromID, indexPath: indexPath)
                        break
                    }
                }else{
                    switch msgType {
                    case "image":
                        // MARK: 读取缩略图
                        let thum_img = UIImage(contentsOfFile: "\(caches)/chat_img/\(msgText)")
                        if thum_img != nil{
                            bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 96), style: .Right, img: thum_img, uid: fromID, indexPath: indexPath)
                        }else{
                            bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 96), style: .Right, img: nil, uid: fromID, indexPath: indexPath)
                        }
                        bubble.delegate = self
                        let resq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getChatImg.php?filename=\(msgText)")!)
                        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                            if err == nil{
                                if let data = returnData{
                                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                                    if json == nil{
                                        dispatch_async(dispatch_get_main_queue(), {
                                            bubble.imageToShow = UIImage(data: data)!
                                            data.writeToFile("\(self.caches)/chat_img/\(msgText)", atomically: true)
                                        })
                                    }
                                }
                            }
                        })
                        break
                    default:
                        bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: msgText, uid: fromID, indexPath: indexPath)
                        break
                    }
                    
                }
            }else if sendFromType == "system"{
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: msgText, uid: nil, indexPath: indexPath)
            }else if sendFromType == "timeMark"{
                
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: UDChatDate.longTime(curItem.objectForKey("time") as! String)!, uid: nil, indexPath: indexPath)
            }
//            else if sendFromType.hasPrefix("group"){
//                
//                if fromID != myUID{
//                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Left, text: msgText, uid: fromID, indexPath: indexPath)
//                }else{
//                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: msgText, uid: fromID, indexPath: indexPath)
//                }
//            }
            
            //头像点击事件
            if bubble.style != .System {
                bubble.avatar!.addTarget(self, action: #selector(UDChatViewController.gotoUser), forControlEvents: .TouchUpInside)
            }
            
            cell.addSubview(bubble)
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            
            let curItem = msgList.objectAtIndex(indexPath.row) as! NSDictionary
            let msgType = curItem.objectForKey("type") as! String
            switch msgType {
            case "image":
                return 96
            default:
                let msgText = curItem.objectForKey("body") as! String
                let size = NSString(string: msgText).boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width*0.6, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
                return size.height + 32
            }
            
        case 1:
            return 48 + buttomChangeHeight
        default:
            return 44
        }
    }
    
    func keyboardWillChangeFrame(noti:NSNotification) {
        let info = noti.userInfo!
        let heightValue = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height = heightValue.CGRectValue().height
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        print("change frame | height: \(height)")
        if isKeyboardShowed{
            UIView.animateWithDuration(time, animations: {
                self.buttomBar.center.y = self.view.frame.height - height - 20
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)
            }) { (finished) in
            
            }
            if self.isScrollToButtom && tableView.contentSize.height > tableView.frame.height - 40{
                self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
            }
            buttomStartedY = buttomBar.frame.origin.y + buttomChangeHeight
            tableOffsetYOrigin = self.tableView.contentSize.height - self.tableView.frame.height
        }
        
    }

    func keyboardWillShow(noti:NSNotification){
        let info = noti.userInfo!
        let heightValue = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height = heightValue.CGRectValue().height
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        //keyboardAnimating = true
        print("keyboard show | height: \(height)")
        if !isKeyboardShowed{
            UIView.animateWithDuration(time, animations: {
                self.buttomBar.center.y -= height
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)
            }) { (finished) in
                
            }
            if self.isScrollToButtom && tableView.contentSize.height > tableView.frame.height - 40{
                self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
            }
            buttomStartedY = buttomBar.frame.origin.y + buttomChangeHeight
            tableOffsetYOrigin = self.tableView.contentSize.height - self.tableView.frame.height
            isKeyboardShowed = true
        }
        
    }
    
    func keyboardWillUnShow(noti:NSNotification){
        let info = noti.userInfo!
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        //keyboardAnimating = true
        print("keyboard unshow")
        UIView.animateWithDuration(time, animations: {
            self.buttomBar.frame.origin.y = self.buttomOriginY - self.buttomChangeHeight
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            }) { (finished) in
                //self.keyboardAnimating = false
        }
        isKeyboardShowed = false
    }
    
    func textViewDidChange(textView: UITextView) {
//        // MARK: 没有虚拟键盘的情况
//        if !isKeyboardShowed{
//            buttomStartedY = view.frame.height - 40
//            tableOffsetYOrigin = tableView.contentOffset.y
//        }
        // MARK: 根据文字调整高度
        if buttomOriginHeight != inputTextView.contentSize.height{
            if inputTextView.contentSize.height <= 24 {
                
                UIView.animateWithDuration(0.3, animations: {
                    self.buttomBar.frame = CGRect(x: 0, y: self.buttomStartedY, width: self.buttomBar.frame.width, height: 40)
                    self.inputTextView.frame = CGRect(origin: self.inputTextView.frame.origin, size: CGSize(width: self.inputTextView.frame.width, height: 32))
                })
                buttomChangeHeight = 0
                tableOffsetYOrigin = tableView.contentOffset.y
            }else if inputTextView.contentSize.height < 64 {
                buttomChangeHeight = self.inputTextView.contentSize.height - 32
                UIView.animateWithDuration(0.3, animations: {
                    self.buttomBar.frame = CGRect(x: 0, y: self.buttomStartedY - self.buttomChangeHeight, width: self.buttomBar.frame.width, height: self.inputTextView.contentSize.height+8)
                    self.inputTextView.frame = CGRect(origin: self.inputTextView.frame.origin, size: CGSize(width: self.inputTextView.frame.width, height: self.inputTextView.contentSize.height))
                })
            }else{
                UIView.animateWithDuration(0.3, animations: {
                    self.buttomBar.frame = CGRect(x: 0, y: self.buttomStartedY - 32, width: self.buttomBar.frame.width, height: 72)
                    self.inputTextView.frame = CGRect(origin: self.inputTextView.frame.origin, size: CGSize(width: self.inputTextView.frame.width, height: 64))
                })
                buttomChangeHeight = 32
                
            }
            tableView.reloadData()
            tableView.setContentOffset(CGPoint(x: 0, y: tableOffsetYOrigin + buttomChangeHeight), animated: true)
        }
        buttomOriginHeight = inputTextView.contentSize.height
        
        
        
    }
    
    func gotoUser(sender:UIButton){
        let userVC = UDUserViewController()
        // MARK: 进入用户详情
        tableView.alpha = 0
        userVC.thisUid = String(sender.tag)
        userVC.myUID = myUID
        userVC.acode = myAcode
        userVC.rootVC = self.rootVC
        if chatroomID != nil{
            if chatroomID!.hasPrefix("user"){
                if NSString(string: chatroomID!).substringFromIndex(4) == String(sender.tag){
                    userVC.justPop = true
                }
            }
        }
        
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // MARK: 发送消息
            
            
            //比较时间，判断是否添加时间标记
            let date = NSDate()
            let formate = NSDateFormatter()
            formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeStr = formate.stringFromDate(date)
            
            var requireMarker = true
            
            if msgList.count != 0{
                let lastTime = (msgList.lastObject as! NSDictionary).objectForKey("time") as! String
                requireMarker = UDChatDate.isTimeToAddTimeMarker(timeStr, lastTime)
            }
            if requireMarker{
                let timeMarker = NSMutableDictionary()
                timeMarker.setValue("timeMark", forKey: "send_from")
                timeMarker.setValue("0", forKey: "fromid")
                timeMarker.setValue("string", forKey: "type")
                timeMarker.setValue(UDChatDate.longTime(timeStr)!, forKey: "body")
                timeMarker.setValue(timeStr, forKey: "time")
                timeMarker.setValue("\(chatroomName!)", forKey: "chatname")
                msgList.addObject(timeMarker)
                
            }
            
            let msgToSend = NSMutableDictionary()
            
            let thisMsgBody = inputTextView.text
            if chatroomID!.hasPrefix("user"){
                let thisChatID = NSString(string: chatroomID!).substringFromIndex(4)
                //生成消息
                msgToSend.setValue("user", forKey: "send_from")
                msgToSend.setValue("\(myUID!)", forKey: "fromid")
                
                msgToSend.setValue("string", forKey: "type")
                
                msgToSend.setValue("\(thisMsgBody)", forKey: "body")
                
                msgToSend.setValue("\(timeStr)", forKey: "time")
                
                msgToSend.setValue("\(chatroomName!)", forKey: "chatname")
                msgToSend.setValue("0", forKey: "sendStatus")
                
                //写入文件
                msgList.addObject(msgToSend)
                tableView.reloadData()
                
                if tableView.contentSize.height > tableView.frame.height{
                    tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
                }
                
                let msgPath = "\(caches)/\(chatroomID!).plist"
                msgList.writeToFile(msgPath, atomically: true)
                
                
                //更新首页消息列表
                let homePageMsg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
                var reverseAry = homePageMsg?.reverseObjectEnumerator().allObjects
                for i in 0..<reverseAry!.count{
                    let dic = reverseAry![i] as! NSDictionary
                    if dic.objectForKey("send_from") as! String == "user" && dic.objectForKey("fromid") as! String == "\(thisChatID)"{
                        reverseAry?.removeAtIndex(i)
                        break
                    }
                }
                let msgShowInHomePage = NSMutableDictionary(dictionary: msgToSend)
                msgShowInHomePage.setValue(0, forKey: "unread")
                msgShowInHomePage.setValue("\(thisChatID)", forKey: "fromid")
                reverseAry?.append(msgShowInHomePage)
                homePageMsg?.removeAllObjects()
                reverseAry = (reverseAry! as NSArray).reverseObjectEnumerator().allObjects
                for item in reverseAry!{
                    homePageMsg?.addObject(item)
                }
                homePageMsg?.writeToFile("\(caches)/msg.plist", atomically: true)
                
                //MARK: POST消息
                let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/sendMsg.php")!)
                resq.HTTPMethod = "POST"
                resq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(myAcode!)&toid=\(thisChatID)&body=\(thisMsgBody)").dataUsingEncoding(NSUTF8StringEncoding)
//                $uid = $_POST["uid"];
//                $acode = $_POST["acode"];
//                $toid = $_POST["toid"];
//                $msgtype = $_POST["msgtype"];
//                $body = $_POST["body"];
                NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                    var sendSuccess = false
                    if err == nil{
                        if let data = returnData{
                            print(NSString(data: data, encoding: NSUTF8StringEncoding))
                            let jsonObj = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if jsonObj.objectForKey("success") != nil{
                                sendSuccess = true
                            }
                        }
                    }
                    if !sendSuccess{
                        // MARK: 发送失败
                        let timeMarker = NSMutableDictionary()
                        timeMarker.setValue("system", forKey: "send_from")
                        timeMarker.setValue("0", forKey: "fromid")
                        timeMarker.setValue("string", forKey: "type")
                        timeMarker.setValue("很抱歉，您的消息\"\(thisMsgBody)\"发送失败", forKey: "body")
                        timeMarker.setValue(timeStr, forKey: "time")
                        timeMarker.setValue("\(self.chatroomName!)", forKey: "chatname")
                        self.msgList.addObject(timeMarker)
                        self.msgList.writeToFile(msgPath, atomically: true)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                            if self.tableView.contentSize.height > self.tableView.frame.height{
                                self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
                            }
                        })
                    }
                })
            }
            
            
            
//            {
//                "send_from":"user",
//                "fromid":"8",
//                "type":"string",
//                "body":"\u6d4b\u8bd5\u6d4b\u8bd5",
//                "time":"2016-07-21 23:22:32",
//                "chatname":"\u7cfb\u7edf\u6d88\u606f"
//            }
            
            
            inputTextView.text = ""
            textViewDidChange(inputTextView)
            return false
        }
        return true
    }
    //我们已经成为好友啦，可以愉快地开始聊天啦!
    func comfirmFriend(){
        print("确认添加好友")
        // MARK: 确认添加好友
//        let thisChatID = NSString(string: chatroomID!).substringFromIndex(4)
        
        //比较时间，判断是否添加时间标记
        let date = NSDate()
        let formate = NSDateFormatter()
        formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStr = formate.stringFromDate(date)
        
        var requireMarker = true
        
        if msgList.count != 0{
            let lastTime = (msgList.lastObject as! NSDictionary).objectForKey("time") as! String
            requireMarker = UDChatDate.isTimeToAddTimeMarker(timeStr, lastTime)
        }
        if requireMarker{
            let timeMarker = NSMutableDictionary()
            timeMarker.setValue("timeMark", forKey: "send_from")
            timeMarker.setValue("0", forKey: "fromid")
            timeMarker.setValue("string", forKey: "type")
            timeMarker.setValue(UDChatDate.longTime(timeStr)!, forKey: "body")
            timeMarker.setValue(timeStr, forKey: "time")
            timeMarker.setValue("\(chatroomName!)", forKey: "chatname")
            msgList.addObject(timeMarker)
            
        }
        
        let msgToSend = NSMutableDictionary()
        
//        if chatroomID!.hasPrefix("user"){
        let thisChatID = NSString(string: chatroomID!).substringFromIndex(4)
        //生成消息
        msgToSend.setValue("user", forKey: "send_from")
        msgToSend.setValue("\(myUID!)", forKey: "fromid")
        
        msgToSend.setValue("string", forKey: "type")
        
        msgToSend.setValue("我们已经成为好友啦，可以愉快地开始聊天啦!", forKey: "body")
        
        msgToSend.setValue("\(timeStr)", forKey: "time")
        msgToSend.setValue("\(chatroomName!)", forKey: "chatname")
        msgToSend.setValue("0", forKey: "sendStatus")
        
        //写入文件
        msgList.addObject(msgToSend)
        tableView.reloadData()
        
        if tableView.contentSize.height > tableView.frame.height{
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
        }
        
        let msgPath = "\(caches)/\(chatroomID!).plist"
        msgList.writeToFile(msgPath, atomically: true)
        
        
        //更新首页消息列表
        let homePageMsg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
        var reverseAry = homePageMsg?.reverseObjectEnumerator().allObjects
        for i in 0..<reverseAry!.count{
            let dic = reverseAry![i] as! NSDictionary
            if dic.objectForKey("send_from") as! String == "user" && dic.objectForKey("fromid") as! String == "\(thisChatID)"{
                reverseAry?.removeAtIndex(i)
                break
            }
        }
        let msgShowInHomePage = NSMutableDictionary(dictionary: msgToSend)
        msgShowInHomePage.setValue(0, forKey: "unread")
        msgShowInHomePage.setValue("\(thisChatID)", forKey: "fromid")
        reverseAry?.append(msgShowInHomePage)
        homePageMsg?.removeAllObjects()
        reverseAry = (reverseAry! as NSArray).reverseObjectEnumerator().allObjects
        for item in reverseAry!{
            homePageMsg?.addObject(item)
        }
        homePageMsg?.writeToFile("\(caches)/msg.plist", atomically: true)
        
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/addFriend.php")!)
        resq.HTTPMethod = "POST"
        resq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(myAcode!)&toid=\(thisChatID)").dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            var sendSuccess = false
            if err == nil{
                if let data = returnData{
                    print(NSString(data: data, encoding: NSUTF8StringEncoding)!)
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    if json?.objectForKey("error") == nil{
                        sendSuccess = true
                    }
                    
                }
            }
            if sendSuccess {
                dispatch_async(dispatch_get_main_queue(), {
                    self.addFriendComfirm?.alpha = 0
                    self.blackListOptionBar?.alpha = 0
                    self.inputTextView.alpha = 1
                    self.moreType.alpha = 1
                })
            }else{
                let timeMarker = NSMutableDictionary()
                timeMarker.setValue("system", forKey: "send_from")
                timeMarker.setValue("0", forKey: "fromid")
                timeMarker.setValue("string", forKey: "type")
                timeMarker.setValue("很抱歉，添加好友失败", forKey: "body")
                timeMarker.setValue(timeStr, forKey: "time")
                timeMarker.setValue("\(self.chatroomName!)", forKey: "chatname")
                self.msgList.addObject(timeMarker)
                self.msgList.writeToFile(msgPath, atomically: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    if self.tableView.contentSize.height > self.tableView.frame.height{
                        self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
                    }
                })
            }
        }
    }
    func showBlackListOption(){
        let blOptionSheet = UIActionSheet(title: "添加黑名单防止该用户骚扰", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        blOptionSheet.addButtonWithTitle("忽略该请求")
        blOptionSheet.addButtonWithTitle("添加黑名单")
        blOptionSheet.addButtonWithTitle("取消")
        blOptionSheet.destructiveButtonIndex = 1
        blOptionSheet.cancelButtonIndex = 2
        blOptionSheet.showInView(view)
        
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.title == "添加黑名单防止该用户骚扰" {
            if buttonIndex == 1{
                print("添加黑名单")
                // MARK: 添加黑名单提示
                let deleteAlert = UIAlertView(title: "添加到黑名单?", message: "对方将无法添加你为好友，可防止该用户骚扰", delegate: self, cancelButtonTitle: nil)
                deleteAlert.addButtonWithTitle("是")
                deleteAlert.addButtonWithTitle("否")
                deleteAlert.cancelButtonIndex = 1
                deleteAlert.tag = 200
                deleteAlert.show()
            }else if buttonIndex == 0{
                ignoreFriendReq()
            }
        }else if actionSheet.title == "发送图片" {
            switch buttonIndex {
            case 0:
                // MARK: 弹出图片选择
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                picker.view.tag = 1
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) || UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front){
                    //picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                    
                    picker.sourceType = UIImagePickerControllerSourceType.Camera
                    
                }else{
                    print("Camera Unavaliable")
                }
                presentViewController(picker, animated: true, completion: nil)
                
                break
            case 1:
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                picker.view.tag = 1
                presentViewController(picker, animated: true, completion: nil)
                break
            default:
                break
            }
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // MARK: 草稿更新首页消息列表
        if inputTextView.text != ""{
            var draftList:NSMutableDictionary?
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/draft.plist"){
                draftList = NSMutableDictionary(contentsOfFile: "\(caches)/draft.plist")
            }else{
                draftList = NSMutableDictionary()
            }
            draftList?.setValue(inputTextView.text, forKey: "\(chatroomID!)")
            draftList?.writeToFile("\(caches)/draft.plist", atomically: true)
        }else if inputTextView.text == "" {
            var draftList:NSMutableDictionary?
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/draft.plist"){
                draftList = NSMutableDictionary(contentsOfFile: "\(caches)/draft.plist")
            }else{
                draftList = NSMutableDictionary()
            }
            if draftList?.objectForKey("\(chatroomID!)") != nil{
                draftList?.removeObjectForKey("\(chatroomID!)")
                draftList?.writeToFile("\(caches)/draft.plist", atomically: true)
            }
        }
        
    }
    
    func moreTypeOption(){
        inputTextView.resignFirstResponder()
        let as1 = UIActionSheet(title: "发送图片", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        as1.addButtonWithTitle("拍照")
        as1.addButtonWithTitle("选择照片")
        as1.addButtonWithTitle("取消")
        as1.cancelButtonIndex = as1.numberOfButtons - 1
        as1.showInView(view)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true) { 
            print("发图片")
            // MARK: 发图片
            // 生成两张大小的图片
            let img = UIImage(image: image, resizeRatioWithHeight: 64)
            let imgFull = UIImage(image: image, resizeRatioWithWidth: 640)
            let imgData = UIImageJPEGRepresentation(img, 0.5)
            let imgDataFull = UIImageJPEGRepresentation(imgFull, 0.5)
            // 生成文件名和路径
            let fomatter = NSDateFormatter()
            fomatter.dateFormat = "yyyyMMddHHmmss"
            
            let filename = "user\(self.myUID!)_\(self.chatroomID!)_\(fomatter.stringFromDate(NSDate())).jpg"
            let filenameFull = "user\(self.myUID!)_\(self.chatroomID!)_\(fomatter.stringFromDate(NSDate()))_full.jpg"
            let path = "\(self.caches)/chat_img/\(filenameFull)"
            // 图片先存到缓存
            imgData?.writeToFile("\(self.caches)/chat_img/\(filename)", atomically: true)
            imgDataFull?.writeToFile(path, atomically: true)
            
            //比较时间，判断是否添加时间标记
            let date = NSDate()
            let formate = NSDateFormatter()
            formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeStr = formate.stringFromDate(date)
            
            var requireMarker = true
            
            if self.msgList.count != 0{
                let lastTime = (self.msgList.lastObject as! NSDictionary).objectForKey("time") as! String
                requireMarker = UDChatDate.isTimeToAddTimeMarker(timeStr, lastTime)
            }
            if requireMarker{
                let timeMarker = NSMutableDictionary()
                timeMarker.setValue("timeMark", forKey: "send_from")
                timeMarker.setValue("0", forKey: "fromid")
                timeMarker.setValue("string", forKey: "type")
                timeMarker.setValue(UDChatDate.longTime(timeStr)!, forKey: "body")
                timeMarker.setValue(timeStr, forKey: "time")
                timeMarker.setValue("\(self.chatroomName!)", forKey: "chatname")
                self.msgList.addObject(timeMarker)
                
            }
            
            let msgToSend = NSMutableDictionary()
            
            let thisMsgBody = filename
            if self.chatroomID!.hasPrefix("user"){
                let thisChatID = NSString(string: self.chatroomID!).substringFromIndex(4)
                //生成消息
                msgToSend.setValue("user", forKey: "send_from")
                msgToSend.setValue("\(self.myUID!)", forKey: "fromid")
                
                msgToSend.setValue("image", forKey: "type")
                
                msgToSend.setValue("\(thisMsgBody)", forKey: "body")
                
                msgToSend.setValue("\(timeStr)", forKey: "time")
                msgToSend.setValue("\(self.chatroomName!)", forKey: "chatname")
                msgToSend.setValue("0", forKey: "sendStatus")
                
                //写入文件
                self.msgList.addObject(msgToSend)
                self.tableView.reloadData()
                
                if self.tableView.contentSize.height > self.tableView.frame.height{
                    self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
                }
                
                let msgPath = "\(self.caches)/\(self.chatroomID!).plist"
                self.msgList.writeToFile(msgPath, atomically: true)
                
                
                //更新首页消息列表
                let homePageMsg = NSMutableArray(contentsOfFile: "\(self.caches)/msg.plist")
                var reverseAry = homePageMsg?.reverseObjectEnumerator().allObjects
                for i in 0..<reverseAry!.count{
                    let dic = reverseAry![i] as! NSDictionary
                    if dic.objectForKey("send_from") as! String == "user" && dic.objectForKey("fromid") as! String == "\(thisChatID)"{
                        reverseAry?.removeAtIndex(i)
                        break
                    }
                }
                let msgShowInHomePage = NSMutableDictionary(dictionary: msgToSend)
                msgShowInHomePage.setValue(0, forKey: "unread")
                msgShowInHomePage.setValue("\(thisChatID)", forKey: "fromid")
                reverseAry?.append(msgShowInHomePage)
                homePageMsg?.removeAllObjects()
                reverseAry = (reverseAry! as NSArray).reverseObjectEnumerator().allObjects
                for item in reverseAry!{
                    homePageMsg?.addObject(item)
                }
                homePageMsg?.writeToFile("\(self.caches)/msg.plist", atomically: true)

            
                // POST 消息
                let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/sendImgMsg.php")!)
                resq.HTTPMethod = "POST"
                let postData = NSMutableData()
                
                resq.setValue("multipart/form-data; boundary=AaB03x", forHTTPHeaderField: "Content-Type")
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"uid\";\r\n\r\n\(self.myUID!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"acode\";\r\n\r\n\(self.myAcode!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"toid\";\r\n\r\n\(thisChatID)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"img\"; filename=\"\(filename)\"\r\nContent-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(imgData!)
                postData.appendData(NSString(string: "\r\n--AaB03x\r\nContent-Disposition: form-data; name=\"img_full\"; filename=\"\(filenameFull)\"\r\nContent-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(imgDataFull!)
                postData.appendData(NSString(string: "\r\n--AaB03x--\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                resq.setValue(String(postData.length), forHTTPHeaderField: "Content-Length")
                resq.HTTPBody = postData
                
                
                NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) -> Void in
                    var sendSuccess = false
                    if err == nil{
                        print("return data:\(NSString(data: returnData!, encoding: NSUTF8StringEncoding)!)")
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if json?.objectForKey("error") == nil{
                                sendSuccess = true
                                
                            }
                        }
                        
                    }
                    if !sendSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            let timeMarker = NSMutableDictionary()
                            timeMarker.setValue("system", forKey: "send_from")
                            timeMarker.setValue("0", forKey: "fromid")
                            timeMarker.setValue("string", forKey: "type")
                            timeMarker.setValue("很抱歉，图片发送失败", forKey: "body")
                            timeMarker.setValue(timeStr, forKey: "time")
                            timeMarker.setValue("\(self.chatroomName!)", forKey: "chatname")
                            self.msgList.addObject(timeMarker)
                            self.msgList.writeToFile(msgPath, atomically: true)
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                                if self.tableView.contentSize.height > self.tableView.frame.height{
                                    self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
                                }
                            })
                        })
                        
                    }
                }
            }
        }
    }
    
    func chatBubble(chatBubble: UDChatBubble, clickedImageButtonView imageButton: UIButton) {
        let curItem = msgList.objectAtIndex(chatBubble.indexPath.row) as! NSDictionary
        let msgType = curItem.objectForKey("type") as! String
        let msgText = curItem.objectForKey("body") as! String
        if msgType != "image" {
            return
        }
        let thum_img = UIImage(contentsOfFile: "\(caches)/chat_img/\(msgText)")
        let imgVC = PVImgViewController(imagePrview: thum_img)
        let filenameFull = "\(msgText.componentsSeparatedByString(".")[0])_full.\(msgText.componentsSeparatedByString(".")[1])"
        if let fullImg = UIImage(contentsOfFile: filenameFull) {
            imgVC.imageView.image = fullImg
        }else{
            imgVC.requestURL = "http://119.29.225.180/notecloud/getChatImg.php?filename=\(filenameFull)"
        }
        imgVC.delegate = self
        hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.alpha = 0
        navigationController?.pushViewController(imgVC, animated: true)
    }
    func pvImgViewController(pvVC: PVImgViewController, finishedLoadingURLImage URL: String, image: UIImage) {
        
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch alertView.tag {
        case 200:
            if buttonIndex == 0{
                print("黑名单")
                // MARK: 添加黑名单操作
                let addBLResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setBlackList.php")!)
                addBLResq.HTTPMethod = "POST"
                let thisUid = NSString(string: chatroomID!).substringFromIndex(4)
                addBLResq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(myAcode!)&toid=\(thisUid)").dataUsingEncoding(NSUTF8StringEncoding)
                NSURLConnection.sendAsynchronousRequest(addBLResq, queue: NSOperationQueue(), completionHandler: { (resp:
                    NSURLResponse?, returnData:NSData?, err:NSError?) in
                    var isSuccess = false
                    if err == nil{
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                            if json != nil{
                                if json?.objectForKey("error") == nil{
                                    isSuccess = true
                                    dispatch_async(dispatch_get_main_queue(), {
                                        let addBLAlert = UIAlertView(title: "操作成功", message: nil, delegate: self, cancelButtonTitle: "好")
                                        addBLAlert.tag = 201
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
        case 201:
            ignoreFriendReq()
            break
        default:
            break
        }
    }
    
    func ignoreFriendReq(){
        // 删除首页条目
        let homePageMsg = NSMutableArray(contentsOfFile: "\(caches)/msg.plist")
        let thisUid = NSString(string: chatroomID!).substringFromIndex(4)
        for i in 0..<homePageMsg!.count{
            let item = homePageMsg?.objectAtIndex(i) as! NSDictionary
            if item.objectForKey("send_from") as! String == "user" && item.objectForKey("fromid") as! String == "\(thisUid)" {
                homePageMsg?.removeObjectAtIndex(i)
                homePageMsg?.writeToFile("\(caches)/msg.plist", atomically: true)
                break
            }
        }
        
        
        navigationController?.popViewControllerAnimated(true)
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
