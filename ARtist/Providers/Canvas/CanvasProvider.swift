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

class CanvasProvider {
      
      public var canvasView:ARSCNView
      
      // Offset between camera and drawing - 0.1 seems to be a decent value
      public let worldOffset:Float
      
      public var drawList:[SCNNode]
      public var undoList:[[SCNNode]]
      
      init(canvasView:ARSCNView, worldOffset:Float) {
            self.canvasView = canvasView
            self.worldOffset = worldOffset
            
            self.drawList = []
            self.undoList = []
      }
      
      //
      // Coordinate Functions
      //
      
      private func getScreenCoordinates(screenCoord:CGPoint) -> (SCNVector3, SCNVector3) { // (direction, position)
            if let frame = self.canvasView.session.currentFrame {
                  let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
                  let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
                  let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space

                  return (dir, pos)
            }
            return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
      }
      
//      private func getScreenCoordinates(screenCoord:CGPoint) -> (SCNVector3, SCNVector3) { // (direction, position)
//            if let frame = self.canvasView.session.currentFrame {
//                  let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
//                  let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
////                  let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
////                  print ("Pos   : (\(pos.x), \(pos.y), \(pos.z))")
//                  let newPos = SCNVector3(Float(screenCoord.x), Float(screenCoord.y), mat.m43) // location of camera in world space
//                  print("Direction: (\(dir.x), \(dir.y), \(dir.z))")
//                  print("Position!: (\(mat.m41), \(mat.m42), \(mat.m43))")
//                  print("Position : (\(newPos.x), \(newPos.y), \(newPos.z))")
//
//                  return (dir, newPos)
//            }
//            return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
//      }
      
      func getWorldCoordinates(screenCoord:CGPoint) -> SCNVector3 {
            // d1 stores camera position
            let d1 = getScreenCoordinates(screenCoord: screenCoord).1
            // d0 stores camera direction
            let d0 = getScreenCoordinates(screenCoord: screenCoord).0
            // Returns a position pointing in the direction vector, accounting for the offset
            print(d1.z + d0.z * worldOffset)
            return SCNVector3(d1.x + d0.x * worldOffset, d1.y + d0.y * worldOffset, d1.z + d0.z * worldOffset)
      }
      
      //
      // Drawing Functions
      //
      
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
            
            let materials:[SCNMaterial] = [materialFromBrush(brush: brush)]
            
            let vectorDistance = SCNVector3Distance(vectorStart: from, vectorEnd: to)
            
            if (vectorDistance == 0.0) {
                  // two points are identical
                  let sphere = SCNSphere(radius: CGFloat(brush.size))
                  sphere.materials = materials
                  
                  node = SCNNode(geometry: sphere)
                  node?.geometry = sphere
                  node?.position = from
            } else {
                  let cyl = SCNCylinder(radius: CGFloat(brush.size), height: CGFloat(vectorDistance))
                  
                  cyl.materials = materials
                  
                  node = SCNNode(geometry: cyl)
                  
                  node?.geometry = cyl
                  
                  //original vector of cylinder above 0,0,0
                  let ov = SCNVector3(0, vectorDistance/2.0,0)
                  //target vector, in new coordination
                  let nv = SCNVector3((to.x - from.x)/2.0, (to.y - from.y)/2.0,
                                      (to.z-from.z)/2.0)
                  
                  // axis between two vector
                  let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
                  
                  //normalized axis vector
                  let av_normalized:SCNVector3 = SCNVector3Normalize(vector: av)
                  let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
                  let q1 = Float(av_normalized.x) // x' * sin(angle/2)
                  let q2 = Float(av_normalized.y) // y' * sin(angle/2)
                  let q3 = Float(av_normalized.z) // z' * sin(angle/2)
                  
                  let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
                  let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
                  let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
                  let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
                  let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
                  let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
                  let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
                  let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
                  let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
                  
                  node?.transform.m11 = r_m11
                  node?.transform.m12 = r_m12
                  node?.transform.m13 = r_m13
                  node?.transform.m14 = 0.0
                  
                  node?.transform.m21 = r_m21
                  node?.transform.m22 = r_m22
                  node?.transform.m23 = r_m23
                  node?.transform.m24 = 0.0
                  
                  node?.transform.m31 = r_m31
                  node?.transform.m32 = r_m32
                  node?.transform.m33 = r_m33
                  node?.transform.m34 = 0.0
                  
                  node?.transform.m41 = (from.x + to.x) / 2.0
                  node?.transform.m42 = (from.y + to.y) / 2.0
                  node?.transform.m43 = (from.z + to.z) / 2.0
                  node?.transform.m44 = 1.0
            }
            
            canvasView.scene.rootNode.addChildNode(node!)
            
            drawList.append(node!)
            
            return node!
      }
      
      //
      // Brush helper functions
      //
      
      func materialFromBrush(brush:BrushModel) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = brush.color
            material.transparency = CGFloat(brush.opacity)
            material.lightingModel = SCNMaterial.LightingModel(rawValue: brush.type.lightingModel)
            material.shininess = CGFloat(brush.type.shininess)
            return material
      }
      
      //
      // Undo Functions
      //
      
      private func undoNode() -> SCNNode? {
            let node:SCNNode? = drawList.popLast()
            if (node != nil) {
                  node?.removeFromParentNode()
                  //node?.isHidden = true
            }
            return node
      }
      
      func undo(specificity:Int = 200) -> [SCNNode] {
            var removedNodes:[SCNNode] = []
            var remove:Int = specificity
            remove = (specificity > drawList.count) ? drawList.count : specificity
            for _ in 0...remove {
                  let node:SCNNode? = undoNode()
                  if (node != nil) {
                        removedNodes.append(node!)
                  }
            }
            undoList.append(removedNodes)
            return removedNodes
      }
      
      func redo() -> [SCNNode]? {
            let removedList = undoList.popLast()
            if (removedList != nil) {
                  for node in removedList! {
                        canvasView.scene.rootNode.addChildNode(node)
                  }
            }
            return removedList
      }
      
      func canUndo() -> Bool {
            return drawList.count > 0
      }
      
      func canRedo() -> Bool {
            return undoList.count > 0
      }
      
}
