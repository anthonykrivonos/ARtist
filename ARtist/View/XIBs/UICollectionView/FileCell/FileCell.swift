//
//  FileCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class FileCell: UICollectionViewCell {
    
    /// Canvas Controller with drawing
    var canvasController:CanvasController!
    
    // MARK: - IBOutlets
    
    /// File screenshot preview view
    @IBOutlet weak var previewView: UIImageView!
    
    /// View displaying options on tap
    @IBOutlet weak var overlayView: UIView!
    
    /// Label displaying the file's name
    @IBOutlet weak var fileNameLabel: UILabel!
    
    /// Button that triggers file loading
    @IBOutlet weak var loadButton: UIButton!
    
    // MARK: - Globals
    
    /// File this cell is for
    var file:SaveModel!
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let showOverlayRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOverlay))
        showOverlayRecognizer.delegate = self
        previewView.addGestureRecognizer(showOverlayRecognizer)
        
        let hideOverlayRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideOverlay))
        hideOverlayRecognizer.delegate = self
        overlayView.addGestureRecognizer(hideOverlayRecognizer)
        
        let didTapLoadButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLoadButton))
        didTapLoadButtonRecognizer.delegate = self
        loadButton.addGestureRecognizer(didTapLoadButtonRecognizer)
    }

    /// Initialize the screenshotCell with an image
    func initialize(withFile file:SaveModel) {
        previewView.image = file.getThumbnail()
        fileNameLabel.text = file.getFileName().uppercased()
        self.file = file
        hideOverlay()
    }

    /// Shows the options overlay
    @objc func showOverlay(_ sender:UITapGestureRecognizer) {
        overlayView.isHidden = false
        UIView.bkDampAnimation(animations: {
            self.overlayView.alpha = 1
        }) { (didComplete:Bool) in
            self.loadButton.isEnabled = true
        }
    }

    /// Hides the options overlay
    @objc func hideOverlay() {
        loadButton.isEnabled = false
        UIView.bkDampAnimation(animations: {
            self.overlayView.alpha = 0
        }) { (didComplete:Bool) in
            self.overlayView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapLoadButton(_ sender:UITapGestureRecognizer) {
        canvasController.load(file: file)
        EntryProvider().showToast(title: "Loaded \(file.getFileName())", description: "Last Saved \(file.getSaveDate()?.timeAgo() ?? "sometime ago")", position: .top, duration: 2, image: file.getThumbnail())
        hideOverlay()
    }

}

// MARK: - UIGestureRecognizer
extension FileCell:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
