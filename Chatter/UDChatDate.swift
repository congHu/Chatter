//
//  UDChatDate.swift
//  Chatter
//
//  Created by David on 16/7/22.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class UDChatDate {
    static func softTime(timeString: String) -> String?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.dateFromString(timeString)
        if date == nil{
            return nil
        }
        let curDate = NSDate()
        
        let das = NSCalendar.currentCalendar()
        //new 一个 NSCalendar
        let flags: NSCalendarUnit = [.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit, .NSHourCalendarUnit, .NSMinuteCalendarUnit]
        //设置格式
        let nowCom = das.components(flags, fromDate: curDate)
        
        let timeCom = das.components(flags, fromDate: date!)
        //创建当前和需要计算的components
        //components有之前设置的格式的各种参数
        
        
        if timeCom.year == nowCom.year{
            if timeCom.month == nowCom.month {
                if timeCom.day == nowCom.day{
                    if timeCom.hour == nowCom.hour{
                        if timeCom.minute == nowCom.minute{
                            return "刚刚"
                        }else{
                            return "\(nowCom.minute - timeCom.minute)分钟前"
                        }
                        
                    }else{
                        var zero = ""
                        //timeCom.hour = (timeCom.hour+12)%24
                        if timeCom.minute < 10{
                            zero = "0"
                        }
                        return "今天 \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }
                }else{
                    if nowCom.day - timeCom.day == 1{
                        //timeCom.hour = (timeCom.hour+12)%12
                        var zero = ""
                        if timeCom.minute < 10{
                            zero = "0"
                        }
                        return "昨天 \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }else{
                        return "\(nowCom.day - timeCom.day)天前"
                    }
                }
            }else{
                return "\(timeCom.month)-\(timeCom.day)"
            }
            
        }else{
            return "\(timeCom.year)-\(timeCom.month)-\(timeCom.day)"
        }
    }
    
    static func longTime(timeString: String) -> String?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.dateFromString(timeString)
        if date == nil{
            return nil
        }
        let curDate = NSDate()
        
        let das = NSCalendar.currentCalendar()
        //new 一个 NSCalendar
        let flags: NSCalendarUnit = [.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit, .NSHourCalendarUnit, .NSMinuteCalendarUnit, .NSWeekdayCalendarUnit]
        //设置格式
        let nowCom = das.components(flags, fromDate: curDate)
        
        let timeCom = das.components(flags, fromDate: date!)
        //创建当前和需要计算的components
        //components有之前设置的格式的各种参数
        
        var zero = ""
        if timeCom.minute < 10{
            zero = "0"
        }
        if timeCom.year == nowCom.year{
            if timeCom.month == nowCom.month{
                if timeCom.day == nowCom.day{
                    return "\(timeCom.hour):"+zero+"\(timeCom.minute)"
                }else{
                    if nowCom.day - timeCom.day == 1{
                        return "昨天 \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }else if nowCom.day - timeCom.day <= 6{
                        var weekday = "星期"
                        switch timeCom.weekday {
                        case 1:
                            weekday += "日"
                            break
                        case 2:
                            weekday += "一"
                            break
                        case 3:
                            weekday += "二"
                            break
                        case 4:
                            weekday += "三"
                            break
                        case 5:
                            weekday += "四"
                            break
                        case 6:
                            weekday += "五"
                            break
                        case 7:
                            weekday += "六"
                            break
                        default:
                            break
                        }
                        return "\(weekday) \(timeCom.hour):"+zero+"\(timeCom.minute)"
                    }
                }
            }
            
            
            return "\(timeCom.month)-\(timeCom.day) \(timeCom.hour):"+zero+"\(timeCom.minute)"
            
            
        }else{
            return "\(timeCom.year)-\(timeCom.month)-\(timeCom.day) \(timeCom.hour):"+zero+"\(timeCom.minute)"
        }
        
    }
    
    static func shortTime(timeString: String) -> String? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.dateFromString(timeString)
        if date == nil{
            return nil
        }
        let curDate = NSDate()
        
        let das = NSCalendar.currentCalendar()
        //new 一个 NSCalendar
        let flags: NSCalendarUnit = [.NSYearCalendarUnit, .NSMonthCalendarUnit, .NSDayCalendarUnit, .NSHourCalendarUnit, .NSMinuteCalendarUnit, .NSWeekdayCalendarUnit]
        //设置格式
        let nowCom = das.components(flags, fromDate: curDate)
        
        let timeCom = das.components(flags, fromDate: date!)
        //创建当前和需要计算的components
        //components有之前设置的格式的各种参数
        
        var zero = ""
        if timeCom.minute < 10{
            zero = "0"
        }
        if timeCom.year == nowCom.year{
            if timeCom.month == nowCom.month{
                if timeCom.day == nowCom.day{
                    return "\(timeCom.hour):"+zero+"\(timeCom.minute)"
                }else{
                    if nowCom.day - timeCom.day == 1{
                        return "昨天"
                    }else if nowCom.day - timeCom.day <= 6{
                        var weekday = "星期"
                        switch timeCom.weekday {
                        case 1:
                            weekday += "日"
                            break
                        case 2:
                            weekday += "一"
                            break
                        case 3:
                            weekday += "二"
                            break
                        case 4:
                            weekday += "三"
                            break
                        case 5:
                            weekday += "四"
                            break
                        case 6:
                            weekday += "五"
                            break
                        case 7:
                            weekday += "六"
                            break
                        default:
                            break
                        }
                        return "\(weekday)"
                    }
                }
            }
            
            
            return "\(timeCom.month)-\(timeCom.day)"
            
            
        }else{
            return "\(timeCom.year)-\(timeCom.month)-\(timeCom.day)"
        }
    }
    
}
