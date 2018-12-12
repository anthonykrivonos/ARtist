//
//  DetailDynamicCell.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/4/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

/// Dynamic data for collection view
enum DetailDynamicType {
    case largeButtons
    case statistics
    case screenshots
    case loadRecents
}

class DetailDynamicCell: UITableViewCell {
    
    /// Canvas Controller with drawing
    var canvasController:CanvasController!
    
    // MARK: - Constants
    
    private static let COLLECTION_VIEW_WIDTH:CGFloat = 110
    
    private static let COLLECTION_VIEW_PADDING:CGFloat = 0
    
    private static let COLLECTION_VIEW_HEIGHTS:[DetailDynamicType:CGFloat] = [
        .largeButtons: 50,
        .statistics: 84,
        .screenshots: 150,
        .loadRecents: 150
    ]
    
    // MARK: - IBOutlets
    
    /// Collection view displaying detail data
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    /// Height constraint for detailCollectionView
    @IBOutlet weak var detailCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Globals
    
    var type:DetailDynamicType! {
        didSet {
            detailCollectionViewHeightConstraint.constant = DetailDynamicCell.COLLECTION_VIEW_HEIGHTS[type]!
            
            if detailCollectionView != nil {
                
                let layout = UICollectionViewFlowLayout()
                layout.minimumLineSpacing = DetailDynamicCell.COLLECTION_VIEW_PADDING
                layout.minimumInteritemSpacing = DetailDynamicCell.COLLECTION_VIEW_PADDING
                layout.itemSize = CGSize(width: DetailDynamicCell.COLLECTION_VIEW_WIDTH, height: DetailDynamicCell.COLLECTION_VIEW_HEIGHTS[type]!)
                layout.scrollDirection = .horizontal
                layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
                detailCollectionView.setCollectionViewLayout(layout, animated: false)
                detailCollectionView.delegate = self
                detailCollectionView.dataSource = self
            }
        }
    }
    
    var currentSave:SaveModel? {
        didSet {
            if currentSave != nil {
                detailCollectionView.delegate = self
                detailCollectionView.dataSource = self
            }
        }
    }
    
    var storage:StorageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        detailCollectionView.register(UINib(nibName: "FileCell", bundle: nil), forCellWithReuseIdentifier: "FileCell")
        detailCollectionView.register(UINib(nibName: "ScreenshotCell", bundle: nil), forCellWithReuseIdentifier: "ScreenshotCell")
        detailCollectionView.register(UINib(nibName: "StatisticsCell", bundle: nil), forCellWithReuseIdentifier: "StatisticsCell")
        detailCollectionView.register(UINib(nibName: "LargeButtonCell", bundle: nil), forCellWithReuseIdentifier: "LargeButtonCell")
        
        detailCollectionView.showsHorizontalScrollIndicator = false
        
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
    }
    
}

extension DetailDynamicCell:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch type! {
            case .largeButtons:
                // Large Button Section
                return currentSave != nil && currentSave!.getSaveDate() != nil ? 3 : 1
            case .statistics:
                // Statistics Section
                return 4
            case .screenshots:
                // Screenshots Section
                return currentSave != nil ? (currentSave?.getScreenshots().count)! : 0
            case .loadRecents:
                // Load Recents Section
                return storage != nil ? (storage?.getCount())! : 0
            default:
                break
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch type! {
            case .largeButtons:
                // Large Button Section
                let largeButtonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeButtonCell", for: indexPath) as! LargeButtonCell
                if indexPath.row == 0 {
                    largeButtonCell.initialize(withTitle: "Save As", andTextColor: Color.primary, andBackgroundColor: Color.gray, andAction: {
                        self.canvasController.promptSave()
                    })
                } else if indexPath.row == 1 {
                    largeButtonCell.initialize(withTitle: "Save", andTextColor: Color.primary, andBackgroundColor: Color.gray, andAction: {
                        _ = self.canvasController.save(save: self.canvasController.currentFile!)
                    })
                } else if indexPath.row == 2 {
                    largeButtonCell.initialize(withTitle: "Delete", andTextColor: Color.offWhite, andBackgroundColor: Color.error, andAction: {
                        self.canvasController.delete(file: self.canvasController.currentFile!)
                    })
                }
                return largeButtonCell
            case .statistics:
                // Statistics Section
                let statisticsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticsCell", for: indexPath) as! StatisticsCell
                if indexPath.row == 0 {
                    statisticsCell.initialize(forStatistic: "Strokes", andNumber: (currentSave?.getSavedDrawing().getCount())!)
                } else if indexPath.row == 1 {
                    statisticsCell.initialize(forStatistic: "Colors", andNumber: (currentSave?.getSavedDrawing().getColorCount())!)
                } else if indexPath.row == 2 {
                    statisticsCell.initialize(forStatistic: "Length (m)", andNumber: Int((CGFloat((currentSave?.getSavedDrawing().getLength())!).toMeters)))
                } else if indexPath.row == 3 {
                    statisticsCell.initialize(forStatistic: "Size (mb)", andNumber: Int(((StorageProvider.get(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, valueType: StorageModel.self) as? Data ?? Data()).sizeInMB)))
                }
                return statisticsCell
            case .screenshots:
                // Screenshots Section
                let screenshotCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCell", for: indexPath) as! ScreenshotCell
                screenshotCell.initialize(withScreenshot: (currentSave?.getScreenshots()[indexPath.row])!)
                screenshotCell.canvasController = canvasController
                return screenshotCell
            case .loadRecents:
                // Load Recents Section
                let fileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as! FileCell
                fileCell.initialize(withFile: (storage?.getStorage()[indexPath.row])!)
                fileCell.canvasController = canvasController
                if canvasController.currentFile != nil && canvasController.currentFile!.getFileName() == fileCell.file.getFileName() {
                    fileCell.previewView.borderColor = .white
                    fileCell.previewView.borderWidth = 4
                }
                return fileCell
            default:
                break
            
        }
        return UICollectionViewCell()
    }
    
}

// MARK: - UIGestureRecognizer
extension DetailDynamicCell {
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
