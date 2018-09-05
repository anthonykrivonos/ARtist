//
//  FeedbackProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/11/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit

class FeedbackProvider {
    
    static private let isFeedbackAvailable = UIDevice.current.value(forKey: "_feedbackSupportLevel") as! Int == 2
    
    static func weak() {
        if isFeedbackAvailable {
            UISelectionFeedbackGenerator().prepare()
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    static func medium() {
        if isFeedbackAvailable {
            UIImpactFeedbackGenerator().prepare()
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
    
    static func strong() {
        if isFeedbackAvailable {
            UINotificationFeedbackGenerator().prepare()
            UINotificationFeedbackGenerator().notificationOccurred(UINotificationFeedbackType.success)
        }
    }
}
