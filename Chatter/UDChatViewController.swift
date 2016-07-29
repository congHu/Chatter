//
//  UDChatViewController.swift
//  Chatter
//
//  Created by David on 16/7/20.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate {

    var chatroomID:String?
    var chatroomName:String?
    var myUID:String?
    var myAcode:String?
    var notFriendYet = false
    
    // TODO: 草稿功能
    var draft:String?
    var rootVC:FirstViewController?
    
    private var buttomBar: UIVisualEffectView!
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
    var blackListOption:UIButton?
    
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var msgList:NSMutableArray!
    
    
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
        
        buttomBar = UIVisualEffectView(frame: CGRect(x: 0, y: view.frame.height - 40, width: view.frame.width, height: 40))
        buttomBar.effect = UIBlurEffect(style: .ExtraLight)
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
        
        moreType = UIButton(type: .ContactAdd)
        moreType.frame = CGRect(x: inputTextView.frame.origin.x + inputTextView.frame.width, y: 4, width: buttomBar.frame.height - 7, height: buttomBar.frame.height - 7)
        buttomBar.addSubview(moreType)
        
        
        // MARK: 请求加为好友
        if notFriendYet{
            inputTextView.alpha = 0
            moreType.alpha = 0
            addFriendComfirm = UIButton(type: .System)
            addFriendComfirm?.frame = inputTextView.frame
            buttomBar.addSubview(addFriendComfirm!)
            addFriendComfirm?.setTitle("添加为好友", forState: .Normal)
            blackListOption = UIButton(frame: moreType.frame)
            blackListOption?.setImage(UIImage(named: "more"), forState: .Normal)
            buttomBar.addSubview(blackListOption!)
            
            addFriendComfirm?.addTarget(self, action: #selector(UDChatViewController.comfirmFriend), forControlEvents: .TouchUpInside)
            blackListOption?.addTarget(self, action: #selector(UDChatViewController.showBlackListOption), forControlEvents: .TouchUpInside)
        }
        
        buttomOriginY = buttomBar.frame.origin.y
        // TODO: 切换输入法bug
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillUnShow(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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
            msgList = NSMutableArray(contentsOfFile: msgPath)
        }else{
            msgList = NSMutableArray()
            msgList.writeToFile(msgPath, atomically: true)
        }
        tableView.reloadData()
        if isScrollToButtom && tableView.contentSize.height > tableView.frame.height{
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
        }
        
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
        if tableView.contentSize.height > tableView.frame.height{
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: false)
        }
    }
    func gotoSetting(){
//        let userVC = UDUserViewController()
//        // TODO: 传入uid
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
                if curItem.objectForKey("type") as! String == "req"{
                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: msgText, uid: nil)
                }
                if fromID != myUID{
                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Left, text: msgText, uid: fromID)
                }else{
                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: msgText, uid: fromID)
                }
            }else if sendFromType == "system"{
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: msgText, uid: nil)
            }else if sendFromType == "timeMark"{
                
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 24, width: cell.frame.width, height: cell.frame.height-32), style: .System, text: UDChatDate.longTime(curItem.objectForKey("time") as! String)!, uid: nil)
            }
//            else if sendFromType.hasPrefix("group"){
//                
//                if fromID != myUID{
//                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Left, text: msgText, uid: fromID)
//                }else{
//                    bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: msgText, uid: fromID)
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
            let msgText = curItem.objectForKey("body") as! String
            let size = NSString(string: msgText).boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width*0.6, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
            return size.height + 32
        case 1:
            return 48 + buttomChangeHeight
        default:
            return 44
        }
    }

    func keyboardWillShow(noti:NSNotification){
        let info = noti.userInfo!
        let heightValue = info[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let height = heightValue.CGRectValue().height
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        //keyboardAnimating = true
        
        UIView.animateWithDuration(time, animations: {
            self.buttomBar.center.y -= height
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)
            }) { (finished) in
                
        }
        if self.isScrollToButtom{
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.height), animated: true)
        }
        buttomStartedY = buttomBar.frame.origin.y + buttomChangeHeight
        isKeyboardShowed = true
    }
    
    func keyboardWillUnShow(noti:NSNotification){
        let info = noti.userInfo!
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        //keyboardAnimating = true
        UIView.animateWithDuration(time, animations: {
            self.buttomBar.frame.origin.y = self.buttomOriginY - self.buttomChangeHeight
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            }) { (finished) in
                //self.keyboardAnimating = false
        }
        isKeyboardShowed = false
    }
    
    func textViewDidChange(textView: UITextView) {
        // MARK: 没有虚拟键盘的情况
        if !isKeyboardShowed{
            buttomStartedY = view.frame.height - 40
            tableOffsetYOrigin = tableView.contentOffset.y
        }
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
                
                // TODO: 需要支持更多的type
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
                resq.HTTPBody = NSString(string: "uid=\(myUID!)&acode=\(myAcode!)&toid=\(thisChatID)&msgtype=string&body=\(thisMsgBody)").dataUsingEncoding(NSUTF8StringEncoding)
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
    
    func comfirmFriend(){
        print("确认添加好友")
    }
    func showBlackListOption(){
        UIActionSheet(title: "添加黑名单防止该用户骚扰", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "添加黑名单").showInView(view)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0{
            print("添加黑名单")
        }
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
