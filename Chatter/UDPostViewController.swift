//
//  UDPostViewController.swift
//  Chatter
//
//  Created by David on 16/7/31.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit
@objc protocol UDPostViewControllerDelegate {
    optional func postViewControllerDidSucceed()
    optional func postViewControllerDidFailed()
    optional func postViewControllerSetBody(content: String?) -> String?
}
class UDPostViewController: UIViewController, UITextViewDelegate {

    private var textView:UITextView!
    private var textViewBG:UIView!
    private var hintLabel:UILabel?
    var navigationTitle:String?
    var hint:String?
    var placeholder:String?
    var request:String!
    private var claarBtn:UIButton!
    private var charsIndicator:UILabel?
    var charsLimit:Int?
    var method:String = "POST"
    var HTTPBody:String?
    var delegate:UDPostViewControllerDelegate?
    convenience init(hint:String?, placeholder:String?, charsLimit:Int?, requestURL:String!){
        self.init()
        self.hint = hint
        self.placeholder = placeholder
        self.charsLimit = charsLimit
        self.request = requestURL
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 外观混乱，Textview文字地方不对，hintLabel也见不到，灰色需要再浅一些，加上scrollView的拖拽隐藏键盘，而且一加载textView马上获得焦点
        view.backgroundColor = UIColor.lightGrayColor()
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        textViewBG = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 116))
        textViewBG.backgroundColor = UIColor.whiteColor()
        view.addSubview(textViewBG)
        textViewBG.addSubview(textView)
        if hint != nil{
            let size = NSString(string: hint!).boundingRectWithSize(CGSize(width: view.frame.width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
            hintLabel = UILabel(frame: CGRect(x: 0, y: 8, width: view.frame.width, height: size.height))
            hintLabel?.font = UIFont.systemFontOfSize(14)
            view.addSubview(hintLabel!)
            textViewBG.frame = CGRect(x: 0, y: size.height + 16, width: view.frame.width, height: 100)
        }
        if placeholder != nil{
            textView.text = placeholder
        }
        
        claarBtn = UIButton(frame: CGRect(x: view.frame.width - 32, y: 100, width: 16, height: 16))
        claarBtn.setImage(UIImage(named: "clear"), forState: .Normal)
        claarBtn.addTarget(self, action: #selector(UDPostViewController.clearText), forControlEvents: .TouchUpInside)
        textViewBG.addSubview(claarBtn)
        
        if charsLimit != nil{
            charsIndicator = UILabel(frame: CGRect(x: claarBtn.frame.origin.x - 48, y: claarBtn.frame.origin.y, width: 40, height: 16))
            charsIndicator?.textColor = UIColor.grayColor()
            charsIndicator?.text = "\(charsLimit!)"
            textViewBG.addSubview(charsIndicator!)
        }
        textView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: .Plain, target: self, action: #selector(UDPostViewController.sendRequest))
        
    }
    func clearText(){
        textView.text = ""
    }
    func sendRequest(){
        let resq = NSMutableURLRequest(URL: NSURL(string: request)!)
        resq.HTTPMethod = method
        HTTPBody = self.delegate?.postViewControllerSetBody!(textView.text)
        if HTTPBody != nil{
            resq.HTTPBody = NSString(string: HTTPBody!).dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue()) { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
            var sendSuccess = false
            if err == nil{
                if let data = returnData{
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    if json != nil{
                        if json?.objectForKey("error") == nil{
                            sendSuccess = true
                        }
                    }
                }
            }
            if sendSuccess{
                self.delegate?.postViewControllerDidSucceed!()
            }else{
                self.delegate?.postViewControllerDidFailed!()
            }
        }
    }
    func textViewDidChange(textView: UITextView) {
        if charsLimit != nil{
            charsIndicator?.text = "\(charsLimit! - textView.text.characters.count)"
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if charsLimit != nil{
            if textView.text.characters.count >= charsLimit{
                return false
            }
        }
        return true
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
