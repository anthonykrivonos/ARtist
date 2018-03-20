//
//  ViewController.swift
//  ARtist
//
//  Created by Anthony Krivonos on 3/10/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

// Native Imports
import UIKit
import ARKit

// Pod Imports
import ColorSlider
import Hero

class ViewController: UIViewController, ARSCNViewDelegate {
      
      //
      // UI Outlets
      //

      // ARScene view for canvas
      @IBOutlet weak var canvasView: ARSCNView!
      @IBOutlet weak var undoButton: UIButton!
      @IBOutlet weak var redoButton: UIButton!
      
      // DQ for asynchronous methods
      let dispatchQueue:DispatchQueue = DispatchQueue(label: "com.AnthonyKrivonos.ARtist.DispatchQueue")
      var dispatchSuspended:Bool = false
      
      //
      // Canvas variables
      //
      
      // Tools for operating on canvasView
      var canvasProvider:CanvasProvider!
      
      // Cursor for drawing
      var cursorProvider:CursorProvider!
      
      // Color slider for color picking
      var colorSliderProvider:ColorSliderProvider!
      
      // Brush size slider for brush size changing
      var brushSizeSliderProvider:BrushSizeSliderProvider!
      
      // Position of current vector in world space
      var currentWorldCoord:SCNVector3?
      
      var colorSlider:ColorSlider?
      
      // Current brush in use
      var brush:BrushModel?
      
      //
      // Boolean Globals
      //
      
      // Allow repositioning of cursor
      var canReposition:Bool = true
      
      //
      // BrushTypeModels for different kinds of brushes
      //
      
      let pencil:BrushTypeModel = BrushTypeModel("pencil", 0.9, 0.8)
      let pen:BrushTypeModel = BrushTypeModel("pen", 0.7, 0.5)
      let marker:BrushTypeModel = BrushTypeModel("marker", 0.6, 0.2)
      let smoothBrush:BrushTypeModel = BrushTypeModel("smoothBrush", 0.3, 0.4)
      let roughBrush:BrushTypeModel = BrushTypeModel("roughBrush", 0.8, 0.4)
      let chalk:BrushTypeModel = BrushTypeModel("chalk", 0.9, 0.1)
      
      //
      // Constants
      //
      
      // Turns on debug features
      let DEBUG:Bool = true
      
      // Default brush variables
      let DEFAULT_BRUSH_COLOR:UIColor = UIColor.black
      let DEFAULT_BRUSH_OFFSET:Float = 0.1
      
      // Default slider variables
      let DEFAULT_SLIDER_PADDING:CGFloat = 20
      let DEFAULT_SLIDER_WIDTH:CGFloat = 20
      let DEFAULT_SLIDER_HEIGHT:CGFloat = 150
      
      // Default slider variables specifically for color slider
      let DEFAULT_COLOR_SLIDER_DIRECTION:DefaultPreviewView.Side = DefaultPreviewView.Side.left
      var DEFAULT_COLOR_SLIDER_POSITION:CGPoint?
      
      // Default slider variables specifically for brush size slider
      var DEFAULT_BRUSH_SIZE_SLIDER_POSITION:CGPoint?
      var DEFAULT_BRUSH_SIZE_SLIDER_WIDTH:CGFloat = 300
      var DEFAULT_BRUSH_SIZE_SLIDER_HEIGHT:CGFloat = 40
      var DEFAULT_BRUSH_SIZE_MAX:CGFloat = 200
      
      override func viewDidLoad() {
            super.viewDidLoad()
            
            isHeroEnabled = true
            
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
            canvasProvider = CanvasProvider(canvasView: canvasView, worldOffset: DEFAULT_BRUSH_OFFSET)

            // Sets default brush on open
            // TODO: Make this more dynamic
            brush = BrushModel(size: 2, color: DEFAULT_BRUSH_COLOR, opacity: 1, type: pen)
            
            // Creates round cursor and a provider along with it
            cursorProvider = CursorProvider(canvasView: canvasView, worldOffset: DEFAULT_BRUSH_OFFSET, position: CGPoint(x: canvasView.frame.midX, y: canvasView.frame.midY), radius: 25, thickness: 0.5, color: DEFAULT_BRUSH_COLOR, brush: brush!)
            
            //
            // Brush Size Slider
            //
            
            DEFAULT_BRUSH_SIZE_SLIDER_POSITION = CGPoint(x: canvasView.frame.midX, y: CGFloat(canvasView.frame.maxY - CGFloat(DEFAULT_BRUSH_SIZE_SLIDER_HEIGHT * 2)))
            
            // Draw the color slider
            brushSizeSliderProvider = BrushSizeSliderProvider(canvasView: canvasView, brushSizeSliderPos: DEFAULT_BRUSH_SIZE_SLIDER_POSITION!, width: DEFAULT_BRUSH_SIZE_SLIDER_WIDTH, height: DEFAULT_BRUSH_SIZE_SLIDER_HEIGHT, brush: brush!, cursorProvider: cursorProvider, brushSizeMax: DEFAULT_BRUSH_SIZE_MAX)
            
            //
            // Color Slider
            //
            
            // Initialize color slider in canvas
            DEFAULT_COLOR_SLIDER_POSITION = CGPoint(x: canvasView.frame.maxX - CGFloat(DEFAULT_SLIDER_WIDTH/2), y: CGFloat((canvasView.frame.height - DEFAULT_SLIDER_HEIGHT)/2))
            
            // Draw the color slider
            colorSliderProvider = ColorSliderProvider(canvasView: canvasView, colorSliderPos: DEFAULT_COLOR_SLIDER_POSITION!, width: DEFAULT_SLIDER_WIDTH, height: DEFAULT_SLIDER_HEIGHT, padding: DEFAULT_SLIDER_PADDING, direction: DEFAULT_COLOR_SLIDER_DIRECTION, brush: brush!, cursor: cursorProvider.cursor, brushSizeSliderProvider: brushSizeSliderProvider)
      }
      
      override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            
            // Enable plane detection
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            canvasView.session.run(configuration)
            
            // Display undo and redo if able
            displayOperations()
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
      
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            // Display undo and redo if able
            displayOperations()
            
            if (canReposition) {
                  cursorProvider.repositionCursor(position: (touches.first?.location(in: cursorProvider.cursorView))!)
            }
            
            // Begin async queue
            defineUpdateQueue(actions: { () -> Void in
                  self.handleTap()
            })
            resumeUpdateQueue()
      }
      
      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            // If continues lines is on, omit the following line
            // This'll make drawing continuous
            currentWorldCoord = nil
            //
            suspendUpdateQueue()
      }

      // Completes something on a tap
      func handleTap() -> Void {
            // Account for the brush's radius in centering the cursos
            
            let worldCoord:SCNVector3? = canvasProvider.getWorldCoordinates(screenCoord: cursorProvider.cursorPos)
            if (brush != nil && currentWorldCoord != nil && worldCoord != nil) {
                  // The following occurs on a tap:
                  // canvasProvider.draw(brush: brush, worldCoord: worldCoord!)
                  // canvasProvider.drawLine(brush: brush, from: currentWorldCoord!, to: worldCoord!)
                  
                  // Capsule-based line drawing
                  // Registered an undo function for this in viewdidload
                  _ = canvasProvider.drawThickLine(brush: brush!, from: currentWorldCoord!, to: worldCoord!)
            }
            if (worldCoord != nil) {
                  currentWorldCoord = worldCoord
            }
      }
      
      // Runs asynchronous functions in renderer
      func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            defineUpdateQueue(actions: { () -> Void in
                  
            })
      }
      
      // Hides status bar
      override var prefersStatusBarHidden : Bool {
            return true
      }
      
      //
      // ML Methods
      //
      
      // Define asynchronous methods to call in thread
      func defineUpdateQueue(actions:@escaping ()->Void) {
            dispatchQueue.async {
                  
                  // Only runs if the dispatch isn't suspended
                  // Crucial to efficiency
                  guard !self.dispatchSuspended else { return }
                  
                  // Runs actions
                  actions();
                  
                  // Recurrance call
                  self.defineUpdateQueue(actions: actions)
            }
      }
      
      // Asynchronous calling of coreML dispatcher
      func resumeUpdateQueue() {
            if (dispatchSuspended) {
                  dispatchQueue.resume()
            }
            dispatchSuspended = false;
      }
      
      // Suspend asynchronous dispatcher
      func suspendUpdateQueue() {
            if (!dispatchSuspended) {
                  dispatchQueue.suspend()
            }
            dispatchSuspended = true;
      }
      
      //
      // UI functions
      //
      
      func displayOperations() {
            undoButton.isHidden = !canvasProvider.canUndo()
            redoButton.isHidden = !canvasProvider.canRedo()
      }
      
      @IBAction func undoButtonPressed(_ sender: Any) {
            if (canvasProvider.canUndo()) {
                  _ = canvasProvider.undo(specificity: 10)
            }
      }
      
      @IBAction func redoButtonPressed(_ sender: Any) {
            if (canvasProvider.canRedo()) {
                  _ = canvasProvider.redo()
            }
      }
      
}

