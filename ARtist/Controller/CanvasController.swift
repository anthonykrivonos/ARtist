//
//  CanvasController.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/10/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

// Native Imports
import UIKit
import ARKit

import EzPopup

class CanvasController: UIViewController, ARSCNViewDelegate {
     
     //
     // MARK - IBOutlets
     //
     
     /// ARScene view for canvas
     @IBOutlet weak var canvasView: ARSCNView!
    
     /// View displayed when a popup appears
     @IBOutlet weak var overlayView: UIView!
    
     @IBOutlet weak var brushSizeSliderView: SizeSliderView!
     
     @IBOutlet weak var undoButton: UIButton!
     @IBOutlet weak var redoButton: UIButton!
     
     @IBOutlet weak var brushColorButton: UIButton!
     
     @IBOutlet weak var detailCardView: DetailCardView!
     
     @IBOutlet weak var detailCardViewBottomConstraint: NSLayoutConstraint!
     
     @IBOutlet weak var detailCardViewHeightConstraint: NSLayoutConstraint!
     
     // DQ for asynchronous methods
     let brushQueue:QueueProvider = QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.Brush")
     let undoQueue:QueueProvider = QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.Undo")
     let redoQueue:QueueProvider = QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.Redo")
     let eraseQueue:QueueProvider = QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.Erase")
     let bucketQueue:QueueProvider = QueueProvider(label: "com.AnthonyKrivonos.ARtist.DQ.Queue")
     
     //
     // Canvas variables
     //
     
     // Tools for operating on canvasView
     var canvasProvider:CanvasProvider!
     
     // Cursor for drawing
     var cursorProvider:CursorProvider!
     
     // For saving alert
     var saveProvider:SaveProvider!
     
     // For storage
     var storageProvider:StorageProvider!
     
     // Position of current vector in world space
     var currentWorldCoord:SCNVector3?
     
     // Current file being edited
     var currentFile:SaveModel? {
          didSet {
               updateDetailCardView()
          }
     }
     
     // Current brush in use
     var brush:BrushModel? {
          didSet {
               brushColorButton.backgroundColor = brush?.color
          }
     }
     
     //
     // Boolean Globals
     //
     
     // Allow repositioning of cursor
     var canReposition:Bool = true
     
     //
     // Popup Containers
     //
     
     var colorPickerPopup:PopupViewController?
     
     //
     // Constants
     //
     
     // Turns on debug features
     let DEBUG:Bool = false
     
     // Default brush variables
     let DEFAULT_BRUSH_COLOR:UIColor = .white
     let DEFAULT_BRUSH_OFFSET:Float = 0.1
     
     // Default slider variables specifically for brush size slider
     var DEFAULT_BRUSH_SIZE_MAX:CGFloat = 100
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          canvasView.delegate = self
          
          // Show statistics such as fps and timing information
          canvasView.showsStatistics = DEBUG
          
          // Create a new scene
          let scene = SCNScene()
          
          // Set the scene to the view
          canvasView.scene = scene
          
          // Enable Default Lighting - makes the 3D text a bit poppier.
          canvasView.autoenablesDefaultLighting = true
          
          // Configure provider for operating on canvasView
          canvasProvider = CanvasProvider(canvasView: canvasView, worldOffset: DEFAULT_BRUSH_OFFSET, onCapture: onCapture)
          
          // Sets default brush on open
          // TODO: Make this more dynamic
          brush = BrushModel(size: 2, color: DEFAULT_BRUSH_COLOR, opacity: 1)
          
          // Creates round cursor and a provider along with it
          cursorProvider = CursorProvider(canvasView: canvasView, worldOffset: DEFAULT_BRUSH_OFFSET, position: CGPoint(x: canvasView.frame.midX, y: canvasView.frame.midY), radius: 25, thickness: 2, color: DEFAULT_BRUSH_COLOR, brush: brush!)
          
          // Instantiate the save provider
          saveProvider = SaveProvider(parentViewController: self)
          
          // Instantiate the storage provider
          storageProvider = StorageProvider()
          
          // Set slider delegate
          brushSizeSliderView.delegate = self
          
          // Initialize current file
          currentFile = SaveModel(fileName: "", thumbnail: UIImage(), screenshots: [], drawing: self.canvasProvider.drawList, saveDate: nil)
          
          // Tap and hold gesture recognizer for drawing
          let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCanvas))
          longPressGesture.delegate = self
          canvasView.addGestureRecognizer(longPressGesture)
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          // Set status bar to light
          UIApplication.shared.statusBarStyle = .lightContent
          
          // Create a session configuration
          let configuration = ARWorldTrackingConfiguration()
          
          // Enable plane detection
          configuration.planeDetection = .horizontal
          
          // Run the view's session
          canvasView.session.run(configuration)
          
          // Display undo and redo if able
          displayOperations()
          
          // Initialize detailCardView
          detailCardView.storage = StorageProvider.get(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, valueType: StorageModel.self) as? StorageModel
          detailCardView.currentSave = currentFile
          detailCardView.canvasController = self
          
          // Initialize card view toggling
          let tapToShowDetailCard = UITapGestureRecognizer(target: self, action: #selector(tapToShowDetailCardView))
          let swipeDownToHideDetailCard = UIPanGestureRecognizer(target: self, action: #selector(swipeDownToHideDetailCardView))
          tapToShowDetailCard.delegate = self
          swipeDownToHideDetailCard.delegate = self
          detailCardView.addGestureRecognizer(tapToShowDetailCard)
          detailCardView.addGestureRecognizer(swipeDownToHideDetailCard)
          
          // Initialize overlay view
          let tapToHideOverlay = UITapGestureRecognizer(target: self, action: #selector(tapToHideOverlayView))
          tapToHideOverlay.delegate = self
          overlayView.addGestureRecognizer(tapToHideOverlay)
     }
     
     override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          
          // Pause the view's session
          canvasView.session.pause()
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     /// Change status bar color to white
     override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
     }
     
     //
     // Detail View Displaying
     //
     
     @objc func tapToShowDetailCardView(_ sender:UITapGestureRecognizer) {
          if detailCardViewBottomConstraint.constant >= -DetailCardView.PEEK_VIEW_HEIGHT {
               FeedbackProvider.medium()
               showDetailCardView()
          }
     }
     
     @objc func swipeDownToHideDetailCardView(_ sender:UIPanGestureRecognizer) {
          if sender.translation(in: view).y > 100 {
               FeedbackProvider.weak()
               hideDetailCardView()
          }
     }
     
     func showDetailCardView() {
          showOverlay()
          detailCardViewHeightConstraint.constant = detailCardView.intrinsicContentSize.height
          detailCardViewBottomConstraint.constant = -detailCardViewHeightConstraint.constant - self.view.safeAreaInsets.bottom
          UIView.bkDampAnimation(animations: {
               self.view.layoutIfNeeded()
          })
     }
     
     func hideDetailCardView() {
          hideOverlay()
          detailCardViewHeightConstraint.constant = detailCardView.intrinsicContentSize.height
          detailCardViewBottomConstraint.constant = -DetailCardView.PEEK_VIEW_HEIGHT - self.view.safeAreaInsets.bottom
          UIView.bkDampAnimation(animations: {
               self.view.layoutIfNeeded()
          })
     }
     
     func updateDetailCardView() {
          hideDetailCardView()
          detailCardView.updateDetails()
     }
     
     //
     // Overlay view displaying
     //
     
     @objc func tapToHideOverlayView(_ sender:UITapGestureRecognizer) {
          hideOverlay()
          if colorPickerPopup != nil {
               colorPickerPopup?.dismiss(animated: true, completion: nil)
          }
          hideDetailCardView()
     }
     
     /// Display the overlay view
     func showOverlay() {
          overlayView.isHidden = false
          UIView.bkDampAnimation(animations: {
               self.overlayView.alpha = 1
          })
     }
     
     /// Hide the overlay view
     func hideOverlay() {
          UIView.bkDampAnimation(animations: {
               self.overlayView.alpha = 0
          }) { (didComplete:Bool) in
               self.overlayView.isHidden = true
          }
     }
     
     //
     // Camera Actions
     //
     
     // Call this function when the user captures a snapshat on the CanvasProvider
     func onCapture(snapshot:UIImage?) -> Void {
          if (snapshot != nil && currentFile != nil) {
               // Image was taken
               // Play camera sound
               
               currentFile!.append(screenshot: snapshot!)
               detailCardView.updateDetails()
               
               AudioServicesPlaySystemSound(1108);
               
               // Vibrate on picture taken
               FeedbackProvider.strong()
               
               // Animate the screen flash
               animateFlash(completion: { () -> Void in
                    EntryProvider().showToast(title: "Captured!", description: "Find your screenshot below.", position: .top, duration: 2, image: snapshot)
               })
          } else {
               // Image wasn't taken
          }
     }
     
     // Animate a screen flash when the user takes a snapshot
     func animateFlash(completion:@escaping ()->Void) -> Void {
          let flashView = UIView(frame: canvasView.frame)
          flashView.alpha = 0
          flashView.backgroundColor = UIColor.white
          canvasView.addSubview(flashView)
          UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { () -> Void in
               flashView.alpha = 1
          }, completion: { (Bool) -> Void in
               flashView.alpha = 0
               completion()
          })
     }
     
     //
     // Brush Functions
     //
     
     func changeBrushColor(toColor color:UIColor) {
          self.brush?.color = color
          self.cursorProvider.changeCursorColor(color: color)
          self.brushColorButton.backgroundColor = color
     }
     
     
     //
     // Save/Load Functions
     //
     
     /// Saves a model and returns the updated model
     func save(save:SaveModel) -> SaveModel {
          var storedDrawings:StorageModel? = StorageProvider.get(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, valueType:StorageModel.self) as? StorageModel
          
          if storedDrawings == nil {
               storedDrawings = StorageModel()
          }
          
          _ = storedDrawings?.save(save: save)
          
          _ = StorageProvider.set(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, val: storedDrawings!)
          
          detailCardView.storage = storedDrawings!
          
          currentFile = save
          updateDetailCardView()
          
          return save
     }
     
     /// Prompts a model to be saved and returns the save in a completion hanlder
     func promptSave(completionHandler:((SaveModel)->Void)? = nil) {
          let thumbnail:UIImage = (canvasProvider.captureSnapshot(saveToAlbum: false)?.squared)!
          EntryProvider().showForm(title: "Save File", fields: [EntryFormField(placeholder: "Untitled", textColor: Color.primary, placeholderColor: Color.gray, isSecureText: false, icon: #imageLiteral(resourceName: "Upload Icon.png").resizeWith(width: 25)?.maskWithColor(color: Color.gray))], button: EntryButton(text: "Save", action: { (output:Any?) in
               if let outputDict = output as? [String:String] {
                    let savedDrawing = SaveModel(fileName: outputDict["Untitled"]!, thumbnail: thumbnail, screenshots: self.currentFile?.getScreenshots() ?? [], drawing: self.canvasProvider.drawList, saveDate: Date())
                    if completionHandler != nil {
                         completionHandler!(savedDrawing)
                    } else {
                         _ = self.save(save: savedDrawing)
                    }
                    self.updateDetailCardView()
               }
               return
          }, textColor: Color.primary, backgroundColor: Color.offWhite), position: .center)
     }
     
     /// Clears the current save
     func clear() {
          currentFile = SaveModel(fileName: "", thumbnail: UIImage(), screenshots: [], drawing: canvasProvider.drawList, saveDate: nil)
          canvasProvider.clear()
          updateDetailCardView()
     }
     
     /// Load the given saved model
     func load(file:SaveModel) {
          canvasProvider.loadDrawing(drawing: file.getSavedDrawing())
          updateDetailCardView()
     }
     
     /// Delete the given file
     func delete(file:SaveModel) {
          var storedDrawings:StorageModel? = StorageProvider.get(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, valueType:StorageModel.self) as? StorageModel
          if storedDrawings == nil {
               storedDrawings = StorageModel()
          }
          _ = storedDrawings?.remove(save: file)
          
          _ = StorageProvider.set(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, val: storedDrawings!)
          
          detailCardView.storage = storedDrawings!
          
          clear()
     }
     
     //
     // Actions
     //
     
     @objc func didLongPressCanvas(_ sender:UILongPressGestureRecognizer) {
          
          if sender.state == .began {
               
               // TODO: - Check for erase
               if true {
                    
                    // Vibrate on press
                    FeedbackProvider.strong()
                    
                    canvasProvider.newStroke(brush: self.brush!)
                    
                    var count = 1
                    
                    brushQueue.execute(actions: {() -> Void in
                         // Account for the brush's radius in centering the cursor
                         
                         print("\(String(describing: self.brush?.color)) brush ran \(count) times")
                         
                         let worldCoord:SCNVector3? = self.canvasProvider.getWorldCoordinates(screenCoord: self.cursorProvider.cursorPos)
                         if (self.brush != nil && self.currentWorldCoord != nil && worldCoord != nil) {
                              // The following occurs on a tap:
                              // canvasProvider.draw(brush: brush, worldCoord: worldCoord!)
                              // canvasProvider.drawLine(brush: brush, from: currentWorldCoord!, to: worldCoord!)
                              
                              // Capsule-based line drawing
                              // Registered an undo function for this in viewdidload
                              _ = self.canvasProvider.drawThickLine(brush: self.brush!, from: self.currentWorldCoord!, to: worldCoord!)
                         }
                         if (worldCoord != nil) {
                              // Create a starting point for the next brush stroke
                              self.currentWorldCoord = worldCoord
                         }
                         
                         // Increment the number of runs for the brush (FOR DEBUGGING)
                         count += 1
                    }, iterate: true)
                    
                    // Continue dispatch for brush actions
                    brushQueue.resume()
                    
               }
               
          } else if sender.state != .changed {
               
               print("RELEASED CANVAS")
               
               // Vibrate less on release
               FeedbackProvider.medium()
               
               brushQueue.suspend()
               
               // If continues lines is on, omit the following line
               // This'll make drawing continuous
               currentWorldCoord = nil
               //
               
               // Append current list to drawing list
               canvasProvider.appendCurrentList()
               
               // Display undo and redo if able
               displayOperations(true)
               
               currentFile?.overwrite(thumbnail: (currentFile?.getThumbnail())!, screenshots: (currentFile?.getScreenshots())!, drawing: self.canvasProvider.drawList, saveDate: nil)
          }
     }
     
     /// Handles color changing for brush
     @IBAction func brushColorButtonPressed(_ sender: Any) {
          
          let colorPickerVC = ColorController(nibName: "ColorController", bundle: nil)
          colorPickerVC.delegate = self
          
          let POPUP_SIDE:CGFloat = 300
          
          let popupVC = PopupViewController(contentController: colorPickerVC, popupWidth: POPUP_SIDE, popupHeight: POPUP_SIDE)
          
          showOverlay()
          popupVC.backgroundAlpha = 0.0
          popupVC.backgroundColor = .clear
          popupVC.shadowEnabled = false
          popupVC.canTapOutsideToDismiss = true
          popupVC.cornerRadius = POPUP_SIDE/2
          
          popupVC.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToHideOverlayView)))
          
          self.colorPickerPopup = popupVC
          
          present(popupVC, animated: true)
          
          FeedbackProvider.medium()
     }
     
     
     // Bucket button
     @IBAction func bucketPressed(_ sender: Any) {
          
          // Vibrate on press
          FeedbackProvider.strong()
          
          // Change cursor to show erasing
          cursorProvider.changeToBucket()
          
          // Begin async queue
          bucketQueue.execute(actions: {() -> Void in
               let worldCoord:SCNVector3? = self.canvasProvider.getWorldCoordinates(screenCoord: self.cursorProvider.cursorPos)
               if (self.brush != nil && worldCoord != nil) {
                    // Capsule recoloring
                    _ = self.canvasProvider.recolor(brush: self.brush!, worldCoord: worldCoord!)
               }
          }, iterate: true)
          
          bucketQueue.resume()
     }
     @IBAction func bucketReleased(_ sender: Any) {
          
          // Vibrate less on release
          FeedbackProvider.medium()
          
          // Change cursor to brush
          cursorProvider.revertToBrush()
          
          bucketQueue.suspend()
          
          // Display undo and redo if able
          displayOperations()
     }
     
     // Transform button
     @IBAction func transformPressed(_ sender: Any) {
     }
     @IBAction func transformReleased(_ sender: Any) {
     }
     
     // Capture button
     @IBAction func capturePressed(_ sender: Any) {
          // Call the snapshot capture function in CanvasProvider
          // The closure for this function is the onCapture function above
          if let snapshot = canvasProvider.captureSnapshot(saveToAlbum: false) {
               onCapture(snapshot: snapshot)
          }
     }
     
     // Eraser button
     @IBAction func eraserPressed(_ sender: Any) {
          
          // Vibrate on press
          FeedbackProvider.strong()
          
          // Change cursor to show erasing
          cursorProvider.changeToEraser()
          
          // Begin async queue
          eraseQueue.execute(actions: {() -> Void in
               let worldCoord:SCNVector3? = self.canvasProvider.getWorldCoordinates(screenCoord: self.cursorProvider.cursorPos)
               if (self.brush != nil && worldCoord != nil) {
                    // Capsule erasing
                    _ = self.canvasProvider.erase(brush: self.brush!, worldCoord: worldCoord!)
               }
          }, iterate: true)
          
          // Continue dispatch for brush actions
          eraseQueue.resume()
          
          currentFile?.overwrite(thumbnail: (currentFile?.getThumbnail())!, screenshots: (currentFile?.getScreenshots())!, drawing: self.canvasProvider.drawList, saveDate: nil)
     }
     @IBAction func eraserReleased(_ sender: Any) {
          
          // Vibrate less on release
          FeedbackProvider.medium()
          
          // Change cursor to brush
          cursorProvider.revertToBrush()
          
          eraseQueue.suspend()
          
          // Display undo and redo if able
          displayOperations()
          
          currentFile?.overwrite(thumbnail: (currentFile?.getThumbnail())!, screenshots: (currentFile?.getScreenshots())!, drawing: self.canvasProvider.drawList, saveDate: nil)
     }
     
     // Undo button
     @IBAction func undoButtonPressed(_ sender: Any) {
          // Determine whether undo or redo buttons may be displayed
          self.displayOperations()
          
          // Call feedback vibration
          FeedbackProvider.strong()
          
          // Execute undo asynchronously
          undoQueue.execute(actions: {() -> Void in
               _ = self.canvasProvider.undo()
               
               self.currentFile?.overwrite(thumbnail: (self.currentFile?.getThumbnail())!, screenshots: (self.currentFile?.getScreenshots())!, drawing: self.canvasProvider.drawList, saveDate: nil)
          })
     }
     
     // Redo button
     @IBAction func redoButtonPressed(_ sender: Any) {
          // Determine whether undo or redo buttons may be displayed
          self.displayOperations()
          
          // Call feedback vibration
          FeedbackProvider.strong()
          
          // Execute redo asynchronously
          redoQueue.execute(actions: {() -> Void in
               _ = self.canvasProvider.redo()
               
               self.currentFile?.overwrite(thumbnail: (self.self.currentFile?.getThumbnail())!, screenshots: (self.currentFile?.getScreenshots())!, drawing: self.canvasProvider.drawList, saveDate: nil)
          })
     }
     
     // Called when the controller is pressed
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          
     }
     
     // Called when the controller is released
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          
     }
     
     // Runs asynchronous functions in renderer
     func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
          
     }
     
     //
     // UI functions
     //
     
     // Displays undo and redo buttons if they can be pressed
     func displayOperations(_ override:Bool = false) {
          
          // Hide undo button if there is no overide and the number of drawn strokes is <= 1
          undoButton.isEnabled = canvasProvider.drawList.getCount() < 1
          
          
          // Hide redo button if the number of undone strokes is less than 1
          redoButton.isEnabled = canvasProvider.undoList.getCount() < 1
     }
     
}

// MARK: - UIGestureRecognizerDelegate
extension CanvasController:UIGestureRecognizerDelegate {
     
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
          return true
     }
     
}

// MARK: - SizeSliderViewDelegate
extension CanvasController:SizeSliderViewDelegate {
     
     func sizeSliderView(didChangeValue value: Int) {
          self.cursorProvider.resizeCursor(radius: CGFloat(value))
          self.brush?.resize(toValue: value)
     }
     
}

// MARK: - ColorControllerDelegate
extension CanvasController:ColorControllerDelegate {
     
     func colorController(didChangeColorTo color: UIColor) {
          changeBrushColor(toColor: color)
     }
     
}
