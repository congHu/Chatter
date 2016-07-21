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
            print("uid: " + uid!)
        }
        navBar.title = "连接中..."
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FirstViewController.timerElapse), userInfo: nil, repeats: true)
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        
        _ = try? NSFileManager.defaultManager().createDirectoryAtPath("\(caches)/avatar", withIntermediateDirectories: true, attributes: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func timerElapse(){
        navBar.title = "消息"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: "sd")
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        hidesBottomBarWhenPushed = true
        let chatVC = UDChatViewController()
        // TODO: 这是假数据
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

