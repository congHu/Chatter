//
//  PVImgViewController.swift
//  Chatter
//
//  Created by David on 16/8/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

@objc protocol PVImgViewControllerDelegate {
    optional func pvImgViewController(pvVC: PVImgViewController, finishedLoadingURLImage URL: String, image: UIImage)
}

class PVImgViewController: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate {

    var scrollView:UIScrollView!
    var imageView:UIImageView!
    var spinner:UDLoadingSpinner!
    var requestURL:String?
    var entireImg:UIImage?
    var delegate:PVImgViewControllerDelegate?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    convenience init(imagePrview:UIImage?){
        self.init()
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.backgroundColor = UIColor.blackColor()
        view.addSubview(scrollView)
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.bouncesZoom = true
        scrollView.userInteractionEnabled = true
        scrollView.delegate = self
        
        imageView = UIImageView(frame: view.frame)
        imageView.backgroundColor = UIColor.blackColor()
        imageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imageView)
        if imagePrview != nil{
            imageView.image = imagePrview
        }
        imageView.userInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(PVImgViewController.imgTap))
        scrollView.addGestureRecognizer(tapGes)
        let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(PVImgViewController.imgDoubleTap))
        doubleTapGes.numberOfTapsRequired = 2
        tapGes.requireGestureRecognizerToFail(doubleTapGes)
        scrollView.addGestureRecognizer(doubleTapGes)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PVImgViewController.imgLongPress(_:)))
        scrollView.addGestureRecognizer(longPress)
//        imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(PVImgViewController.imgPinch(_:))))
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if requestURL != nil{
            spinner = UDLoadingSpinner(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            spinner.center = view.center
            view.addSubview(spinner)
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: requestURL!)!), queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
                if err == nil{
                    if let data = returnData{
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        if json == nil{
                            dispatch_async(dispatch_get_main_queue(), { 
                                self.imageView.image = UIImage(data: data)
                                self.spinner.alpha = 0
                                self.delegate?.pvImgViewController?(self, finishedLoadingURLImage: self.requestURL!, image: UIImage(data: data)!)
                            })
                        }
                    }
                }
            })
        }
    }
    
    func imgTap(){
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.popViewControllerAnimated(true)
    }
    func imgDoubleTap(){
        if scrollView.zoomScale > 1.0{
            scrollView.setZoomScale(1.0, animated: true)
        }else{
            scrollView.setZoomScale(2.0, animated: true)
        }
        
    }
    
    func imgLongPress(sender:UILongPressGestureRecognizer){
        if sender.state == .Began{
            let imgAs = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            imgAs.addButtonWithTitle("保存图片")
            imgAs.addButtonWithTitle("取消")
            imgAs.cancelButtonIndex = imgAs.numberOfButtons - 1
            imgAs.showInView(view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0{
            // MARK: 保存图片到相册
            
            UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(PVImgViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error == nil {
            UIAlertView(title: "保存成功", message: nil, delegate: nil, cancelButtonTitle: "好").show()
        }else{
            UIAlertView(title: "保存失败", message: nil, delegate: nil, cancelButtonTitle: "好").show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
