//
//  CursorProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/11/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import ARKit

class CursorProvider {
      
      public var cursor:CAShapeLayer
      public var cursorPos:CGPoint
      public var cursorView:UIView
      
      public var worldOffset:Float
      public var canvasView:ARSCNView
      
      public var brush:BrushModel
      
      // Ability to drag cursor
      var panGesture = UIPanGestureRecognizer()
      
      init(canvasView:ARSCNView, worldOffset:Float, position:CGPoint, radius:CGFloat, thickness:CGFloat, color:UIColor, brush:BrushModel) {
            self.canvasView = canvasView
            self.worldOffset = worldOffset
            self.cursorView = UIView()
            self.cursorPos = position
            self.brush = brush
            
            // Create circle with 2pi radians
            
            // Circle with offset area = 2 * pi * radius * offset
            // radius = A/(2 * pi * offset)
            // Thus, radius = (A/offset)/(2 * pi * offset)
            
            let circlePath = UIBezierPath(arcCenter: cursorPos, radius: CGFloat(radius), startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
            // Create a new shape with the path of a circle
            let cursor = CAShapeLayer()
            
            cursor.path = circlePath.cgPath
            
            cursor.frame = canvasView.frame
            
            cursor.zPosition = CGFloat(worldOffset)
            
            // Fill color
            cursor.fillColor = UIColor.clear.cgColor
            // Stroke color
            cursor.strokeColor = UIColor.white.cgColor
            // Line width
            cursor.lineWidth = CGFloat(thickness)
            
            cursor.anchorPointZ = CGFloat(worldOffset)

            self.cursor = cursor
            
            // Set border color
            cursorView.layer.borderColor = color.cgColor
            cursorView.layer.borderWidth = CGFloat(2)
            
            // Allow cursor dragging
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedCursor(_:)))
            cursorView.isUserInteractionEnabled = true
            cursorView.addGestureRecognizer(panGesture)
            
            // Allow hero animations on cursor's view
//            cursorView.isHeroEnabled = true
//            cursorView.heroID = "cursorView"
//            cursorView.heroModifiers = [.translate(y:100)]
            
            // Add cursor as a sublayer to its view
            self.cursorView.layer.addSublayer(self.cursor)
            
            // Add the cursor's view as a subview to the canvas
            self.canvasView.addSubview(self.cursorView)
      }
      
      func resizeCursor(radius:CGFloat) {
            self.cursor.path = UIBezierPath(arcCenter: cursorPos, radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
      }
      
      func repositionCursor(position:CGPoint) {
//            self.cursorPos = position
//            self.cursor.position = cursorPos
      }
      
      @objc func draggedCursor(_ sender:UIPanGestureRecognizer) {
      }
      
}
