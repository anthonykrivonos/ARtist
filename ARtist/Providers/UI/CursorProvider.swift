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
    
    private var ERASE_COLOR:UIColor = UIColor.white
    private var ERASE_RADIUS:CGFloat = 12
    
    private var FILL_ALPHA:CGFloat = 0.4
    
    public var cursor:CAShapeLayer
    public var cursorPos:CGPoint
    public var cursorColor:UIColor
    public var cursorView:UIView
    
    // Paths
    public var brushPath:UIBezierPath
    public var eraserPath:UIBezierPath
    
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
        
        // Create paths
        self.brushPath = UIBezierPath(arcCenter: cursorPos, radius: CGFloat(radius), startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        self.eraserPath = UIBezierPath(roundedRect: CGRect(x: cursorPos.x - CGFloat(radius), y: cursorPos.y - CGFloat(radius), width: CGFloat(radius) * 2, height: CGFloat(radius) * 2), cornerRadius: self.ERASE_RADIUS)
        
        // Create a new shape with the path of a circle for the brush
        let cursor = CAShapeLayer()
        cursor.path = self.brushPath.cgPath
        cursor.frame = canvasView.frame
        cursor.zPosition = CGFloat(worldOffset)
        
        // Fill color
        cursor.fillColor = color.withAlphaComponent(FILL_ALPHA).cgColor
        // Stroke color
        cursor.strokeColor = color.cgColor
        self.cursorColor = color
        // Line width
        cursor.lineWidth = CGFloat(thickness)
        cursor.anchorPointZ = CGFloat(worldOffset)
        
        cursor.shadowOffset = CGSize(width: 0, height: 0)
        cursor.shadowRadius = 3
        cursor.shadowOpacity = 1
        cursor.shadowColor = UIColor.gray.cgColor
        
        self.cursor = cursor
        
        // Set border color
        cursorView.layer.borderColor = color.cgColor
        cursorView.layer.borderWidth = CGFloat(2)
        
        // Allow cursor dragging
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedCursor(_:)))
        cursorView.isUserInteractionEnabled = true
        cursorView.addGestureRecognizer(panGesture)
        
        // Add cursor as a sublayer to its view
        self.cursorView.layer.addSublayer(self.cursor)
        
        // Add the cursor's view as a subview to the canvas
        self.canvasView.addSubview(self.cursorView)
    }
    
    func resizeCursor(radius:CGFloat) {
        self.brushPath = UIBezierPath(arcCenter: cursorPos, radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        self.eraserPath = UIBezierPath(roundedRect: CGRect(x: cursorPos.x - CGFloat(radius), y: cursorPos.y - CGFloat(radius), width: CGFloat(radius) * 2, height: CGFloat(radius) * 2), cornerRadius: self.ERASE_RADIUS)
        
        self.cursor.path = brushPath.cgPath
    }
    
    func repositionCursor(position:CGPoint) {
        
    }
    
    func changeCursorColor(color:UIColor) {
        cursor.strokeColor = color.cgColor
        cursor.fillColor = color.withAlphaComponent(FILL_ALPHA).cgColor
        cursorColor = color
    }
    
    func changeToEraser() {
        cursor.strokeColor = ERASE_COLOR.cgColor
        cursor.path = self.eraserPath.cgPath
    }
    
    func changeToBucket() {
        cursor.path = self.eraserPath.cgPath
    }
    
    func revertToBrush() {
        cursor.strokeColor = cursorColor.cgColor
        cursor.path = self.brushPath.cgPath
    }
    
    @objc func draggedCursor(_ sender:UIPanGestureRecognizer) {
    }
    
}
