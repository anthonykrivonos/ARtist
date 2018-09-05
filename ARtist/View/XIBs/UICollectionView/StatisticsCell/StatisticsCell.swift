//
//  StatisticsCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class StatisticsCell: UICollectionViewCell {
    
    /// Larger label displaying a number
    @IBOutlet weak var numberLabel: UILabel!
    
    /// Smaller text indicating what this statistic entails
    @IBOutlet weak var subtextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Initializes the statistics cell
    public func initialize(forStatistic statistic:String, andNumber number:Int) {
        numberLabel.text = String(number)
        subtextLabel.text = statistic.uppercased()
    }

}
