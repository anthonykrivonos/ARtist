//
//  Storage.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/21/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation

class StorageProvider {
      
      private static var storage:UserDefaults = UserDefaults.standard
      
      // Sets the value at key "key" to "val", returns "val"
      static func set(key:String, val:Any) {
            let encodedVal = NSKeyedArchiver.archivedData(withRootObject: val)
            StorageProvider.storage.set(encodedVal, forKey: key)
      }
      
      // Gets the value at "key" or returns nil
      static func get<GenericType>(key:String, valueType: GenericType.Type) -> Any? {
            if let decoded = StorageProvider.storage.object(forKey: key) as? Data {
                  let decodedVal = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? GenericType
                  return decodedVal
            }
            return nil
      }
}
