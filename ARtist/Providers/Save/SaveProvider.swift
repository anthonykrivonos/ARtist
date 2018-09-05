//
//  SaveProvider.swift
//  ARtist
//
//  Created by Anthony Krivonos on 4/24/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import Foundation
import UIKit

import SideMenu

class SaveProvider {
      
      public var parentViewController:UIViewController
      
      public static var LOCAL_SAVED_DRAWINGS_KEY:String = "LOCAL_SAVED_DRAWINGS"
      
      
      init(parentViewController:UIViewController) {
            self.parentViewController = parentViewController
      }
      
      func promptSaveDrawing(closure:@escaping (String)->Void) {
            let alertController = UIAlertController(title: "Save File", message: "Enter the file name.", preferredStyle: .alert)
            
            //the confirm action taking the inputs
            let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
                  let fileName = alertController.textFields?[0].text
                  closure(fileName!)
            }
            
            //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Close", style: .cancel) { (_) in }
            
            //adding textfields to our dialog box
            alertController.addTextField { (textField) in
                  textField.placeholder = "Untitled"
            }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            parentViewController.present(alertController, animated: true, completion: nil)
      }
}
