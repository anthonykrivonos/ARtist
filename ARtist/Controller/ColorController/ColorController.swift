//
//  ColorController.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/3/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol ColorControllerDelegate {
    func colorController(didChangeColorTo color:UIColor)
}

class ColorController: UIViewController {
    
    /// Chroma color picker
    @IBOutlet weak var colorPicker: ChromaColorPicker!
    
    var delegate:ColorControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        colorPicker.delegate = self
        colorPicker.hexLabel.textColor = Color.offWhite
        colorPicker.hexLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        // Change plus button to checkmark
        colorPicker.addButton.plusIconLayer?.removeFromSuperlayer()
        colorPicker.addButton.setImage(#imageLiteral(resourceName: "Checkmark Icon.png").resizeWith(width: 30)?.maskWithColor(color: Color.offWhite), for: .normal)
        colorPicker.addButton.bringSubview(toFront: colorPicker.addButton.imageView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ColorController:ChromaColorPickerDelegate {
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        FeedbackProvider.weak()
        if delegate != nil {
            delegate?.colorController(didChangeColorTo: color)
        }
    }
    
}
