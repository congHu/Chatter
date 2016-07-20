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
    
    let testMsg = ["你好","你好！😄","我们来测试一下吗？","好啊！","那就开始了喔","准备好了","Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","仂猀呧觖陏鸆楥鈺劦圪瓬杈怭穻杈趓乇抯駃鉏。夬悢忥趼枷灟溠筤优伈峇坌昅囷沇溰屮泑毾萺。敓一枵谹寍鉠乜幙噮仈，淂屮洒堄萏鉐乇摎冘夯。仈蚢孢崚殂麡雵搘匟旯宨扷坲炂阨塨乜岨慴滏。堷苃阤膷楱醑癿一傝蚸烒抩夯柀丌，殛堹兀泔籹筰狉阞屮侁禓笁夃帙。爿旂怴裉祋靃葳鄎扙朹奅旲枌怙匉翜丌肸蜞塎。蚺一峛唰雈頍屮碲謔卬，氪丌洐梒跕僋亍綼圠庂。猝一峔庴嵀嗐亍箑鬳冇，淠乇柘逡菡煝亍斠勼夗。揲妵邘彋萿輹艸一蛣厜俴抶刉籹乜，嗝琖兀炘侺艂刱氻屮垀勩壴仂抴。","仂猀呧觖陏鸆楥鈺劦圪瓬杈怭穻杈趓乇抯駃鉏。夬悢忥趼枷灟溠筤优伈峇坌昅囷沇溰屮泑毾萺。敓一枵谹寍鉠乜幙噮仈，淂屮洒堄萏鉐乇摎冘夯。仈蚢孢崚殂麡雵搘匟旯宨扷坲炂阨塨乜岨慴滏。堷苃阤膷楱醑癿一傝蚸烒抩夯柀丌，殛堹兀泔籹筰狉阞屮侁禓笁夃帙。爿旂怴裉祋靃葳鄎扙朹奅旲枌怙匉翜丌肸蜞塎。蚺一峛唰雈頍屮碲謔卬，氪丌洐梒跕僋亍綼圠庂。猝一峔庴嵀嗐亍箑鬳冇，淠乇柘逡菡煝亍斠勼夗。揲妵邘彋萿輹艸一蛣厜俴抶刉籹乜，嗝琖兀炘侺艂刱氻屮垀勩壴仂抴。","仂猀呧觖陏鸆楥鈺劦圪瓬杈怭穻杈趓乇抯駃鉏。夬悢忥趼枷灟溠筤优伈峇坌昅囷沇溰屮泑毾萺。敓一枵谹寍鉠乜幙噮仈，淂屮洒堄萏鉐乇摎冘夯。仈蚢孢崚殂麡雵搘匟旯宨扷坲炂阨塨乜岨慴滏。Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","仂猀呧觖陏鸆楥鈺劦圪瓬杈怭穻杈趓乇抯駃鉏。夬悢忥趼枷灟溠筤优伈峇坌昅囷沇溰屮泑毾萺。敓一枵谹寍鉠乜幙噮仈，淂屮洒堄萏鉐乇摎冘夯。仈蚢孢崚殂麡雵搘匟旯宨扷坲炂阨塨乜岨慴滏。Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."]
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UDChatViewController.keyboardWillUnShow(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: false)
    }
    func gotoSetting(){
        print("push UDChatSettingVC")
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return testMsg.count
        }
        return 1
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "msg")
        if indexPath.section == 0{
            if indexPath.row%2 == 0{
                let bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Left, text: testMsg[indexPath.row])
                cell.addSubview(bubble)
            }else{
                let bubble = UDChatBubble(frame: CGRect(x: 0, y: 16, width: cell.frame.width, height: cell.frame.height-32), style: .Right, text: testMsg[indexPath.row])
                cell.addSubview(bubble)
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let size = NSString(string: testMsg[indexPath.row]).boundingRectWithSize(CGSize(width: UIScreen.mainScreen().bounds.width*0.6, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
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
        
        
        UIView.animateWithDuration(time) { () -> Void in
            self.buttomBar.center.y -= height
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)
        }
        
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + height), animated: true)
        buttomStartedY = buttomBar.frame.origin.y + buttomChangeHeight
        isKeyboardShowed = true
    }
    
    func keyboardWillUnShow(noti:NSNotification){
        let info = noti.userInfo!
        var time:NSTimeInterval = 0
        let timeValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        timeValue.getValue(&time)
        UIView.animateWithDuration(time) { () -> Void in
            self.buttomBar.frame.origin.y = self.buttomOriginY - self.buttomChangeHeight
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        isKeyboardShowed = false
    }
    
    func textViewDidChange(textView: UITextView) {
        if !isKeyboardShowed{
            buttomStartedY = view.frame.height - 40
            tableOffsetYOrigin = tableView.contentOffset.y
        }
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
