//
//  QueueProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/12/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation

class QueueProvider {
      
      var label:String
      var queue:DispatchQueue
      var isSuspended:Bool
      
      init (label:String) {
            self.label = label
            self.queue = DispatchQueue(label: label)
            self.isSuspended = false
      }
      
      func suspend() {
            if !isSuspended {
                  queue.suspend()
                  isSuspended = true
            }
      }
      
      func resume() {
            if isSuspended {
                  queue.resume()
                  isSuspended = false
            }
      }
      
      func execute(actions:@escaping ()->Void, iterate:Bool = false, delay:UInt32 = 10000) {
            queue.async {
                  
                  // Only runs if the dispatch isn't suspended
                  // Crucial to efficiency
                  guard !self.isSuspended else { return }
                  
                  // Runs actions
                  actions()
                  
                  // Recurrance call
                  if iterate {
                        usleep(delay)
                        self.execute(actions: actions, iterate: iterate)
                  }
            }
      }
}
