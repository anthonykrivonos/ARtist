//
//  ScreenshotCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class ScreenshotCell: UICollectionViewCell {
    
    /// Canvas Controller with drawing
    var canvasController:CanvasController!
    
    // MARK: - IBOutlets
    
    /// Image view displaying the screenshot
    @IBOutlet weak var screenshotView: UIImageView!
    
    /// View displaying options on tap
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let showRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOverlay))
        showRecognizer.delegate = self
        screenshotView.addGestureRecognizer(showRecognizer)
        
        let hideRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideOverlay))
        hideRecognizer.delegate = self
        overlayView.addGestureRecognizer(hideRecognizer)
    }
    
    /// Initialize the screenshotCell with an image
    func initialize(withScreenshot screenshot:UIImage) {
        screenshotView.image = screenshot
        hideOverlay()
    }
    
    /// Shows the options overlay
    @objc func showOverlay(_ sender:UITapGestureRecognizer) {
        overlayView.isHidden = false
        UIView.bkDampAnimation(animations: {
            self.overlayView.alpha = 1
        })
    }
    
    /// Hides the options overlay
    @objc func hideOverlay() {
        UIView.bkDampAnimation(animations: {
            self.overlayView.alpha = 0
        }) { (didComplete:Bool) in
            self.overlayView.isHidden = true
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapSaveToAlbum(_ sender: Any) {
        
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        
    }
    
}

// MARK: - UIGestureRecognizer

extension ScreenshotCell:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
