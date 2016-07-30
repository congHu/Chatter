//
//  UDSearchViewController.swift
//  Chatter
//
//  Created by David on 16/7/28.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var myUID:String?
    var myAcode:String?
    var rootVC:FirstViewController?
    
    var searchBar:UISearchBar!
    var tableView:UITableView!
    
    var searchResult:NSArray?
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    
    var pushFromTab2 = false
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "搜索好友"
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 64, width: view.frame.width, height: 44))
        searchBar.placeholder = "输入邮箱地址或用户名"
        searchBar.delegate = self
        searchBar.keyboardType = .EmailAddress
        searchBar.autocorrectionType = .No
        searchBar.autocapitalizationType = .None
//        searchBar.returnKeyType = .Search
        view.addSubview(searchBar)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 108, width: view.frame.width, height: view.frame.height - 108))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResult != nil{
            if searchResult?.count > 0{
                return (searchResult?.count)!
            }
        }
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "people")
        if searchResult != nil{
            if searchResult?.count > 0{
                let res = searchResult?.objectAtIndex(indexPath.row) as! NSDictionary
                print(res)
                // MARK: 头像
                let avatar = UIImageView(frame: CGRect(x: 16, y: 8, width: 48, height: 48))
                avatar.backgroundColor = UIColor.grayColor()
                
                let fid = res.objectForKey("uid") as! String
                let avatarImgPath = "\(caches)/avatar/user\(fid).jpg"
                if NSFileManager.defaultManager().fileExistsAtPath(avatarImgPath){
                    avatar.image = UIImage(contentsOfFile: avatarImgPath)
                }else{
                    NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(fid)&type=user")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
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
                
                let unameLabel = UILabel(frame: CGRect(x: avatar.frame.origin.x + avatar.frame.width + 8, y: 8, width: cell.frame.width - 100 - avatar.frame.width, height: 20))
                unameLabel.text = res.objectForKey("uname") as? String
                
                cell.addSubview(unameLabel)
                
                let subLabel = UILabel(frame: CGRect(x: unameLabel.frame.origin.x, y: 36, width: cell.frame.width - 60 - avatar.frame.width, height: 20))
                subLabel.textColor = UIColor.grayColor()
                subLabel.font = UIFont.systemFontOfSize(14)
                cell.addSubview(subLabel)
                
                var subTitle = ""
                if (res.objectForKey("area") as? String) != nil{
                    subTitle += res.objectForKey("area") as! String
                    subTitle += " "
                }
                if (res.objectForKey("gender") as? String) != nil{
                    let gender = res.objectForKey("gender") as! String
                    if gender == "0"{
                        subTitle += "男"
                    }else if gender == "1"{
                        subTitle += "女"
                    }
                    subTitle += " "
                }
                if res.objectForKey("age") != nil{
                    if (res.objectForKey("age") as? Int) != nil{
                        subTitle += "\(res.objectForKey("age") as! Int)"
                        subTitle += "岁"
                    }
                }
                subLabel.text = subTitle
            }else{
                cell.textLabel?.text = "没有找到\"\(searchBar.text!)\"相关的用户"
            }
            
            
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("search")
        // MARK: 搜索
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/searchFriend.php?input=\(searchBar.text!)")!), queue: NSOperationQueue()) { (resp:NSURLResponse?, returnDara:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnDara{
                    let jsonAry = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSArray
//                    print(jsonAry)
                    self.searchResult = NSArray(array: jsonAry!)
                    dispatch_async(dispatch_get_main_queue(), { 
//                        self.tableView.dataSource = self
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchResult != nil{
            if searchResult?.count > 0{
                let userVC = UDUserViewController()
                // MARK: 进入用户详情
                let res = searchResult?.objectAtIndex(indexPath.row) as! NSDictionary
                userVC.thisUid = res.objectForKey("uid") as? String
                userVC.myUID = myUID
                userVC.acode = myAcode
                userVC.rootVC = self.rootVC
                userVC.needToTab = pushFromTab2
                hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(userVC, animated: true)
            }
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
