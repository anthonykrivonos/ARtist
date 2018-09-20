//
//  DrawingModel.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/25/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class DrawingModel:NSObject, NSCoding {
    
    // List of nodes in stroke
    private var drawing:[StrokeModel]
    
    private var colorMap:[UIColor:Int]
    
    private var length:Float
    
    // Number of nodes in stroke
    private var count:Int
    
    override init() {
        self.drawing = []
        self.colorMap = [:]
        self.count = 0
        self.length = 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(drawing, forKey: "drawing")
        aCoder.encode(colorMap, forKey: "colorMap")
        aCoder.encode(length, forKey: "length")
        aCoder.encode(count, forKey: "count")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.drawing = aDecoder.decodeObject(forKey: "drawing") as? [StrokeModel] ?? []
        self.colorMap = aDecoder.decodeObject(forKey: "colorMap") as? [UIColor:Int] ?? [:]
        self.length = aDecoder.decodeFloat(forKey: "length")
        self.count = aDecoder.decodeInteger(forKey: "count")
    }
    
    /// Add color to colorMap
    private func append(color:UIColor) {
        if colorMap[color] != nil {
            colorMap[color]! += 1
        } else {
            colorMap[color] = 1
        }
    }
    
    /// Remove a color from colorMap
    private func remove(color:UIColor) {
        if let colorCount = colorMap[color] {
            colorMap[color] = colorCount - 1
            if colorCount - 1 == 0 {
                colorMap.removeValue(forKey: color)
            }
        }
    }
    
    /// Push stroke to end of drawing
    func push(stroke:StrokeModel) -> [StrokeModel] {
        drawing.append(stroke)
        count += 1
        append(color: stroke.getBrushType().color)
        self.length += stroke.getLength()
        return self.drawing
    }
    
    /// Remove stroke at a certain index from the stroke
    func removeAtIndex(index:Int) -> StrokeModel? {
        if count > 0 {
            let removedStroke = drawing.remove(at: index)
            count -= 1
            remove(color: removedStroke.getBrushType().color)
            self.length -= removedStroke.getLength()
            return removedStroke
        }
        return nil
    }
    
    /// Pop last stroke from drawing
    func pop() -> StrokeModel? {
        if count > 0, let poppedStroke = drawing.popLast() {
            count -= 1
            remove(color: poppedStroke.getBrushType().color)
            self.length -= poppedStroke.getLength()
            return poppedStroke
        }
        return nil
    }
    
    /// Clear the entire drawing
    func clear() -> [StrokeModel] {
        let clearedDrawing:[StrokeModel] = self.drawing
        self.drawing = []
        self.count = 0
        self.colorMap = [:]
        self.length = 0
        return clearedDrawing
    }
    
    /// Get a stroke at a given index
    func getAtIndex(index:Int) -> StrokeModel? {
        if count > index && index >= 0 {
            return drawing[index]
        }
        return nil
    }
    
    /// Return the entire drawing
    func getDrawing() -> [StrokeModel] {
        return self.drawing
    }
    
    /// Return the colors in the drawing
    func getColors() -> [UIColor:Int] {
        return self.colorMap
    }
    
    /// Return the number of colors in the drawing
    func getColorCount() -> Int {
        return self.colorMap.keys.count
    }
    
    /// Return the length of the nodes as a CGFloat
    func getLength() -> Float {
        return self.length
    }
    
    /// Return the count
    func getCount() -> Int {
        return self.count
    }
    
}
