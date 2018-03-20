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

class BrushTypeModel {
      public let lightingModel: String = "physicallyBased"
      
      public private(set) var name:String
      public private(set) var roughness:Float
      public private(set) var shininess:Float
      
      init(_ name:String, _ roughness:Float, _ shininess:Float) {
            self.name = name
            self.roughness = roughness
            self.shininess = shininess
      }
}

class BrushModel {
      
      // Divisor for sizes to account for tiny brush sizes - 1000 is the best value
      private let sizeOffset:Float = 1000
      
      public var size:Float
      public var color:UIColor
      public var opacity:Float
      public var type:BrushTypeModel
      
      init(size:Float, color:UIColor, opacity:Float, type:BrushTypeModel) {
            self.size = size/sizeOffset
            self.color = color
            self.opacity = opacity
            self.type = type
      }
      
}
