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
    
    private var colors:[UIColor]
    
    private var length:Float
    
    // Number of nodes in stroke
    private var count:Int
    
    override init() {
        self.drawing = []
        self.colors = []
        self.count = 0
        self.length = 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(drawing, forKey: "drawing")
        aCoder.encode(colors, forKey: "colors")
        aCoder.encode(length, forKey: "length")
        aCoder.encode(count, forKey: "count")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.drawing = aDecoder.decodeObject(forKey: "drawing") as? [StrokeModel] ?? []
        self.colors = aDecoder.decodeObject(forKey: "colors") as? [UIColor] ?? []
        self.length = aDecoder.decodeFloat(forKey: "length")
        self.count = aDecoder.decodeInteger(forKey: "count")
    }
    
    /// Update the list of colors in the drawing
    func updateColors() {
        var colors = [UIColor]()
        for stroke in drawing {
            colors.append(stroke.getBrushType().color)
        }
        self.colors = colors.set
    }
    
    /// Update the list of colors in the drawing
    func updateLength() {
        var length:Float = 0
        for stroke in drawing {
            for node in stroke.getStroke() {
                length += node.boundingBox.min.distance(vector: node.boundingBox.max)
            }
        }
        self.length = length
    }
    
    /// Push stroke to end of drawing
    func push(stroke:StrokeModel) -> [StrokeModel] {
        drawing.append(stroke)
        count += 1
        return self.drawing
    }
    
    /// Remove stroke at a certain index from the stroke
    func removeAtIndex(index:Int) -> StrokeModel? {
        if count > 0 {
            let removedStroke = drawing.remove(at: index)
            count -= 1
            return removedStroke
        }
        return nil
    }
    
    /// Pop last stroke from drawing
    func pop() -> StrokeModel? {
        if count > 0 {
            let poppedStroke = drawing.popLast()
            count -= 1
            return poppedStroke
        }
        return nil
    }
    
    /// Clear the entire drawing
    func clear() -> [StrokeModel] {
        let clearedDrawing:[StrokeModel] = self.drawing
        self.drawing = []
        return clearedDrawing
    }
    
    /// Get a stroke at a given index
    func getAtIndex(index:Int) -> StrokeModel? {
        if count > index {
            return drawing[index]
        }
        return nil
    }
    
    /// Return the entire drawing
    func getDrawing() -> [StrokeModel] {
        return self.drawing
    }
    
    /// Return the colors in the drawing
    func getColors() -> [UIColor] {
        return self.colors
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
