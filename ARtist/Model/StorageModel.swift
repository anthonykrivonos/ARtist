//
//  StorageModel.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/25/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation

class StorageModel:NSObject, NSCoding {
      
      // List of saves in storage
      private var saves:[SaveModel]
      
      // Number of saves in stroage
      private var count:Int
      
      override init() {
            self.saves = []
            self.count = 0
      }
      
      //
      // Encoding for storage
      //
      
      func encode(with aCoder: NSCoder) {
            aCoder.encode(saves, forKey: "saves")
            aCoder.encode(count, forKey: "count")
      }
      
      required init?(coder aDecoder: NSCoder) {
            self.saves = aDecoder.decodeObject(forKey: "saves") as? [SaveModel] ?? []
            self.count = aDecoder.decodeInteger(forKey: "count")
      }
      
      // Push save to end of drawing
      func save(save:SaveModel) -> [SaveModel] {
            let overwrittenSave:SaveModel? = get(withFileName: save.getFileName())
            if overwrittenSave != nil {
                overwrittenSave?.overwrite(thumbnail: save.getThumbnail(), screenshots: save.getScreenshots(), drawing: save.getSavedDrawing(), saveDate: save.getSaveDate())
            } else {
                  saves.append(save)
                  count += 1
            }
            return self.saves
      }
      
      // Remove save with savemodel
      func remove(save:SaveModel) -> SaveModel? {
            for i in 0...saves.count {
                  if (saves[i].getFileName() == save.getFileName()) {
                        return removeAtIndex(index: i)
                  }
            }
            return nil
      }
      
      // Remove save at a certain index from the storage
      func removeAtIndex(index:Int) -> SaveModel? {
            if count > 0 {
                  let removedSave = saves.remove(at: index)
                  count -= 1
                  return removedSave
            }
            return nil
      }
      
      // Pop last save from storage
      func pop() -> SaveModel? {
            if count > 0 {
                  let poppedSave = saves.popLast()
                  count -= 1
                  return poppedSave
            }
            return nil
      }
      
      // Clear the entire storage
      func clear() -> [SaveModel] {
            let clearedSaves:[SaveModel] = self.saves
            self.saves = []
            return clearedSaves
      }
      
      // Get a save at a given index
      func get(atIndex:Int) -> SaveModel? {
            if count > atIndex {
                  return saves[atIndex]
            }
            return nil
      }
      
      // Finds if another save with the same name is present
      func get(withFileName:String) -> SaveModel? {
            for storedSave in saves {
                  if (withFileName == storedSave.getFileName()) {
                        return storedSave
                  }
            }
            return nil
      }
      
      // Return the entire storage
      func getStorage() -> [SaveModel] {
            return self.saves
      }
      
      // Return the count
      func getCount() -> Int {
            return self.count
      }
      
}
