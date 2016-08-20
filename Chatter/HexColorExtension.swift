//
//  HexColorExtention.swift
//  CG2048
//
//  Created by David on 16/6/28.
//  Copyright © 2016年 David. All rights reserved.
//

import UIKit

class ColoredHex {
    var hex:String!
    var rgba:(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)?
    init?(h:String) throws{
        hex = h.uppercaseString
        if hex.characters.count != 6 && hex.characters.count != 8{
            print("Bad ColorHex String \(hex)")
            return nil
        }
        var intVlaue:[CGFloat] = []
        var idx = 0
        for h in hex.characters{
            if hex2int(h) != nil{
                intVlaue.append(CGFloat(hex2int(h)!))
                if idx % 2 == 1{
                    intVlaue[idx] += intVlaue[idx-1]*16
                }
            }else{
                print("Bad ColorHex String \(hex)")
                return nil
            }
            
            idx += 1
        }
        if intVlaue.count < 8{
            rgba = (intVlaue[1],intVlaue[3],intVlaue[5],255)
        }else{
            rgba = (intVlaue[1],intVlaue[3],intVlaue[5],intVlaue[7])
        }
    }
    func hex2int(h: Character) ->Int?{
        if Int(String(h)) != nil{
            return Int(String(h))!
        }else{
            switch h {
            case "A":
                return 10
            case "B":
                return 11
            case "C":
                return 12
            case "D":
                return 13
            case "E":
                return 14
            case "F":
                return 15
            default:
                return nil
            }
        }
    }
}

public extension UIColor{
    public convenience init?(hex: String){
        
        do{
            let h = try ColoredHex(h: hex)
            self.init(r:(h!.rgba?.r)!, g:(h!.rgba?.g)!, b:(h!.rgba?.b)!, a:(h!.rgba?.a)!)
        }catch {
            return nil
        }
        
    }
    public convenience init(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/255.0)
    }
    
}