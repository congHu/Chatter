//
//  UIImageExtension.swift
//  SuperFlyer
//
//  Created by David on 16/8/10.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
    
    public convenience init(image: UIImage, resizeRatioWithWidth width: CGFloat) {
        let newsize = CGSize(width: width, height: (width/image.size.width)*image.size.height)
        UIGraphicsBeginImageContext(newsize)
        image.drawInRect(CGRectMake(0, 0, newsize.width, newsize.height))
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(data: UIImagePNGRepresentation(newimg)!)!
    }
    
    public convenience init(image: UIImage, resizeRatioWithHeight height: CGFloat) {
        let newsize = CGSize(width: (height/image.size.height)*image.size.width, height: height)
        UIGraphicsBeginImageContext(newsize)
        image.drawInRect(CGRectMake(0, 0, newsize.width, newsize.height))
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(data: UIImagePNGRepresentation(newimg)!)!
    }
    
    public convenience init(image: UIImage, resizeWithWidthAndHeight width:CGFloat, height: CGFloat) {
        let newsize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(newsize)
        image.drawInRect(CGRectMake(0, 0, newsize.width, newsize.height))
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(data: UIImagePNGRepresentation(newimg)!)!
    }
}
