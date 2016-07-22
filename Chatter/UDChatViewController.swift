//
//  UDChatViewController.swift
//  Chatter
//
//  Created by David on 16/7/20.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    var chatroomID:String?
    var chatroomName:String?
    var myUID:String?
    
    var draft:String?
    
    private var buttomBar: UIVisualEffectView!
    private var tableView:UITableView!
    
    var inputTextView:UITextView!
    private var buttomOriginY:CGFloat!
    private var buttomStartedY:CGFloat!
    private var buttomOriginHeight:CGFloat!
    private var buttomChangeHeight:CGFloat = 0
    
    private var tableOffsetYOrigin:CGFloat!
    private var isKeyboardShowed = false
    private var isScrollToButtom = true
    //private var keyboardAnimating = false
    
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var msgList:NSMutableArray!
    
    let testMsg = ["你好","你好！😄","我们来测试一下吗？","好啊！","那就开始了喔","准备好了","Lorem ipsum dolor sit amet","consectetur adipisicing elit","仂猀呧觖陏鸆楥鈺劦圪瓬杈怭穻杈趓乇抯駃鉏。","爿旂怴裉祋靃葳鄎扙朹奅旲枌怙匉翜丌肸蜞塎。"]
    
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
        buttomOriginY = buttomBar.frame.origin.y
        inputTextView.delegate = self
        inputTextView.returnKeyType = .Send
        inputTextView.enablesReturnKeyAutomatically = true
        
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
        let userVC = UDUserViewController()
        // TODO: 传入uid
        userVC.uid = "4"
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userVC, animated: true)
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
            // TODO: 还没考虑群聊的情况, 和其他类型消息的情况
            let fromID = curItem.objectForKey("fromid") as! String
            let msgText = curItem.objectForKey("body") as! String
            if fromID != myUID{
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Left, text: msgText, uid: fromID)
            }else{
                bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: msgText, uid: fromID)
            }
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
    
    func gotoUser(){
        let userVC = UDUserViewController()
        // TODO: 传入uid
        userVC.uid = "4"
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
            
            let msgToSend = NSMutableDictionary()
            msgToSend.setValue("user", forKey: "send_from")
            msgToSend.setValue("\(myUID!)", forKey: "fromid")
            
            // TODO: 需要支持更多的type
            msgToSend.setValue("string", forKey: "type")
            
            msgToSend.setValue("\(inputTextView.text)", forKey: "body")
            let date = NSDate()
            let formate = NSDateFormatter()
            formate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timeStr = formate.stringFromDate(date)
            msgToSend.setValue("\(timeStr)", forKey: "time")
            msgToSend.setValue("\(chatroomName!)", forKey: "chatname")
            
//            {
//                "send_from":"user",
//                "fromid":"8",
//                "type":"string",
//                "body":"\u6d4b\u8bd5\u6d4b\u8bd5",
//                "time":"2016-07-21 23:22:32",
//                "chatname":"\u7cfb\u7edf\u6d88\u606f"
//            }
            
            msgList.addObject(msgToSend)
            tableView.reloadData()
            if tableView.contentSize.height > tableView.frame.height{
                tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: true)
            }
            
            let msgPath = "\(caches)/\(chatroomID!).plist"
            msgList.writeToFile(msgPath, atomically: true)
            inputTextView.text = ""
            
            return false
        }
        return true
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
