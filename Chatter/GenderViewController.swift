//
//  GenderViewController.swift
//  Chatter
//
//  Created by David on 16/8/3.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class GenderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView:UITableView!
    var currentGender:String?
    var uidAndAcode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.frame, style: .Grouped)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: .Plain, target: self, action: #selector(GenderViewController.postResult))
        navigationItem.title = "设置性别"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "gender")
        if indexPath.row == 0{
            cell.textLabel?.text = "男"
        }else if indexPath.row == 1{
            cell.textLabel?.text = "女"
        }
        if currentGender != nil{
            if currentGender == "0"{
                if indexPath.row == 0{
                    cell.accessoryType = .Checkmark
                }
            }else if currentGender == "1"{
                if indexPath.row == 1{
                    cell.accessoryType = .Checkmark
                }
            }
            
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentGender = "\(indexPath.row)"
        tableView.reloadData()
    }
    func postResult(){
        let genderResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setAttr.php")!)
        genderResq.HTTPMethod = "POST"
        if uidAndAcode != nil{
            genderResq.HTTPBody = NSString(string: "\(uidAndAcode!)&attr=gender&value=\(currentGender!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(genderResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                var sendSuccess = false
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        if json?.objectForKey("error") == nil{
                            sendSuccess = true
                        }
                    }
                }
                if sendSuccess{
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        UIAlertView(title: "操作失败", message: nil, delegate: nil, cancelButtonTitle: "好").show()
                    })
                }
            })
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
