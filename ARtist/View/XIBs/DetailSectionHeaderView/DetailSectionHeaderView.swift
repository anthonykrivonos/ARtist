//
//  DetailSectionHeaderView.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class DetailSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Set the title of the section, uppercased.
    public func setTitle(to title:String) {
        sectionTitleLabel.text = title.uppercased()
    }
    
}
