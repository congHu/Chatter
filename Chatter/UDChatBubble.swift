//
//  UDChatBubble.swift
//  Chatter
//
//  Created by David on 16/7/20.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

enum UDChatBubbleStyle {
    case Right
    case Left
    case System
    case Req
}

class UDChatBubble: UIView {
    
    private var bubbleStyle:UDChatBubbleStyle = .System
    private var bubbleBG:UIView!
    private var textContainer:UILabel!
    private var content:String! = "System test text"
    private var maxWidth:CGFloat!
    private var uid:String?
    var avatar:UIButton?
    var style:UDChatBubbleStyle{
        get {
            return bubbleStyle
        }
    }

    var statusView:UDSendStatusView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, style: UDChatBubbleStyle, text: String, uid: String?) {
        self.init(frame: frame)
        bubbleStyle = style
        content = text
        self.uid = uid
        load()
    }
    
    func load(){
        self.backgroundColor = UIColor.clearColor()
        maxWidth = UIScreen.mainScreen().bounds.width*0.6
        textContainer = UILabel()
        textContainer.numberOfLines = 0
        if bubbleStyle != .System{
            textContainer.font = UIFont.systemFontOfSize(14)
        }else{
            textContainer.font = UIFont.systemFontOfSize(10)
        }
        
        let size = NSString(string: content).boundingRectWithSize(CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: textContainer.font], context: nil)
        
        switch bubbleStyle {
        case .Left:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.15, y: 0, width: size.width + 16, height: size.height + 16))
            bubbleBG.backgroundColor = UIColor(r: 53, g: 152, b: 219, a: 225)
            bubbleBG.layer.cornerRadius = 8
            avatar = UIButton(frame: CGRect(x: 8, y: 0, width: UIScreen.mainScreen().bounds.width*0.1, height: UIScreen.mainScreen().bounds.width*0.1))
            avatar?.tag = Int(uid!)!
            break
            // TODO: 好友请求显示
        case .Req:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.15, y: 0, width: size.width + 16, height: size.height + 16))
            bubbleBG.backgroundColor = UIColor(r: 53, g: 152, b: 219, a: 225)
            bubbleBG.layer.cornerRadius = 8
            avatar = UIButton(frame: CGRect(x: 8, y: 0, width: UIScreen.mainScreen().bounds.width*0.1, height: UIScreen.mainScreen().bounds.width*0.1))
            avatar?.tag = Int(uid!)!
            break
        case .Right:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.85 - size.width - 16, y: 0, width: size.width + 16, height: size.height + 16))
            bubbleBG.backgroundColor = UIColor(r: 39, g: 174, b: 97, a: 255)
            bubbleBG.layer.cornerRadius = 8
            avatar = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.9 - 8, y: 0, width: UIScreen.mainScreen().bounds.width*0.1, height: UIScreen.mainScreen().bounds.width*0.1))
            avatar?.tag = Int(uid!)!
//            statusView = UDSendStatusView(frame: CGRect(x: bubbleBG.frame.origin.x - 28, y: bubbleBG.frame.height - 28, width: 20, height: 20))
//            self.addSubview(statusView!)
            
            
            break
        case .System:
            textContainer.frame = CGRect(x: 4, y: 0, width: size.width, height: size.height)
            
            bubbleBG = UIView(frame: CGRect(x: 0, y: 0, width: size.width + 8, height: size.height + 4))
            bubbleBG.center.x = UIScreen.mainScreen().bounds.width/2
            bubbleBG.backgroundColor = UIColor(hex: "cccccc")
            bubbleBG.layer.cornerRadius = 4
            
            break
        }
        
        textContainer.center.y = bubbleBG.center.y
        textContainer.text = content
        textContainer.textColor = UIColor.whiteColor()
        self.addSubview(bubbleBG)
        bubbleBG.addSubview(textContainer)
        avatar?.backgroundColor = UIColor.grayColor()
        avatar?.adjustsImageWhenHighlighted = true
        if bubbleStyle != .System{
            
            // MARK: 获取本地头像，没有的话才请求数据库
            let caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
            
            if NSFileManager.defaultManager().fileExistsAtPath("\(caches)/avatar/user\(uid!).jpg"){
                avatar?.setImage(UIImage(contentsOfFile: "\(caches)/avatar/user\(uid!).jpg"), forState: .Normal)
            }else{
                let resq = NSURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/getAvatar.php?uid=\(uid!)&type=user")!)
                NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                    if err == nil{
                        if let data = returnData{
                            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                            if json == nil{
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.avatar?.setImage(UIImage(data: data), forState: .Normal)
                                    data.writeToFile("\(caches)/avatar/user\(self.uid!).jpg", atomically: true)
                                })
                            }
                        }
                    }
                })
            }
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        switch bubbleStyle {
        case .Left:
            let leftEdge = bubbleBG.frame.origin.x
            CGContextSetFillColorWithColor(context, UIColor(r: 53, g: 152, b: 219, a: 225).CGColor)
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, leftEdge - 3.464, 8)
            CGContextAddLineToPoint(context, leftEdge, 6)
            CGContextAddLineToPoint(context, leftEdge, 10)
            CGContextFillPath(context)
            break
        case .Req:
            let leftEdge = bubbleBG.frame.origin.x
            CGContextSetFillColorWithColor(context, UIColor(r: 53, g: 152, b: 219, a: 225).CGColor)
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, leftEdge - 3.464, 8)
            CGContextAddLineToPoint(context, leftEdge, 6)
            CGContextAddLineToPoint(context, leftEdge, 10)
            CGContextFillPath(context)
            break
        case .Right:
            let rightEdge = bubbleBG.center.x + bubbleBG.frame.width/2
            CGContextSetFillColorWithColor(context, UIColor(r: 37, g: 174, b: 97, a: 255).CGColor)
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, rightEdge + 3.464, 8)
            CGContextAddLineToPoint(context, rightEdge, 6)
            CGContextAddLineToPoint(context, rightEdge, 10)
            CGContextClosePath(context)
            CGContextFillPath(context)
            break
        default:
            break
        }
        
        if avatar != nil{
            self.addSubview(avatar!)
            bringSubviewToFront(avatar!)
        }

        
    }
    

}
