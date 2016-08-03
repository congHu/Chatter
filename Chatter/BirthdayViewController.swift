//
//  BirthdayViewController.swift
//  Chatter
//
//  Created by David on 16/8/3.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {

    var birthday:String?
    var showLabel:UILabel!
    var datePicker:UIDatePicker!
    var uidAndAcode:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date:NSDate?
        if birthday == nil{
            date = NSDate()
            birthday = formatter.stringFromDate(date!)
        }else{
            
            date = formatter.dateFromString(birthday!)
        }
        
        
        showLabel = UILabel(frame: CGRect(x: 0, y: 80, width: view.frame.width, height: 80))
        showLabel.font = UIFont.systemFontOfSize(48)
        showLabel.textAlignment = .Center
        view.addSubview(showLabel)
        showLabel.text = birthday
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 200))
        datePicker.backgroundColor = UIColor.lightGrayColor()
        datePicker.date = date!
        datePicker.datePickerMode = .Date
        datePicker.minimumDate = formatter.dateFromString("1900-01-01")
        datePicker.maximumDate = NSDate()
        view.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(BirthdayViewController.dateChange(_:)), forControlEvents: .ValueChanged)
        
        navigationItem.title = "设置生日"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: .Plain, target: self, action: #selector(BirthdayViewController.postBirthday))
        
    }

    func dateChange(sender:UIDatePicker){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        birthday = formatter.stringFromDate(sender.date)
        showLabel.text = birthday
    }
    
    func postBirthday(){
        let genderResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setAttr.php")!)
        genderResq.HTTPMethod = "POST"
        if uidAndAcode != nil{
            genderResq.HTTPBody = NSString(string: "\(uidAndAcode!)&attr=birthday&value=\(birthday!)").dataUsingEncoding(NSUTF8StringEncoding)
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
