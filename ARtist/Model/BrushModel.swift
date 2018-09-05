//
//  BrushModel.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/10/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class BrushModel:NSObject, NSCoding {
    
    // Divisor for sizes to account for tiny brush sizes - 10000 is the best value
    private let SIZE_OFFSET:Float = 5200
    
    public var size:Float
    public var color:UIColor
    public var opacity:Float
    
    init(size:Float, color:UIColor, opacity:Float) {
        self.size = size/SIZE_OFFSET
        self.color = color
        self.opacity = opacity
    }
    
    func resize(toValue value:Int) {
        self.size = Float(value)/SIZE_OFFSET
    }
    
    //
    // Encoding for storage
    //
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(size, forKey: "size")
        aCoder.encode(color, forKey: "color")
        aCoder.encode(opacity, forKey: "opacity")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.size = aDecoder.decodeFloat(forKey: "size")
        self.opacity = aDecoder.decodeFloat(forKey: "opacity")
        self.color = aDecoder.decodeObject(forKey: "color") as? UIColor ?? UIColor.clear
    }
}
