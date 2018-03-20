//
//  ColorSliderProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/12/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

// Native imports
import Foundation
import ARKit

// Pod imports
import ColorSlider

extension UIColor {
      var coreImageColor: CIColor {
            return CIColor(color: self)
      }
      var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            let coreImageColor = self.coreImageColor
            return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
      }
}

class ColorSliderProvider {

      public var colorSlider:ColorSlider
      
      public var colorSliderPos:CGPoint

      public var canvasView:ARSCNView
      
      public var brush:BrushModel
      public var cursor:CAShapeLayer
      
      public var brushSizeSliderProvider:BrushSizeSliderProvider
      
      init(canvasView:ARSCNView, colorSliderPos:CGPoint, width:CGFloat, height:CGFloat, padding:CGFloat, direction:DefaultPreviewView.Side, brush:BrushModel, cursor:CAShapeLayer, brushSizeSliderProvider:BrushSizeSliderProvider) {
            self.canvasView = canvasView
            self.brush = brush
            self.cursor = cursor
            self.brushSizeSliderProvider = brushSizeSliderProvider
            
            let colorSliderPosition = CGPoint(x: colorSliderPos.x + (colorSliderPos.x > canvasView.frame.midX ? (padding * -1) : padding), y: colorSliderPos.y)
            
            self.colorSliderPos = colorSliderPosition
            
            // Instantiate slider
            colorSlider = ColorSlider(orientation: .vertical, previewSide: direction)
            
            // Set size of slider
            colorSlider.frame = CGRect(origin: self.colorSliderPos, size: CGSize(width: width, height: height))
            
            // Add padding to colorSlider
            colorSlider.frame.insetBy(dx: padding * -1, dy: padding * -1)
            
            // Set slider's default color
            colorSlider.color = brush.color
            
            // Allow color changing
            colorSlider.addTarget(self, action: #selector(changeSliderColor(_:)), for: .valueChanged)
            
            // Allow hero animations on slider's view
            colorSlider.isHeroEnabled = true
            colorSlider.heroID = "colorSlider"
            colorSlider.heroModifiers = [.translate(y:100)]
            
            // Add the cursor's view as a subview to the canvas
            canvasView.addSubview(colorSlider)
      }
      
      @objc func changeSliderColor(_ slider: ColorSlider) {
            brush.color = slider.color
            cursor.strokeColor = slider.color.cgColor
            brushSizeSliderProvider.brushSizeSlider.contentViewColor = slider.color
            brushSizeSliderProvider.brushSizeSlider.valueViewColor = textColorBasedOnBackground(color: slider.color)
      }
      
      func textColorBasedOnBackground(color:UIColor) -> UIColor {
            var d:Int = 0;
            // Counting the perceptive luminance - human eye favors green color...
            let alpha:Double = 1 - (0.299 * Double(color.components.red) + 0.587 * Double(color.components.green) + 0.114 * Double(color.components.blue))/255.0
      
            if (alpha < 0.5) {
                  d = 0;
            } else {
                  d = 255;
            }
            return UIColor(red: CGFloat(d), green: CGFloat(d), blue: CGFloat(d), alpha: 1)
      }
      
}
