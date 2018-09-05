//
//  SizeSliderView.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/2/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

protocol SizeSliderViewDelegate {
    
    /// Called when the slider's value is changed
    func sizeSliderView(didChangeValue value:Int)
    
}

/// Abstract: - Slider that enables brush size changes.
class SizeSliderView: UIView {
    
    // MARK: - IBOutlets
    
    /// View containing slider bubble
    @IBOutlet weak var sliderView: UIView!
    
    /// Draggable slider bubble
    @IBOutlet weak var sliderBubbleView: UIView!
    
    /// Distance from top of slider bubble to the safe area
    @IBOutlet weak var sliderBubbleViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - IBInspectable Value Variables
    
    /// Maximum slider value
    @IBInspectable var maximumValue:Int = 100
    
    /// Minimum slider value
    @IBInspectable var minimumValue:Int = 1
    
    /// Current slider value
    @IBInspectable var currentValue:Int = 50 {
        didSet {
            updateBubblePosition()
            if delegate != nil {
                delegate?.sizeSliderView(didChangeValue: currentValue)
            }
        }
    }
    
    /// UIView displaying the value as a tooltip
    private var valueTooltip:UIView?
    
    /// Class's SizeSliderViewDelegate
    var delegate:SizeSliderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    /// Called when the view loads from the XIB.
    func didLoad() {
        fromNib()
        
        let dragSliderGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragSlider))
        dragSliderGesture.delegate = self
        sliderView.addGestureRecognizer(dragSliderGesture)
    }
    
    /// Updates the position of the sliderBubbleView in relation to the values
    func updateBubblePosition() {
        let basedMaximumValue = maximumValue - minimumValue
        let basedCurrentValue = currentValue - minimumValue
//        sliderBubbleViewTopConstraint.constant = CGFloat(basedCurrentValue/basedMaximumValue)*(self.frame.height + sliderBubbleView.frame.height)
    }
    
    /// Called when the sliderBubbleView is dragged
    @objc func didDragSlider(_ sender:UIPanGestureRecognizer) {
        let currentBubbleViewTop = sliderBubbleViewTopConstraint.constant
        let currentBubbleViewBottom = currentBubbleViewTop + sliderBubbleView.frame.height
        
        let dragDistance = sender.translation(in: self).y
        let dragPosition = sender.view?.center.y ?? 0
        
        // Animate on start and end
        if sender.state == .began {
            FeedbackProvider.weak()
            UIView.bkDampAnimation(animations: {
                self.sliderBubbleView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
            showTooltip()
        } else if sender.state == .changed {
            for subview in self.valueTooltip?.subviews ?? [] {
                if let valueLabel = subview as? UILabel {
                    valueLabel.text = "\(currentValue)"
                }
            }
        } else {
            UIView.bkDampAnimation(animations: {
                self.sliderBubbleView.transform = .identity
            })
            hideTooltip()
        }
        
        // Update slider view position
        sliderBubbleViewTopConstraint.constant = dragDistance > 0 ? min(dragPosition + dragDistance, frame.height - sliderBubbleView.frame.height/2) : max(dragPosition + dragDistance, -sliderBubbleView.frame.height/2)
        
        if valueTooltip != nil {
            valueTooltip?.center.y = sliderBubbleView.center.y
        }
        
        // Update values
        let basedMaximumValue = maximumValue - minimumValue + 1
        let basedCurrentValue = maximumValue - Int(sliderBubbleView.center.y/self.frame.height*CGFloat(basedMaximumValue))
        
        currentValue = basedCurrentValue
        print("Based Max: \(basedMaximumValue)\nValue: \(currentValue)")
    }
    
    /// Shows the value tooltip on the side of the slider
    func showTooltip() {
        let TOOLTIP_SIZE = CGSize(width: 40, height: 20)
        valueTooltip = UIView(frame: CGRect(x: sliderBubbleView.frame.maxX + 8, y: sliderBubbleView.frame.minY, width: TOOLTIP_SIZE.width, height: TOOLTIP_SIZE.height))
        
        let valueLabel = UILabel(frame: .zero)
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        valueLabel.textColor = UIColor.white
        valueTooltip?.addSubview(valueLabel)
        valueLabel.frame = CGRect(x: 0, y: 0, width: TOOLTIP_SIZE.width, height: TOOLTIP_SIZE.height)
        
        valueTooltip?.alpha = 0
        
        addSubview(valueTooltip!)
        
        valueTooltip?.heightAnchor.constraint(equalToConstant: TOOLTIP_SIZE.height).isActive = true
        valueTooltip?.widthAnchor.constraint(equalToConstant: TOOLTIP_SIZE.width).isActive = true
        
        UIView.bkDampAnimation(animations: {
            self.valueTooltip?.alpha = 1
        })
    }
    
    /// Hides the value tooltip
    func hideTooltip() {
        UIView.bkDampAnimation(animations: {
            self.valueTooltip?.alpha = 0
        }) { (didComplete:Bool) in
            self.valueTooltip?.removeFromSuperview()
            self.valueTooltip = nil
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension SizeSliderView:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
