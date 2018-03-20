//
//  BrushSizeSliderProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/19/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

// Native imports
import Foundation
import ARKit

// Pod imports
import fluid_slider

class BrushSizeSliderProvider {
      
      public var brushSizeSlider:Slider
      
      public var brushSizeSliderPos:CGPoint
      
      public var canvasView:ARSCNView
      
      public var brush:BrushModel
      public var cursorProvider:CursorProvider
      
      public var brushSizeMax:CGFloat
      
      init(canvasView:ARSCNView, brushSizeSliderPos:CGPoint, width:CGFloat, height:CGFloat, brush:BrushModel, cursorProvider:CursorProvider, brushSizeMax:CGFloat) {
            self.canvasView = canvasView
            self.brush = brush
            self.cursorProvider = cursorProvider
            self.brushSizeSliderPos = brushSizeSliderPos
            self.brushSizeMax = brushSizeMax
            
            // Instantiate slider
            self.brushSizeSlider = Slider()
            brushSizeSlider.frame = CGRect(x: brushSizeSliderPos.x - width/2, y: brushSizeSliderPos.y, width: width, height: height)
            let labelTextAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
            brushSizeSlider.attributedTextForFraction = { fraction in
                  let formatter = NumberFormatter()
                  formatter.maximumIntegerDigits = 3
                  formatter.maximumFractionDigits = 0
                  let string = formatter.string(from: (fraction * brushSizeMax) as NSNumber) ?? ""
                  return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
            }
            brushSizeSlider.tintColor = UIColor.blue
            brushSizeSlider.setMinimumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
            brushSizeSlider.setMaximumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
            brushSizeSlider.fraction = 0.5
            brushSizeSlider.shadowOffset = CGSize(width: 0, height: 10)
            brushSizeSlider.shadowBlur = 5
            brushSizeSlider.shadowColor = UIColor(white: 0, alpha: 0.1)
            brushSizeSlider.valueViewColor = .white
            brushSizeSlider.didBeginTracking = { [weak self] _ in
            }
            brushSizeSlider.didEndTracking = { [weak self] _ in
            }
            
            // Allow color changing
            brushSizeSlider.addTarget(self, action: #selector(changeSliderSize), for: .valueChanged)
            
            // Allow hero animations on slider's view
            brushSizeSlider.isHeroEnabled = true
            brushSizeSlider.heroID = "brushSizeSlider"
            brushSizeSlider.heroModifiers = [.translate(y:100)]
            
            // Add the brush slider's view as a subview to the canvas
            canvasView.addSubview(brushSizeSlider)
            canvasView.bringSubview(toFront: brushSizeSlider)
      }
      
      @objc func changeSliderSize() {
            let size:CGFloat = brushSizeSlider.fraction * brushSizeMax
            cursorProvider.resizeCursor(radius: size)
            brush.size = Float(size/10000);
      }
}
