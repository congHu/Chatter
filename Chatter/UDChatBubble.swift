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
}

class UDChatBubble: UIView {
    
    private var bubbleStyle:UDChatBubbleStyle = .System
    private var bubbleBG:UIView!
    private var textContainer:UILabel!
    private var content:String! = "System test text"
    private var maxWidth:CGFloat!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, style: UDChatBubbleStyle, text: String) {
        self.init(frame: frame)
        bubbleStyle = style
        content = text
        load()
    }
    
    func load(){
        self.backgroundColor = UIColor.clearColor()
        maxWidth = UIScreen.mainScreen().bounds.width*0.6
        textContainer = UILabel()
        textContainer.numberOfLines = 0
        textContainer.font = UIFont.systemFontOfSize(14)
        let size = NSString(string: content).boundingRectWithSize(CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: textContainer.font], context: nil)
        
        switch bubbleStyle {
        case .Left:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.15, y: 0, width: size.width + 16, height: size.height + 16))
            bubbleBG.backgroundColor = UIColor(r: 53, g: 152, b: 219, a: 225)
            bubbleBG.layer.cornerRadius = 8
            setNeedsDisplay()
            break
        case .Right:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width*0.85 - size.width - 8, y: 0, width: size.width + 16, height: size.height + 16))
            bubbleBG.backgroundColor = UIColor(r: 39, g: 174, b: 97, a: 255)
            bubbleBG.layer.cornerRadius = 8
            setNeedsDisplay()
            break
        case .System:
            textContainer.frame = CGRect(x: 8, y: 0, width: size.width, height: size.height)
            bubbleBG = UIView(frame: CGRect(x: 0, y: 0, width: size.width + 16, height: size.height + 8))
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

        
    }
    

}
