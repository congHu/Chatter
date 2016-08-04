//
//  PVImgViewController.swift
//  Chatter
//
//  Created by David on 16/8/2.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class PVImgViewController: UIViewController, UIScrollViewDelegate {

    var scrollView:UIScrollView!
    var imageView:UIImageView!
    var spinner:UDLoadingSpinner!
    var requestURL:String?
    
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
//        imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(PVImgViewController.imgPinch(_:))))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if requestURL != nil{
            spinner = UDLoadingSpinner()
            view.addSubview(spinner)
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
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
    
    func imgPinch(sender:UIPinchGestureRecognizer){
        if sender.state == .Began || sender.state == .Changed{
            imageView.transform = CGAffineTransformScale(imageView.transform, sender.scale, sender.scale)
            sender.scale = 1.0
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
