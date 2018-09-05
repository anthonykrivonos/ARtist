//
//  DetailCardView.swift
//  ARtist
//
//  Created by Anthony Krivonos on 9/3/18.
//  Copyright © 2018 Anthony Krivonos. All rights reserved.
//

import UIKit

class DetailCardView: UIView {
    
    // MARK: - Constants
    
    public static let PEEK_VIEW_HEIGHT:CGFloat = 40
    
    // MARK: - IBOutlets
    
    /// Height constraint for peek view
    @IBOutlet weak var peekViewHeightConstraint: NSLayoutConstraint!
    
    /// Button that saves file on press
    @IBOutlet weak var saveButton: UIButton!
    
    /// Label displaying the name of the current file
    @IBOutlet weak var fileNameLabel: UILabel!
    
    /// Label displaying the time the file was last saved
    @IBOutlet weak var lastSavedTimeLabel: UILabel!
    
    /// Table view displaying all details
    @IBOutlet weak var detailTableView: UITableView!
    
    // MARK: - Globals
    
    /// Titles of each section
    let sectionTitles = ["", "Statistics", "Screenshots", "Load Recents" ]
    
    /// File being currently edited
    var currentSave:SaveModel? {
        didSet {
            fileNameLabel.textColor = currentSave != nil ? Color.offWhite : Color.gray
            saveButton.tintColor = currentSave != nil ? Color.offWhite : Color.secondary
            if currentSave != nil && currentSave?.getSaveDate() != nil {
                fileNameLabel.text = currentSave?.getFileName()
                lastSavedTimeLabel.text = currentSave?.getSaveDate()!.timeAgo()
            } else {
                fileNameLabel.text = "Untitled"
                lastSavedTimeLabel.text = "Tap to Save"
            }
        }
    }
    
    /// Save storage model
    var storage:StorageModel?
    
    /// Canvas Controller with drawing
    var canvasController:CanvasController!
    
    override var intrinsicContentSize:CGSize {
        return CGSize(width: frame.width, height: detailTableView.contentSize.height + DetailCardView.PEEK_VIEW_HEIGHT)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    /// Called when the view loads from the XIB.
    func didLoad() {
        fromNib()
        
        /// Set peek view height constant
        peekViewHeightConstraint.constant = DetailCardView.PEEK_VIEW_HEIGHT
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.estimatedRowHeight = 150
        detailTableView.register(UINib(nibName: "DetailDynamicCell", bundle: nil), forCellReuseIdentifier: "DetailDynamicCell")
        detailTableView.delegate = self
        detailTableView.dataSource = self
    }
    
    /// Refresh labels and table view
    func updateDetails() {
        detailTableView.reloadData()
        fileNameLabel.textColor = currentSave != nil ? Color.offWhite : Color.gray
        saveButton.tintColor = currentSave != nil ? Color.offWhite : Color.secondary
    }
    
    //
    // Save/Load Functions
    //
    
    func save(save:SaveModel) {
        var storedDrawings:StorageModel? = StorageProvider.get(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, valueType:StorageModel.self) as? StorageModel
        
        if storedDrawings == nil {
            storedDrawings = StorageModel()
        }
        
        _ = storedDrawings?.save(save: save)
        
        _ = StorageProvider.set(key: SaveProvider.LOCAL_SAVED_DRAWINGS_KEY, val: storedDrawings!)
        
        storage = storedDrawings!
        
        // Load filename and current file
        canvasController.currentFile = save
        currentSave = save
    }
    
    func promptSave() {
        let thumbnail:UIImage = (canvasController.canvasProvider.captureSnapshot(saveToAlbum: false)?.squared)!
        EntryProvider().showForm(title: "Save File", fields: [EntryFormField(placeholder: "Untitled", textColor: Color.primary, placeholderColor: Color.gray, isSecureText: false, icon: #imageLiteral(resourceName: "Upload Icon.png").resizeWith(width: 25)?.maskWithColor(color: Color.gray))], button: EntryButton(text: "Save", action: { (output:Any?) in
            if let outputDict = output as? [String:String] {
                let savedDrawing = SaveModel(fileName: outputDict["Untitled"]!, thumbnail: thumbnail, screenshots: self.currentSave?.getScreenshots() ?? [], drawing: self.canvasController.canvasProvider.drawList, saveDate: Date())
                self.save(save: savedDrawing)
            }
            return
        }, textColor: Color.primary, backgroundColor: Color.offWhite), position: .center)
    }
    
    func clear() {
        canvasController.currentFile = SaveModel(fileName: "", thumbnail: UIImage(), screenshots: [], drawing: canvasController.canvasProvider.drawList, saveDate: nil)
        canvasController.canvasProvider.clear()
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        promptSave()
    }
    
}

extension DetailCardView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionTitles[section] {
            case "Statistics":
                // Statistics Section
                if currentSave == nil {
                    return 0
                }
                break
            case "Screenshots":
                // Screenshots Section
                if currentSave == nil || currentSave?.getScreenshots().count == 0 {
                    return 0
                }
                break
            case "Load Recents":
                // Load Recents Section
                if storage == nil || storage?.getStorage().count == 0 {
                    return 0
                }
                break
            default:
                break
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "DetailDynamicCell", for: indexPath) as! DetailDynamicCell
        
        switch sectionTitles[indexPath.section] {
            case "":
                // Large Button Section
                tableCell.type = .largeButtons
                break
            case "Statistics":
                // Statistics Section
                tableCell.type = .statistics
                break
            case "Screenshots":
                // Screenshots Section
                tableCell.type = .screenshots
                break
            case "Load Recents":
                // Load Recents Section
                tableCell.type = .loadRecents
                break
            default:
                break
        }
        tableCell.currentSave = currentSave
        tableCell.storage = storage
        
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sectionTitles[section] {
            case "":
                // Large Button Section
                return 0
            case "Statistics":
                // Statistics Section
                if currentSave == nil {
                    return 0
                }
                break
            case "Screenshots":
                // Screenshots Section
                if currentSave == nil || currentSave?.getScreenshots().count == 0 {
                    return 0
                }
                break
            case "Load Recents":
                // Load Recents Section
                if storage == nil || storage?.getStorage().count == 0 {
                    return 0
                }
                break
            default:
                break
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionTitle = sectionTitles[section]
        
        guard sectionTitle != "" else { return UIView(frame: .zero) }
        
        let headerView = UIView(frame: CGRect(x: 15, y: 0, width: self.detailTableView.frame.width - 15, height: 30))
        
        let sectionTitleLabel = UILabel(frame: headerView.frame)
        sectionTitleLabel.text = sectionTitle.uppercased()
        sectionTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        sectionTitleLabel.textColor = Color.gray
        
        headerView.addSubview(sectionTitleLabel)
        sectionTitleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 15).isActive = true
        sectionTitleLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: 4).isActive = true
        sectionTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4).isActive = true
        sectionTitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == sectionTitles.count - 1 ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 15, y: 0, width: self.detailTableView.frame.width - 15, height: 30))
        
        
        
        return footerView
    }
    
}
