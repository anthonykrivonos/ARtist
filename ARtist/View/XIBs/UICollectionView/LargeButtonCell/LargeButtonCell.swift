//
//  LargeButtonCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class LargeButtonCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// Large button with actions
    @IBOutlet weak var largeButton: UIButton!
    
    // MARK: - Globals
    
    /// Action called on button click
    var action:(()->Void)?
    
    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Initializes the large button within the cell
    public func initialize(withTitle title:String, andTextColor textColor:UIColor, andBackgroundColor backgroundColor:UIColor, andAction action:@escaping ()->Void) {
        
        largeButton.setTitle(title, for: .normal)
        largeButton.setTitleColor(textColor, for: .normal)
        largeButton.backgroundColor = backgroundColor
        
        self.action = action
    }

    
    // MARK: - IBActions
    
    @IBAction func didTapLargeButton(_ sender: Any) {
        
        if action != nil {
            action!()
        }
        
    }
    
}
