//
//  UDLoginView.swift
//  Chatter
//
//  Created by David on 16/7/5.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDLoginView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private var heights:[CGFloat] = []
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    convenience init(frame: CGRect){
        self.init(frame: frame, style: .Grouped)
        self.delegate = self
        self.keyboardDismissMode = .OnDrag
        self.allowsSelection = false
        self.separatorStyle = .None
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "login")
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    
}
