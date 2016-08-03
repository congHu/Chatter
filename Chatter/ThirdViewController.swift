//
//  ThirdViewController.swift
//  Chatter
//
//  Created by David on 16/7/28.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UDPostViewControllerDelegate {

    var tableView:UITableView!
    var titles:[String] = ["名字","地区","性别","生日","个性签名","隐私"]
    var uid:String?
    var active:String?
    let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
    var avatar:UIImageView!
    var bgImgView:UIImageView!
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
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().objectForKey("user") == nil{
            let loginVC = UDLoginViewController()
            presentViewController(loginVC, animated: false, completion: nil)
        }else{
            let data = NSUserDefaults.standardUserDefaults().objectForKey("user") as! NSData
            let user = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            uid = user?.objectForKey("uid") as? String
            active = user?.objectForKey("activecode") as? String
            
            
            let avatarResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(uid!)&type=user")!)
            NSURLConnection.sendAsynchronousRequest(avatarResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                        if json == nil{
                            dispatch_async(dispatch_get_main_queue(), {
                                self.avatar.image = UIImage(data: data)
                                data.writeToFile("\(self.caches)/avatar/user\(self.uid!).jpg", atomically: true)
                            })
                            
                            
                        }
                        
                    }
                }
            })
            
            
            
            
            let bgResq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getBGImg.php?uid=\(uid!)")!)
            NSURLConnection.sendAsynchronousRequest(bgResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                        if json == nil{
                            if data.length != 0{
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.bgImgView.image = UIImage(data: data)
                                    data.writeToFile("\(self.caches)/bg_img/\(self.uid!).jpg", atomically: true)
                                })
                            }
                            
                            
                            
                        }
                        
                    }
                }
            })
            
            let infoResq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getPrivateInfo.php")!)
            infoResq.HTTPMethod = "POST"
            infoResq.HTTPBody = NSString(string: "uid=\(uid!)&acode=\(active!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(infoResq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        if json != nil{
                            if json!.objectForKey("error") == nil{
                                
                                self.infos = NSDictionary(dictionary: json!)
                                print(self.infos)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.tableView.reloadData()
                                })
                                
                            }
                        }
                    }
                }
            })
            
        }
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
            avatar = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 8, width: 48, height: 48))
            avatar.backgroundColor = UIColor.grayColor()
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/avatar/user\(uid!).jpg"){
                avatar.image = UIImage(contentsOfFile: "\(caches)/avatar/user\(uid!).jpg")
            }
            
            cell.addSubview(avatar)
            break
        case 1:
            cell.textLabel?.text = "封面图"
            cell.accessoryType = .DisclosureIndicator
            bgImgView = UIImageView(frame: CGRect(x: view.frame.width - 80, y: 8, width: 48, height: 48))
            bgImgView.backgroundColor = UIColor.grayColor()
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/bg_img/user\(uid!).jpg"){
                bgImgView.image = UIImage(contentsOfFile: "\(caches)/bg_img/user\(uid!).jpg")
            }
            
            cell.addSubview(bgImgView)
            break
        case 2:
            cell.textLabel?.text = titles[indexPath.row]
            let subLabel = UILabel(frame: CGRect(x: view.frame.width - 132, y: 8, width: 100, height: 28))
            subLabel.font = UIFont.systemFontOfSize(14)
            subLabel.textColor = UIColor.grayColor()
            subLabel.textAlignment = .Right
//            subLabel.backgroundColor = UIColor.greenColor()
            cell.addSubview(subLabel)
            switch indexPath.row {
                //["名字","地区","性别","生日","个性签名","隐私"]
            case 0:
                subLabel.text = infos?.objectForKey("uname") as? String
                break
            case 1:
                subLabel.text = infos?.objectForKey("area") as? String
                break
            case 2:
                let gender = infos?.objectForKey("gender") as? String
                if gender != nil{
                    if gender == "0"{
                        subLabel.text = "男"
                    }else if gender == "1"{
                        subLabel.text = "女"
                    }
                }
                break
            case 3:
                subLabel.text = infos?.objectForKey("birthday") as? String
                break
            default:
                break
            }
            cell.accessoryType = .DisclosureIndicator
            break
        case 3:
            let logoutBtn = UIButton(frame: CGRect(x: 8, y: 8, width: view.frame.width - 16, height: 36))
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let as1 = UIActionSheet(title: "修改头像", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            as1.tag = 1
            as1.addButtonWithTitle("拍照")
            as1.addButtonWithTitle("选择照片")
            as1.addButtonWithTitle("取消")
            as1.cancelButtonIndex = as1.numberOfButtons - 1
            as1.showInView(view)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 1:
            let as2 = UIActionSheet(title: "修改封面图", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            as2.tag = 2
            as2.addButtonWithTitle("拍照")
            as2.addButtonWithTitle("选择照片")
            as2.addButtonWithTitle("取消")
            as2.cancelButtonIndex = as2.numberOfButtons - 1
            as2.showInView(view)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            break
        case 2:
            //   0     1     2      3       4       5
            //["名字","地区","性别","生日","个性签名","隐私"]
            let setAttrUrl = "http://119.29.225.180/notecloud/setAttr.php"
            switch indexPath.row {
            case 0:
                let unamePost = UDPostViewController(hint: "输入用户名", placeholder: infos?.objectForKey("uname") as? String, charsLimit: 10, requestURL: setAttrUrl)
                unamePost.delegate = self
                unamePost.navigationTitle = "用户名"
                unamePost.navSendButtonTitle = "设置"
                hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(unamePost, animated: true)
                break
            case 1:
                break
            case 2:
                let genderPost = GenderViewController()
                genderPost.currentGender = infos?.objectForKey("gender") as? String
                genderPost.uidAndAcode = "uid=\(uid!)&acode=\(active!)"
                hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(genderPost, animated: true)
                break
            case 3:
                let birthdayPost = BirthdayViewController()
                birthdayPost.birthday = infos?.objectForKey("birthday") as? String
                birthdayPost.uidAndAcode = "uid=\(uid!)&acode=\(active!)"
                hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(birthdayPost, animated: true)
                break
            case 4:
                let descPost = UDPostViewController(hint: "输入个性签名", placeholder: infos?.objectForKey("description") as? String, charsLimit: 70, requestURL: setAttrUrl)
                descPost.delegate = self
                descPost.navigationTitle = "个性签名"
                descPost.navSendButtonTitle = "设置"
                hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(descPost, animated: true)
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    func postViewControllerSetBody(postVC: UDPostViewController, content: String?) -> String? {
        if postVC.navigationTitle != nil{
            switch postVC.navigationTitle! {
            case "用户名":
                return "uid=\(uid!)&acode=\(active!)&attr=uname&value=\(content!)"
            case "个性签名":
                return "uid=\(uid!)&acode=\(active!)&attr=description&value=\(content!)"
            default:
                return nil
            }
        }
        return nil
    }
    func postViewControllerDidSucceed(postVC: UDPostViewController, content: String?) {
        navigationController?.popViewControllerAnimated(true)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch actionSheet.tag {
        case 1:
            
            switch buttonIndex {
            case 0:
                
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                picker.allowsEditing = true
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
                picker.allowsEditing = true
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                picker.view.tag = 1
                presentViewController(picker, animated: true, completion: nil)
                break
            default:
                break
            }
            break
        case 2:
            switch buttonIndex {
            case 0:
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                picker.allowsEditing = true
                picker.view.tag = 2
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
                picker.allowsEditing = true
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                picker.view.tag = 2
                presentViewController(picker, animated: true, completion: nil)
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func resizeImg(img:UIImage, _ width:CGFloat) ->UIImage{
        let newsize = CGSize(width: width, height: (width/img.size.width)*img.size.height)
        UIGraphicsBeginImageContext(newsize)
        img.drawInRect(CGRectMake(0, 0, newsize.width, newsize.height))
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimg
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            if picker.view.tag == 1{
                print("头像")
                let img = self.resizeImg(image, 128)
                let imgData = UIImageJPEGRepresentation(img, 0.5)
                
                let filename = "user\(self.uid!).jpg"
                let path = "\(self.caches)/avatar/\(filename)"
                
                let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setAvatar.php")!)
                resq.HTTPMethod = "POST"
                let postData = NSMutableData()
                /*
                 POST /notecloud/setAvatar.php HTTP/1.1
                 Host: 119.29.225.180
                 Cache-Control: no-cache
                 Postman-Token: 18a2dca6-4899-93a5-b531-741176b24389
                 Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
                 
                 ------WebKitFormBoundary7MA4YWxkTrZu0gW \r\n
                 Content-Disposition: form-data; name="uid" \r\n
                 \r\n
                 6 \r\n
                 ------WebKitFormBoundary7MA4YWxkTrZu0gW \r\n
                 Content-Disposition: form-data; name="acode" \r\n
                 \r\n
                 7MEZ2hJkIOGL3aZj \r\n
                 ------WebKitFormBoundary7MA4YWxkTrZu0gW \r\n
                 Content-Disposition: form-data; name="file"; filename="file.jpg" \r\n
                 Content-Type: image/jpeg \r\n
                 \r\n
                 <...> \r\n
                 ------WebKitFormBoundary7MA4YWxkTrZu0gW-- \r\n
                */
                
                resq.setValue("multipart/form-data; boundary=AaB03x", forHTTPHeaderField: "Content-Type")
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"uid\";\r\n\r\n\(self.uid!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"acode\";\r\n\r\n\(self.active!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(imgData!)
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
                                dispatch_async(dispatch_get_main_queue(), { 
                                    imgData?.writeToFile(path, atomically: true)
                                    self.avatar.image = img
                                })
                            }
                        }
                        
                    }
                    if !sendSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            UIAlertView(title: "上传失败", message: nil, delegate: nil, cancelButtonTitle: "好").show()
                        })
                        
                    }
                }
            }else if picker.view.tag == 2{
                print("封面图")
                let img = self.resizeImg(image, 480)
                let imgData = UIImageJPEGRepresentation(img, 0.5)
                
                let filename = "user\(self.uid!).jpg"
                let path = "\(self.caches)/bg_img/\(filename)"
                
                let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setBGImg.php")!)
                resq.HTTPMethod = "POST"
                let postData = NSMutableData()
                
                resq.setValue("multipart/form-data; boundary=AaB03x", forHTTPHeaderField: "Content-Type")
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"uid\";\r\n\r\n\(self.uid!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"acode\";\r\n\r\n\(self.active!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(NSString(string: "--AaB03x\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(imgData!)
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
                                dispatch_async(dispatch_get_main_queue(), {
                                    imgData?.writeToFile(path, atomically: true)
                                    self.bgImgView.image = img
                                })
                            }
                        }
                        
                    }
                    if !sendSuccess{
                        dispatch_async(dispatch_get_main_queue(), {
                            UIAlertView(title: "上传失败", message: nil, delegate: nil, cancelButtonTitle: "好").show()
                        })
                        
                    }
                }
            }
            
        })
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidesBottomBarWhenPushed = false
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
