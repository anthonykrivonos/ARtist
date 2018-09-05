//
//  SaveModel.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/25/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit

class SaveModel:NSObject, NSCoding {
    
    // Name of saved file
    private var fileName:String
    
    // Thumbnail image of saved file
    private var thumbnail:UIImage
    
    // Screenshots of the saved file
    private var screenshots:[UIImage]
    
    // Drawing model being saved
    private var drawing:DrawingModel
    
    // Date of last save
    private var saveDate:Date?
    
    // Date of original save
    private var originalSaveDate:Date?
    
    // Number of times the save was overwritten
    private var overwriteCount:Int
    
    init(fileName:String, thumbnail:UIImage, screenshots:[UIImage], drawing:DrawingModel, saveDate:Date?) {
        self.fileName = fileName
        self.thumbnail = thumbnail
        self.screenshots = screenshots
        self.drawing = drawing
        self.originalSaveDate = saveDate
        self.saveDate = saveDate
        self.overwriteCount = 0
    }
    
    //
    // Encoding for storage
    //
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(fileName, forKey: "fileName")
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(screenshots, forKey: "screenshots")
        aCoder.encode(drawing, forKey: "drawing")
        aCoder.encode(originalSaveDate, forKey: "originalSaveDate")
        aCoder.encode(saveDate, forKey: "saveDate")
        aCoder.encode(overwriteCount, forKey: "overwriteCount")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.fileName = aDecoder.decodeObject(forKey: "fileName") as? String ?? ""
        self.thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as! UIImage
        self.screenshots = aDecoder.decodeObject(forKey: "screenshots") as? [UIImage] ?? []
        self.drawing = aDecoder.decodeObject(forKey: "drawing") as! DrawingModel
        self.originalSaveDate = aDecoder.decodeObject(forKey: "originalSaveDate") as! Date
        self.saveDate = aDecoder.decodeObject(forKey: "saveDate") as? Date
        self.overwriteCount = aDecoder.decodeInteger(forKey: "overwriteCount")
    }
    
    /// Overwrite saved drawing
    func overwrite(thumbnail:UIImage, screenshots:[UIImage], drawing:DrawingModel, saveDate:Date?) {
        self.thumbnail = thumbnail
        self.screenshots = screenshots
        self.drawing = drawing
        if self.originalSaveDate == nil && saveDate != nil {
            self.originalSaveDate = saveDate!
        }
        self.saveDate = saveDate
        self.overwriteCount += 1
    }
    
    /// Append a screenshot to the save model's list
    func append(screenshot:UIImage) {
        screenshots.append(screenshot)
    }
    
    //
    // Getters
    //
    
    func getFileName() -> String {
        return self.fileName
    }
    
    func getThumbnail() -> UIImage {
        return self.thumbnail
    }
    
    func getScreenshots() -> [UIImage] {
        return self.screenshots
    }
    
    func getSavedDrawing() -> DrawingModel {
        return self.drawing
    }
    
    func getSaveDate() -> Date? {
        return self.saveDate
    }
    
    func getOriginalSaveDate() -> Date? {
        return self.originalSaveDate
    }
    
    func getOverwriteCount() -> Int {
        return self.overwriteCount
    }
}
