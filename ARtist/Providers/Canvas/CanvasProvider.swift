//
//  CanvasProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/10/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import ARKit

import OpenGLES

class CanvasProvider: NSObject {
    
    public var canvasView:ARSCNView
    
    // Offset between camera and drawing - 0.1 seems to be a decent value
    public var worldOffset:Float
    
    // Every node in the current stroke
    public var strokeList:StrokeModel!
    
    // List of strokes in the canvas
    public var drawList:DrawingModel = DrawingModel()
    
    // List of undone nodes
    public var undoList:DrawingModel = DrawingModel()
    
    public var onCapture:(_ snapshot:UIImage?)->Void
    public var canCapture:Bool = true
    
    init(canvasView:ARSCNView, worldOffset:Float, onCapture:@escaping (_ snapshot:UIImage?)->Void) {
        
        self.canvasView = canvasView
        self.worldOffset = worldOffset
        
        self.onCapture = onCapture
        
        super.init()
        
        // Register long press gestures
        //            let gesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(captureSnapshotOnPress(longPress:)))
        //            gesture.minimumPressDuration = 0.2
        //            canvasView.addGestureRecognizer(gesture)
    }
    
    //
    // Coordinate Functions
    //
    
    private func getHitTestPosition(screenCoord:CGPoint) -> SCNVector3 {
        var worldCoord:SCNVector3 = SCNVector3(0, 0, 0);
        
        // HIT TEST : REAL WORLD
        // Get Screen Center
        
        let arHitTestResults : [ARHitTestResult] = canvasView.hitTest(screenCoord, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
        
        if let closestResult = arHitTestResults.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        }
        
        return worldCoord
    }
    
    private func getScreenCoordinates(screenCoord:CGPoint) -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.canvasView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func getWorldCoordinates(screenCoord:CGPoint) -> SCNVector3 {
        // d1 stores camera position
        let dir = getScreenCoordinates(screenCoord: screenCoord).1
        // d0 stores camera direction
        
        var pos = SCNVector3(getScreenCoordinates(screenCoord: screenCoord).0.x, getScreenCoordinates(screenCoord: screenCoord).0.y, getScreenCoordinates(screenCoord: screenCoord).0.z)
        
        /*let posOffset*/ pos = pos * worldOffset
        // Returns a position pointing in the direction vector, accounting for the offset
        
        // let hitTest = getHitTestPosition(screenCoord: screenCoord)
        
        //            if (pos.distance(vector: posOffset) > pos.distance(vector: hitTest)) {
        //                  pos = hitTest
        //            } else {
        //                  pos = posOffset
        //            }
        
        return SCNVector3(dir.x + pos.x, dir.y + pos.y, dir.z + pos.z)
    }
    
    //
    // Capture Functions
    //
    
    func captureSnapshot(saveToAlbum:Bool = true) -> UIImage? {
        var snapshot:UIImage?
        if (canCapture) {
            canCapture = false
            snapshot = canvasView.snapshot()
            
            if (saveToAlbum) {
                UIImageWriteToSavedPhotosAlbum(snapshot!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
            // Debounce the capture button for 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.canCapture = true
            }
        }
        return snapshot
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if (error != nil) {
            onCapture(nil)
        } else {
            onCapture(image)
        }
    }
    
    //
    // Drawing Functions
    //
    
    func newStroke(brush:BrushModel) {
        self.strokeList = StrokeModel(brushType:brush, rootNode: canvasView.scene.rootNode)
    }
    
    func draw(brush:BrushModel, worldCoord:SCNVector3) {
        let stroke = SCNSphere(radius: CGFloat(brush.size))
        let strokeNode = SCNNode(geometry: stroke)
        
        stroke.materials = [materialFromBrush(brush: brush)]
        
        strokeNode.position = worldCoord
        canvasView.scene.rootNode.addChildNode(strokeNode)
    }
    
    func drawLine(brush:BrushModel, from:SCNVector3, to:SCNVector3) {
        
        glLineWidth(GLfloat(brush.size*50))
        
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let line = SCNGeometry(sources: [source], elements: [element])
        let lineNode = SCNNode(geometry: line)
        
        line.materials = [materialFromBrush(brush: brush)]
        
        canvasView.scene.rootNode.addChildNode(lineNode)
    }
    
    func drawThickLine(brush:BrushModel, from:SCNVector3, to:SCNVector3) -> SCNNode {
        var node:SCNNode?
        
        // Sets the node's color/other properties based on brush
        let materials:[SCNMaterial] = [materialFromBrush(brush: brush)]
        
        // Calculates the distance between the "from" (start) and "to" (end) vectors
        let vectorDistance = SCNVector3Distance(vectorStart: from, vectorEnd: to)
        
        // Check if the two points are identical
        // True: draw a sphere in their location
        // False: draw a capsure from "from" to "to"
        if (vectorDistance == 0.0) {
            // Create a new sphere with materials from the brush
            let sphere = SCNSphere(radius: CGFloat(brush.size))
            sphere.materials = materials
            
            // Set the node to a sphere and set its position equal to the position
            // of "from"
            node = SCNNode(geometry: sphere)
            node?.geometry = sphere
            node?.position = from
        } else {
            // Creates a cylinder with a radius of the brush size and the height equal to the
            // distance between the two vectors.
            let capsule = SCNCapsule(capRadius: CGFloat(brush.size), height: CGFloat(vectorDistance) + CGFloat(brush.size)*2)
            capsule.materials = materials
            
            // Gives the node a cylindrical geometry
            node = SCNNode(geometry: capsule)
            
            // Create vector in y-direction with half the vector distance
            let yDirVector = SCNVector3(0, vectorDistance/2.0,0)
            
            // Create a midpoint vector
            let midpointVector:SCNVector3 = SCNVector3Midpoint(vectorStart: from, vectorEnd: to)
            
            // Create an axis vector which is in the new coordinate system of yDirVector
            let axisVector:SCNVector3 = SCNVector3Mean(vectorStart: yDirVector, vectorEnd: midpointVector)
            
            // Normalize the axis vector
            let axisVectorNormalized:SCNVector3 = SCNVector3Normalize(vector: axisVector)
            
            let q0:Float = (0.0) //cos(angel/2), angle is always 180 or M_PI
            let q1:Float = Float(axisVectorNormalized.x) // x' * sin(angle/2)
            let q2:Float = Float(axisVectorNormalized.y) // y' * sin(angle/2)
            let q3:Float = Float(axisVectorNormalized.z) // z' * sin(angle/2)
            
            // Affine transformations
            // See article on affine transformations along 4x4 matrices:
            // http://www.euclideanspace.com/maths/geometry/affine/matrix4x4/
            
            // Transform row 1
            node?.transform.m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
            node?.transform.m12 = 2 * q1 * q2 + 2 * q0 * q3
            node?.transform.m13 = 2 * q1 * q3 - 2 * q0 * q2
            node?.transform.m14 = 0.0
            
            // Transform row 2
            node?.transform.m21 = 2 * q1 * q2 - 2 * q0 * q3
            node?.transform.m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
            node?.transform.m23 = 2 * q2 * q3 + 2 * q0 * q1
            node?.transform.m24 = 0.0
            
            // Transform row 3
            node?.transform.m31 = 2 * q1 * q3 + 2 * q0 * q2
            node?.transform.m32 = 2 * q2 * q3 - 2 * q0 * q1
            node?.transform.m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
            node?.transform.m34 = 0.0
            
            // Transform row 4
            node?.transform.m41 = (from.x + to.x) / 2.0
            node?.transform.m42 = (from.y + to.y) / 2.0
            node?.transform.m43 = (from.z + to.z) / 2.0
            node?.transform.m44 = 1.0
        }
        
        // Add the node to the canvasView
        //canvasView.scene.rootNode.addChildNode(node!)
        
        // Append the node to the current list of nodes being drawn on this stroke
        _ = strokeList.push(node: node!)
        strokeList.parent(node: node!)
        
        // Return the node
        return node!
    }
    
    //      func smoothenStroke() {
    //            if (currentList.count > 2) {
    //                  let startNode:SCNNode = currentList.first!
    //                  let endNode:SCNNode = currentList.last!
    //                  var meanDirection:SCNVector3?
    //                  var totalDirection:SCNVector3?
    //                  for i in 0...currentList.count - 2 {
    //                        let node:SCNNode = currentList[i]
    //                        let nextNode:SCNNode = currentList[i + 1]
    //                        totalDirection = totalDirection! + node.convertPosition(node.position, to: nextNode)
    //                  }
    //                  meanDirection = totalDirection!/(Float(currentList.count - 2))
    //                  if (meanDirection.) {
    //                        for node in currentList {
    //                              node.convertPosition(<#T##position: SCNVector3##SCNVector3#>, to: <#T##SCNNode?#>)
    //                        }
    //                  }
    //            }
    //      }
    
    //
    // Load functions
    //
    func loadDrawing(drawing:DrawingModel) {
        // Clear the undo and stroke lists
        self.clear()
        // Overwrite the draw list
        self.drawList = drawing
        // Parent every node from the new draw list
        for i in 0...drawing.getCount() - 1 {
            self.drawList.getAtIndex(index: i)?.parent()
        }
    }
    
    //
    // Brush helper functions
    //
    
    func materialFromBrush(brush:BrushModel) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = brush.color
        material.transparency = CGFloat(brush.opacity)
        return material
    }
    
    //
    // Eraser functions
    //
    
    func erase(brush:BrushModel, worldCoord:SCNVector3) -> DrawingModel {
        let brushSize = brush.size
        let eraseList:DrawingModel = DrawingModel()
        if drawList.getCount() > 0 {
            var i:Int = 0
            var willErase:Bool = false
            while i < drawList.getCount() && !willErase {
                for node in (drawList.getAtIndex(index: i)?.getStroke())! {
                    if node.position.distance(vector: worldCoord) < brushSize {
                        willErase = true
                        print("Found node to erase")
                        break
                    }
                }
                if willErase {
                    _ = eraseList.push(stroke: drawList.getAtIndex(index: i)!)
                    _ = drawList.push(stroke: drawList.getAtIndex(index: i)!)
                    drawList.getAtIndex(index: i)?.unparent()
                    _ = drawList.removeAtIndex(index: i)
                } else {
                    i += 1
                }
            }
        }
        updateDrawList()
        return eraseList
    }
    
    //
    // Paint bucket functions
    //
    
    func recolor(brush:BrushModel, worldCoord:SCNVector3) -> DrawingModel {
        let brushSize = brush.size
        let recolorList:DrawingModel = DrawingModel()
        if drawList.getCount() > 0 {
            var i:Int = 0
            var willRecolor:Bool = false
            while i < drawList.getCount() && !willRecolor {
                for node in (drawList.getAtIndex(index: i)?.getStroke())! {
                    if node.position.distance(vector: worldCoord) < brushSize {
                        willRecolor = true
                        print("Found node to recolor")
                        break
                    }
                }
                if willRecolor {
                    for node in (drawList.getAtIndex(index: i)?.getStroke())! {
                        node.geometry = node.geometry!.copy() as? SCNGeometry
                        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
                        node.geometry?.firstMaterial?.diffuse.contents = brush.color.cgColor
                    }
                } else {
                    i += 1
                }
            }
        }
        updateDrawList()
        return recolorList
    }
    
    /// Updates the length and color arrays of the drawList
    func updateDrawList() {
        QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.UpdateDrawList").execute(actions: {
            self.drawList.updateLength()
            self.drawList.updateColors()
        })
    }
    
    //
    // Undo Functions
    //
    
    func clear() {
        for i in 0...self.drawList.getCount() - 1 {
            self.drawList.getAtIndex(index: i)?.unparent()
        }
        _ = self.undoList.clear()
        _ = self.strokeList.clear()
        _ = self.drawList.clear()
        updateDrawList()
    }
    
    func unparentAndClear() {
        _ = self.undoList.clear()
        _ = self.strokeList.clear()
        _ = self.drawList.clear()
        updateDrawList()
    }
    
    func appendCurrentList() {
        _ = drawList.push(stroke: strokeList)
        _ = undoList.clear()
        _ = strokeList.clear()
        updateDrawList()
    }
    
    func undo() -> StrokeModel? {
        let removedNodes = drawList.pop()
        if (removedNodes != nil) {
            _ = undoList.push(stroke: removedNodes!)
            removedNodes?.unparent()
        }
        updateDrawList()
        return removedNodes
    }
    
    func redo() -> StrokeModel? {
        let undoneNodes = undoList.pop()
        if (undoneNodes != nil) {
            _ = drawList.push(stroke: undoneNodes!)
            undoneNodes?.parent()
        }
        updateDrawList()
        return undoneNodes
    }
    
    func canUndo() -> Bool {
        return drawList.getCount() > 0
    }
    
    func canRedo() -> Bool {
        return undoList.getCount() > 0
    }
    
}
