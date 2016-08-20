//
//  AreaViewController.swift
//  Chatter
//
//  Created by David on 16/8/4.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit
import CoreLocation

class AreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var tableView:UITableView!
    var currentArea:String?
    var cityDict:NSDictionary!
    var uidAndAcode:String?
    var indexArray:[String]!
    
    var locationLabel:UILabel!
    var locationGot:String?
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityDict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("citydict", ofType: "plist")!)
        indexArray = cityDict.allKeys as! [String]
        indexArray.sortInPlace()
        tableView = UITableView(frame: view.frame, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        navigationItem.title = "设置地区"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "设置", style: .Plain, target: self, action: #selector(AreaViewController.setPost))
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            if #available(iOS 8.0, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
            locationManager.startUpdatingLocation()
            
        }else{
            locationLabel.text = "定位不可用"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexArray.count + 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return (cityDict.objectForKey(indexArray[section-1]) as! NSArray).count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "area")
        if indexPath.section == 0{
            locationLabel = cell.textLabel
            locationLabel.text = "正在获取定位..."
            if locationGot != nil{
                locationLabel.text = locationGot
            }
            if currentArea != nil{
                if currentArea == cell.textLabel?.text{
                    cell.accessoryType = .Checkmark
                }
            }
            
        }else{
            cell.textLabel?.text = (cityDict.objectForKey(indexArray[indexPath.section-1]) as! NSArray).objectAtIndex(indexPath.row) as? String
            if currentArea != nil{
                if currentArea == cell.textLabel?.text{
                    cell.accessoryType = .Checkmark
                }
            }
        }
        return cell
    }
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexs:[String]? = []
        indexs?.append("*")
        for i in indexArray{
            indexs?.append(i)
        }
        return indexs
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "获取定位"
        default:
            return indexArray[section-1]
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!) { (clps:[CLPlacemark]?, err:NSError?) in
            var city:String?
            if err == nil{
                
                if clps?.count > 0{
                    city = clps?.first!.locality
                }
                if city == nil{
                    city = clps?.first!.administrativeArea
                }
            }
            if city == nil{
                city = "定位失败"
            }
            self.locationLabel.text = city
            self.locationGot = city
            
            manager.stopUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            if locationGot == nil{
                locationLabel.text = "正在获取定位..."
                locationGot = nil
                locationManager.startUpdatingLocation()
            }else{
                currentArea = locationGot
            }
        }else{
            currentArea = (cityDict.objectForKey(indexArray[indexPath.section-1]) as! NSArray).objectAtIndex(indexPath.row) as? String
        }
        
        tableView.reloadData()
    }
    
    func setPost(){
        let resq = NSMutableURLRequest(URL: NSURL(string: "http://119.29.225.180/notecloud/setAttr.php")!)
        resq.HTTPMethod = "POST"
        if uidAndAcode != nil{
            resq.HTTPBody = NSString(string: "\(uidAndAcode!)&attr=area&value=\(currentArea!)").dataUsingEncoding(NSUTF8StringEncoding)
            NSURLConnection.sendAsynchronousRequest(resq, queue: NSOperationQueue(), completionHandler: { (resp:NSURLResponse?, returnData:NSData?, err:NSError?) in
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
