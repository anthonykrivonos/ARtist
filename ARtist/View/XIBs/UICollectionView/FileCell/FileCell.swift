//
//  FileCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class FileCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// File screenshot preview view
    @IBOutlet weak var previewView: UIImageView!
    
    /// View displaying options on tap
    @IBOutlet weak var overlayView: UIView!
    
    /// Label displaying the file's name
    @IBOutlet weak var fileNameLabel: UILabel!
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLoadButton)))
        previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showOverlay)))
    }

    /// Initialize the screenshotCell with an image
    func initialize(withFile file:SaveModel) {
        previewView.image = file.getThumbnail()
        fileNameLabel.text = file.getFileName().uppercased()
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
    
    // MARK: - Actions
    
    @objc func didTapLoadButton(_ sender:UITapGestureRecognizer) {
    
        
        
    }

}
