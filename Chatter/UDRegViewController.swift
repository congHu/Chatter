//
//  UDRegViewController.swift
//  Chatter
//
//  Created by David on 16/7/13.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDRegViewController: UIViewController {

    private var scrollView:UIScrollView!
    var navigationBar:UINavigationBar!
    
    private var emailTextField:UDTextField!
    private var passwordTextField:UDTextField!
    private var verifyTextField:UDTextField!
    private var verifyImg:UIButton!
    private var registerBtn:UIButton!
    private var msg:UILabel!
    
    private var spinnerBG:UIView!
    
    //register compare with login
    
    private var passwordConfirmTextField:UDTextField!
    
    // DEL: private var forgetPswBtn:UIButton!
    // DEL: requireVerify:Bool
    // DEL: func checkNeedVerify()
    
    @objc private func refreshVerifyImg(){
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/captcha.php")!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            if err == nil{
                if let data = returnData{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.verifyImg.setImage(UIImage(data: data), forState: .Normal)
                        self.spinnerBG.alpha = 0
                    })
                }
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        self.modalTransitionStyle = .CrossDissolve
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        view.addSubview(navigationBar)
        let navItem = UINavigationItem(title: "注册")
        navigationBar.pushNavigationItem(navItem, animated: true)
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登陆", style: .Plain, target: self, action: #selector(UDRegViewController.gotoLogin))
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64))
        scrollView.keyboardDismissMode = .OnDrag
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
        
        emailTextField = UDTextField(frame: CGRect(x: 8, y: 24, width: self.view.frame.width - 16, height: 32))
        emailTextField.addTarget(self, action: #selector(UDRegViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        
        passwordTextField = UDTextField(frame: CGRect(x: 8, y: 24 + emailTextField.frame.height + 8, width: self.view.frame.width - 16, height: 32))
        passwordTextField.textFieldType = .Password
        passwordTextField.addTarget(self, action: #selector(UDRegViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        passwordTextField.placeholder = "设置密码"
        
        passwordConfirmTextField = UDTextField(frame: CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8, width: self.view.frame.width - 16, height: 32))
        passwordConfirmTextField.textFieldType = .Password
        passwordConfirmTextField.tabIndex = 2
        passwordConfirmTextField.addTarget(self, action: #selector(UDRegViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        passwordConfirmTextField.placeholder = "确认密码"
        
        verifyTextField = UDTextField(frame: CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + passwordConfirmTextField.frame.height + 8, width: self.view.frame.width - 16, height: 32))
        verifyTextField.textFieldType = .Verify
        verifyTextField.tabIndex = 3
        verifyTextField.addTarget(self, action: #selector(UDRegViewController.nextInput(_:)), forControlEvents: .EditingDidEndOnExit)
        
        verifyImg = UIButton(frame: CGRect(x: self.view.frame.width - 91.2, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + passwordConfirmTextField.frame.height + 8 + verifyTextField.frame.height + 8, width: 83.2, height: 32))
        verifyImg.backgroundColor = UIColor.grayColor()
        verifyImg.contentMode = .ScaleToFill
        verifyImg.addTarget(self, action: #selector(UDRegViewController.refreshVerifyImg), forControlEvents: .TouchUpInside)
        
        msg = UILabel(frame: CGRect(x: 8, y: 0, width: self.view.frame.width - 16, height: 32))
        msg.textColor = UIColor.redColor()
        msg.textAlignment = .Center
        msg.font = UIFont.systemFontOfSize(12)
        
        registerBtn = UIButton(type: .System)
        registerBtn.frame = CGRect(x: 8, y: 24 + emailTextField.frame.height + 8 + passwordTextField.frame.height + 8 + passwordConfirmTextField.frame.height + 8 + verifyTextField.frame.height + 8 + verifyImg.frame.height + 8, width: self.view.frame.width - 16, height: 32)
        registerBtn.setTitle("注册", forState: .Normal)
        registerBtn.backgroundColor = UIColor(red: 81.0/255.0, green: 178.0/255.0, blue: 16.0/255.0, alpha: 1)
        registerBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        registerBtn.layer.cornerRadius = 4
        registerBtn.addTarget(self, action: #selector(UDRegViewController.register), forControlEvents: .TouchUpInside)
        registerBtn.adjustsImageWhenDisabled = true
        
        
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
        
        refreshVerifyImg()
        
        self.scrollView.addSubview(self.emailTextField)
        self.scrollView.addSubview(self.passwordTextField)
        self.scrollView.addSubview(self.passwordConfirmTextField)
        self.scrollView.addSubview(self.verifyTextField)
        self.scrollView.addSubview(self.verifyImg)
        self.scrollView.addSubview(self.registerBtn)
        self.scrollView.addSubview(self.msg)
        self.emailTextField.becomeFirstResponder()
        
        
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
            passwordConfirmTextField.becomeFirstResponder()
            break
        case 2:
            verifyTextField.becomeFirstResponder()
            break
        case 3:
            register()
            break
        default:
            break
        }
    }
    
    @objc private func register(){
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
        
        if passwordTextField.text?.characters.count < 6{
            setErrorMsg("密码长度不足")
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        if passwordTextField.text != passwordConfirmTextField.text{
            setErrorMsg("两次密码不一致")
            passwordConfirmTextField.becomeFirstResponder()
            return false
        }
        
        if verifyTextField.text == ""{
            setErrorMsg("请输入验证码")
            verifyTextField.becomeFirstResponder()
            return false
        }
        setErrorMsg("")
        return true
    }
    
    private func postingStatus(status: Bool){
        
        emailTextField.enabled = !status
        passwordTextField.enabled = !status
        passwordConfirmTextField.enabled = !status
        verifyTextField.enabled = !status
        verifyImg.enabled = !status
        registerBtn.enabled = !status
        if status{
            spinnerBG.alpha = 1
        }else{
            spinnerBG.alpha = 0
        }
    }
    
    private func postRequest(){
        postingStatus(true)
        
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/register.php")!)
        resq.HTTPMethod = "POST"
        resq.HTTPBody = NSString(string: "email=\(emailTextField.text!)&password=\(passwordTextField.text!)&verify=\(verifyTextField.text!)").dataUsingEncoding(NSUTF8StringEncoding)
        
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
        if jsonObj?.objectForKey("error") != nil{
            let errCode = jsonObj?.objectForKey("error") as! Int
            switch errCode{
            case 103:
                setErrorMsg("验证码不正确")
                verifyTextField.becomeFirstResponder()
                break
            case 111:
                setErrorMsg("用户名已注册，请登录")
                break
            default:
                setErrorMsg("发生错误: \(errCode)")
                break
            }
            postingStatus(false)
            refreshVerifyImg()
        }else{
            // MARK: 注册完成
            let returnData = try? NSJSONSerialization.JSONObjectWithData(res, options: .AllowFragments) as! NSDictionary
            let user = NSMutableDictionary()
            user.setObject(returnData?.objectForKey("activecode") as! String, forKey: "activecode")
            user.setObject("0", forKey: "isActive")
            user.setObject(returnData?.objectForKey("uid") as! String, forKey: "uid")
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(user, options: .PrettyPrinted)
            NSUserDefaults.standardUserDefaults().setObject(jsonData!, forKey: "user")
            dismissViewControllerAnimated(false, completion: nil)
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
    
    @objc private func gotoLogin(){
        dismissViewControllerAnimated(true, completion: nil)
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
