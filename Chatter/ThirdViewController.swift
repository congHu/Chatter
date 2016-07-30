//
//  ThirdViewController.swift
//  Chatter
//
//  Created by David on 16/7/28.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView:UITableView!
    var titles:[String] = ["名字","地区","性别","生日","个性签名","隐私"]
    var uid:String?
    var active:String?
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var avatarImg:UIImage?
    var infos:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.frame, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        //是否登录。获取uid和acode
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            let loginVC = UDLoginViewController()
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
            active = user?.objectForKey("activecode") as? String
        }
        
        let avatarResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(uid!)&type=user")!)
        NSURLConnection.sendAsynchronousRequest(avatarResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if json == nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.avatarImg = UIImage(data: data)
                            data.writeToFile("\(self.caches)/avatar/user\(self.uid!).jpg", atomically: true)
                            self.tableView.reloadData()
                        })
                        
                        
                    }
                    
                }
            }
        })
        
        let infoResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getUserInfo.php?uid=\(uid!)")!)
        NSURLConnection.sendAsynchronousRequest(infoResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    if json != nil{
                        if json!.objectForKey("error") == nil{
                            self.infos = NSDictionary(dictionary: json!)
//                            print(self.infos)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2{
            return titles.count
        }
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "item")
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "头像"
            cell.accessoryType = .DisclosureIndicator
            let avatar = UIImageView(frame: CGRect(x: cell.frame.width - 80, y: 8, width: 48, height: 48))
            avatar.backgroundColor = UIColor.grayColor()
            if avatarImg != nil{
                avatar.image = avatarImg
            }
            
            cell.addSubview(avatar)
            break
        case 1:
            cell.textLabel?.text = "封面图"
            cell.accessoryType = .DisclosureIndicator
            break
        case 2:
            cell.textLabel?.text = titles[indexPath.row]
            
            switch indexPath.row {
                //["名字","地区","性别","生日","个性签名","隐私"]
            case 0:
                cell.detailTextLabel?.text = infos?.objectForKey("uname") as? String
                break
            case 1:
                cell.detailTextLabel?.text = infos?.objectForKey("area") as? String
                break
            case 2:
                cell.detailTextLabel?.text = infos?.objectForKey("gender") as? String
                break
            case 3:
                // TODO: 获取完整生日
                break
            case 4:
                cell.detailTextLabel?.text = infos?.objectForKey("description") as? String
                break
            default:
                break
            }
            cell.accessoryType = .DisclosureIndicator
            break
        case 3:
            let logoutBtn = UIButton(frame: CGRect(x: 8, y: 8, width: cell.frame.width - 16, height: 36))
            logoutBtn.backgroundColor = UIColor(r: 232, g: 76, b: 61, a: 255)
            logoutBtn.setTitle("退出当前账号", forState: .Normal)
            logoutBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            logoutBtn.layer.cornerRadius = 4
            cell.addSubview(logoutBtn)
            
            break
        default:
            break
        }
        return cell
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "头像"
        case 1:
            return "封面图"
        case 2:
            return "基本信息"
        default:
            return nil
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 64
        case 1:
            return 64
        case 3:
            return 48
        default:
            return 44
        }
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
