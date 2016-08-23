//
//  UDLoginViewController.swift
//  Chatter
//
//  Created by David on 16/7/13.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDLoginViewController: UIViewController {

    private var scrollView:UIScrollView!
    var navigationBar:UINavigationBar!
    
    private var emailTextField:UDTextField!
    private var passwordTextField:UDTextField!
    private var verifyTextField:UDTextField!
    private var forgetPswBtn:UIButton!
    private var verifyImg:UIButton!
    private var loginBtn:UIButton!
    private var msg:UILabel!
    
    private var spinnerBG:UIView!
    private var verifyNeed = false
    private var requireVerify:Bool{
        get{
            return verifyNeed
        }
        set(val){
            verifyNeed = val
            
            if val{
                self.passwordTextField.returnKeyType = .Next
                self.verifyTextField.alpha = 1
                self.forgetPswBtn.frame.origin.y = self.verifyImg.frame.origin.y
                self.verifyImg.alpha = 1
                self.loginBtn.frame.origin.y = self.verifyImg.frame.origin.y + self.verifyImg.frame.height + 8
                refreshVerifyImg()
                
            }
        }
    }
    @objc private func refreshVerifyImg(){
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/captcha.php")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.verifyImg.setImage(UIImage(data: data), forState: .Normal)
                    })
                }
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        view.addSubview(navigationBar)
        let navItem = UINavigationItem(title: "登陆")
        navigationBar.pushNavigationItem(navItem, animated: true)
        navItem.rightBarButtonItem = UIBarButtonItem(title: "注册", style: .Plain, target: self, action: #selector(UDLoginViewController.gotoReg))
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64))
        scrollView.keyboardDismissMode = .OnDrag
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
        
        emailTextField = UDTextField(frame: CGRect(x: 8, y: 24, width: self.view.frame.width - 16, height: 32))
        emailTextField.addTarget(self, action: #selector(UDLoginViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        
        passwordTextField = UDTextField(frame: CGRect(x: 8, y: 24 + emailTextField.frame.height + 8, width: self.view.frame.width - 16, height: 32))
        passwordTextField.textFieldType = .Password
        passwordTextField.addTarget(self, action: #selector(UDLoginViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        
        verifyTextField = UDTextField(frame: CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8, width: self.view.frame.width - 16, height: 32))
        verifyTextField.textFieldType = .Verify
        verifyTextField.addTarget(self, action: #selector(UDLoginViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        
        forgetPswBtn = UIButton(type: .System)
        forgetPswBtn.frame = CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + verifyTextField.frame.height + 8, width: 75, height: 32)
        forgetPswBtn.setTitle("忘记密码", forState: .Normal)
        forgetPswBtn.titleLabel?.textAlignment = .Left
        
        verifyImg = UIButton(frame: CGRect(x: self.view.frame.width - 91.2, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + verifyTextField.frame.height + 8, width: 83.2, height: 32))
        verifyImg.backgroundColor = UIColor.grayColor()
        verifyImg.contentMode = .ScaleToFill
        verifyImg.addTarget(self, action: #selector(UDLoginViewController.refreshVerifyImg), forControlEvents: .TouchUpInside)
        
        msg = UILabel(frame: CGRect(x: 8, y: 0, width: self.view.frame.width - 16, height: 32))
        msg.textColor = UIColor.redColor()
        msg.textAlignment = .Center
        msg.font = UIFont.systemFontOfSize(12)
        
        loginBtn = UIButton(type: .System)
        loginBtn.frame = CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + verifyTextField.frame.height + 8 + verifyImg.frame.height + 8, width: self.view.frame.width - 16, height: 32)
        loginBtn.setTitle("登陆", forState: .Normal)
        loginBtn.backgroundColor = UIColor(red: 81.0/255.0, green: 178.0/255.0, blue: 16.0/255.0, alpha: 1)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginBtn.layer.cornerRadius = 4
        loginBtn.addTarget(self, action: #selector(UDLoginViewController.login), forControlEvents: .TouchUpInside)
        loginBtn.adjustsImageWhenDisabled = true
        
        checkNeedVerify()
        
        spinnerBG = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinnerBG.center = view.center
        spinnerBG.backgroundColor = UIColor(white: 0, alpha: 0.75)
        spinnerBG.layer.cornerRadius = 5
        view.addSubview(spinnerBG)
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        spinner.center = CGPoint(x: 25, y: 25)
        spinner.activityIndicatorViewStyle = .White
        spinner.startAnimating()
        spinnerBG.addSubview(spinner)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().objectForKey("user") != nil{
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    private func checkNeedVerify(){
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/isRequireValidCode.php")!), queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    let result = NSString(data: data, encoding: NSUTF8StringEncoding)
                    if result != "0"{
                        self.requireVerify = true
                    }else{
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.verifyTextField.alpha = 0
                            self.forgetPswBtn.frame.origin.y = self.verifyTextField.frame.origin.y
                            self.verifyImg.alpha = 0
                            self.loginBtn.frame.origin.y = self.verifyImg.frame.origin.y
                            self.passwordTextField.returnKeyType = .Done
                        })
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.scrollView.addSubview(self.emailTextField)
                        self.scrollView.addSubview(self.passwordTextField)
                        self.scrollView.addSubview(self.verifyTextField)
                        self.scrollView.addSubview(self.forgetPswBtn)
                        self.scrollView.addSubview(self.verifyImg)
                        self.scrollView.addSubview(self.loginBtn)
                        self.scrollView.addSubview(self.msg)
                        self.emailTextField.becomeFirstResponder()
                        self.spinnerBG.alpha = 0
                    })
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func nextInput(sender: UDTextField){
        switch sender.tabIndex {
        case 0:
            passwordTextField.becomeFirstResponder()
            break
        case 1:
            if requireVerify{
                verifyTextField.becomeFirstResponder()
            }else{
                login()
            }
            break
        case 2:
            login()
            break
        default:
            break
        }
    }
    
    @objc private func login(){
        if checkInput() {
            postRequest()
        }
    }
    
    private func checkInput() ->Bool{
        if emailTextField.text == ""{
            setErrorMsg("请输入邮箱地址")
            emailTextField.becomeFirstResponder()
            return false
        }
        // MARK: 打开这段代码检查邮箱地址
        if emailTextField.text!.componentsSeparatedByString("@").count != 2{
            setErrorMsg("邮箱地址不正确")
            emailTextField.becomeFirstResponder()
            return false
        }
        
        if passwordTextField.text == ""{
            setErrorMsg("请输入密码")
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        // MARK: 打开这段代码检查密码长度
        /*
        if passwordTextField.text?.characters.count < 6{
            setErrorMsg("密码长度不足")
            passwordTextField.becomeFirstResponder()
            return false
        }
        */
        
        if requireVerify{
            if verifyTextField.text == ""{
                setErrorMsg("请输入验证码")
                verifyTextField.becomeFirstResponder()
                return false
            }
        }
        setErrorMsg("")
        return true
    }
    
    private func postingStatus(status: Bool){
        
        emailTextField.enabled = !status
        passwordTextField.enabled = !status
        verifyTextField.enabled = !status
        verifyImg.enabled = !status
        loginBtn.enabled = !status
        if status{
            spinnerBG.alpha = 1
        }else{
            spinnerBG.alpha = 0
        }
    }
    
    private func postRequest(){
        postingStatus(true)
        
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/login.php")!)
        resq.HTTPMethod = "POST"
        if requireVerify{
            resq.HTTPBody = NSString(string: "email=\(emailTextField.text!)&password=\(passwordTextField.text!)&verify=\(verifyTextField.text!)").dataUsingEncoding(NSUTF8StringEncoding)
        }else{
            resq.HTTPBody = NSString(string: "email=\(emailTextField.text!)&password=\(passwordTextField.text!)").dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.handleResult(data)
                    })
                }
            }
        }
    }
    
    private func handleResult(res: NSData){
        let jsonObj = try? NSJSONSerialization.JSONObjectWithData(res, options: .AllowFragments) as! NSDictionary
        if jsonObj != nil{
            if jsonObj?.objectForKey("error") != nil{
                let errCode = jsonObj?.objectForKey("error") as! Int
                switch errCode{
                case 101:
                    setErrorMsg("用户不存在，请注册")
                    emailTextField.becomeFirstResponder()
                    break
                case 102:
                    setErrorMsg("密码不正确，忘记密码？")
                    passwordTextField.becomeFirstResponder()
                    break
                case 103:
                    setErrorMsg("验证码不正确")
                    verifyTextField.becomeFirstResponder()
                    break
                default:
                    setErrorMsg("发生错误: \(errCode)")
                    break
                }
                requireVerify = true
                postingStatus(false)
            }else{
                // MARK: 登陆成功
                NSUserDefaults.standardUserDefaults().setObject(res, forKey: "user")
//                print(jsonObj)
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }

    private func setErrorMsg(message: String){
        msg.text = message
        if message != ""{
            UIView.animateWithDuration(0.1, delay: 0, options: .Autoreverse, animations: {
                self.msg.center.x -= 30
                }, completion: { (finished1) in
                    self.msg.center.x += 30
                    UIView.animateWithDuration(0.1, delay: 0, options: .Autoreverse, animations: {
                        self.msg.center.x -= 10
                        }, completion: { (finished2) in
                            self.msg.center.x += 10
                            UIView.animateWithDuration(0.1, delay: 0, options: .Autoreverse, animations: {
                                self.msg.center.x -= 5
                                }, completion: { (finished3) in
                                    self.msg.center.x += 5
                            })
                    })
            })
        }
    }
    
    @objc private func gotoReg(){
        let regVC = UDRegViewController()
        presentViewController(regVC, animated: true, completion: nil)
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
