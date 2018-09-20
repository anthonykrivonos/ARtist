//
//  StrokeModel.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/24/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class StrokeModel:NSObject, NSCoding {
    
    // root node of stroke
    private var rootNode:SCNNode!
    
    // List of nodes in stroke
    private var stroke:[SCNNode]
    
    // Type of brush that drew nodes
    private var brushType:BrushModel
    
    // Number of nodes in stroke
    private var count:Int
    
    init(brushType:BrushModel, rootNode:SCNNode!) {
        self.brushType = brushType
        self.stroke = []
        self.count = 0
        self.rootNode = rootNode
    }
    
    //
    // Encoding for storage
    //
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(brushType, forKey: "brushType")
        aCoder.encode(stroke, forKey: "stroke")
        aCoder.encode(count, forKey: "count")
        aCoder.encode(rootNode, forKey: "rootNode")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.brushType = (aDecoder.decodeObject(forKey: "brushType") as? BrushModel)!
        self.stroke = aDecoder.decodeObject(forKey: "stroke") as? Array ?? []
        self.count = aDecoder.decodeInteger(forKey: "count")
        self.rootNode = aDecoder.decodeObject(forKey: "rootNode") as? SCNNode ?? SCNNode()
    }
    
    // Push to end of stroke
    func push(node:SCNNode) -> [SCNNode] {
        stroke.append(node)
        count += 1
        return self.stroke
    }
    
    // Remove node at a certain index from the stroke
    func removeAtIndex(index:Int) -> SCNNode? {
        if count > 0 {
            let removedNode = stroke.remove(at: index)
            count -= 1
            return removedNode
        }
        return nil
    }
    
    // Pop last node from stroke
    func pop() -> SCNNode? {
        if count > 0 {
            let poppedNode = stroke.popLast()
            count -= 1
            return poppedNode
        }
        return nil
    }
    
    // Clear the entire stroke
    func clear() -> [SCNNode] {
        let clearedStroke:[SCNNode] = self.stroke
        self.stroke = []
        return clearedStroke
    }
    
    // Get a node at a given index
    func getAtIndex(index:Int) -> SCNNode? {
        if count > index {
            return stroke[index]
        }
        return nil
    }
    
    // Return the entire stroke
    func getStroke() -> [SCNNode] {
        return self.stroke
    }
    
    // Return the count
    func getCount() -> Int {
        return self.count
    }
    
    // Return the brush type
    func getBrushType() -> BrushModel {
        return self.brushType
    }
    
    /// Get the approximate length of the stroke
    func getLength() -> Float {
        var length:Float = 0
        for node in stroke {
            length += node.boundingBox.min.distance(vector: node.boundingBox.max)
        }
        return length
    }
    
    // Set the brush type
    func setBrushType(brushType:BrushModel) {
        self.brushType = brushType
    }
    // Removes one or all nodes from their parents, then clears
    func parent(index:Int = -1) {
        if index < 0 && stroke.count > 0 {
            for i in 0...stroke.count - 1 {
                self.rootNode.addChildNode(stroke[i])
            }
        } else if count > index && index >= 0 {
            self.rootNode.addChildNode(stroke[index])
        }
    }
    // Removes one or all nodes from their parents, then clears
    func parent(node:SCNNode) {
        self.rootNode.addChildNode(node)
    }
    
    // Removes one or all nodes from their parents, then clears
    func unparent(index:Int = -1) {
        if index < 0 && stroke.count > 0 {
            print("Unparenting all")
            for i in 0...stroke.count - 1 {
                stroke[i].removeFromParentNode()
                print("unparented node at index \(i))")
            }
        } else if count > index && index >= 0 {
            print("Unparenting at index \(index)")
            stroke[index].removeFromParentNode()
        }
    }
    
}
